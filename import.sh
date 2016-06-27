#! /bin/sh

#
# A master script controlling the SoleCRIS->DSpace import process
#
# NOTE: you must set environmental variable PGPASSWORD (password for PostgreSQL)
# for this script to work. If you have changed default database settings, you may
# also need to provide other variables. See below for other used.
#

#
# Check if necessary environmental variables are set
#

#
# Variables with defaults
# 
if [ "x$DS_DIR" == "x" ]; 
then 
	echo "Setting DS_DIR (DSpace directory) to /dspace"; 
	DS_DIR=/dspace; 
fi

if [ "x$DS_MAPDIR" == "x" ]; 
then 
	echo "Setting DS_MAPDIR (Directory for DSpace import maps) to /opt/solecris-dspace/maps"; 
	DS_MAPDIR=/opt/solecris-dspace/maps; 
fi

if [ "x$SOLE_CSV_CONF" == "x" ];
then
	echo "Setting SOLE_CSV_CONF (Config file for prepare-csv) to /opt/solecris-dspace/config.json";
	SOLE_CSV_CONF=/opt/solecris-dspace/config.json
fi

if [ "x$SOLE_CSV_FILE" == "x" ];
then
	echo "Setting SOLE_CSV_FILE (CSV input from SoleCRIS) to /opt/solecris-dspace/solecris_dspace.csv";
	SOLE_CSV_FILE=/opt/solecris-dspace/solecris_dspace.csv
fi

#
# Variables without defaults
#
if [ "x$DS_COLLECTION" == "x" ]; 
then 
	echo "You must set DS_COLLECTION (DSpace import collection) environmental variable!"; 
	exit 1; 
fi

if [ "x$DS_EPERSON" == "x" ]; 
then 
	echo "You must set DS_EPERSON (EPerson doing the import) environmental variable!"; 
	exit 1; 
fi

#
# Print notifications for missing, but not always necessary variables 
#
if [ "x$DS_LICENSE" == "x" ];
then
	echo "DS_LICENCE not set. Not adding license files to the archive."
fi

if [ "x$PGPASSWORD" == "x" ];
then
	echo "PGPASSWORD not set! Ensure that the user running this script can access the database without it!"
fi

#
# Internal variables, these shouldn't normally need changing
#
WORKDIR=/tmp/solecris-dspace
TMP0=$WORKDIR/header_dropped.csv
TMP1=$WORKDIR/prepared_solecris.csv
TMP2=$WORKDIR/tmp.csv
TMP3=$WORKDIR/pruned_solecris.csv
ARCHIVEDIR=$WORKDIR/archive

#
# Check if binaries are in path
#
command -v prepare-csv >/dev/null 2>&1 || { echo "prepare-csv command is not installed. Aborting." >&2; exit 1; }
command -v saf-archiver >/dev/null 2>&1 || { echo "saf-archiver command is not installed. Aborting." >&2; exit 1; }
command -v add-file >/dev/null 2>&1 || { echo "add-file command is not installed. Aborting." >&2; exit 1; }
command -v solecris_records_in_dspace.sh >/dev/null 2>&1 || { echo "solecris_records_in_dspace.sh command is not installed. Aborting." >&2; exit 1; }

#
# Delete old working directory, if it exists
#
if [ -d "$WORKDIR" ]; then
    rm -rf "$WORKDIR"
fi
mkdir "$WORKDIR"

#
# Prepare CSV-file for SAF Archiver
#

# Remove header and check if there is content
tail -n +2 $SOLE_CSV_FILE > $TMP0

LINES=`wc -l $TMP0 | sed 's/^\([0-9]*\).*$/\1/'`

if [ $LINES -lt 1 ]
then
	echo "No records to be processed."
	exit 0
fi

prepare-csv $SOLE_CSV_CONF $TMP0 > $TMP1

#
# Remove items already in DSpace by SoleCRIS id
# (Easier to do here, with prepared CSV-file)
# Removal is O(n^2) but should suffice
#

IDS=$(solecris_records_in_dspace.sh | head -n -2 | tail -n +3 | awk '{ print $1; }')
cp $TMP1 $TMP2

for ID in $IDS
do
	cat $TMP2 | awk -v soleid="$ID" -F";" '$1 != soleid' > $TMP3
	cp $TMP3 $TMP2
	
done

# Check if there is still content
LINES=`wc -l $TMP2 | sed 's/^\([0-9]*\).*$/\1/'`

if [ $LINES -lt 2 ]
then
        echo "No new records to be processed."
        exit 0
fi

#
# Create SAF Archive
#
if [ -d "$ARCHIVEDIR" ]; 
then
    rm -rf "$ARCHIVEDIR"
fi

saf-archiver $TMP2 $ARCHIVEDIR

#
# Add LICENSE files to archive
#

if [ "x$DS_LICENSE" != "x" ];
then
	add-file -m "bundle:LICENSE" $DS_LICENSE $ARCHIVEDIR
fi

#
# Import to DSpace
#

# Check for MAP-directory
if [[ ! -d "$DS_MAPDIR" ]];
then
	echo "Creating MAP-directory $DS_MAPDIR..."
	mkdir -p $DS_MAPDIR
fi


MAPFILE=$DS_MAPDIR/map-$(date +"%Y-%m-%d")

$DS_DIR/bin/dspace import $DS_FLAGS --add --collection $DS_COLLECTION --source $ARCHIVEDIR --eperson $DS_EPERSON \
    --mapfile $MAPFILE --workflow
