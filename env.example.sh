#!/bin/sh

#
# Environmental variables for SoleCRIS->DSpace import scripts
# 
export PATH=/opt/solecris-dspace/bin:$PATH
export PGPASSWORD=**PUT YOUR POSTGRES PASSWORD HERE** (remember to use suitable permissions, as well)
export DS_DIR=/dspace
export DS_COLLECTION=123456789/1 
export DS_EPERSON=dspace-user@example.com
export DS_MAPDIR=/opt/solecris-dspace/maps
export DS_LICENSE=/opt/solecris-dspace/pp-collection-license.txt
export DS_FLAGS=--test
export SOLE_CSV_FILE=/home/solecris/upload/solecris_dspace.csv

