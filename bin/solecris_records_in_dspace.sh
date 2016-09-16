#! /bin/sh

#
# Script that produces SoleCRIS ids that are already
# in DSpace's database (ingested or in the queue)
#
# Put PostgreSQL password DSpace's database to enviromental
# variable PGPASSWORD. If you want to override default database
# name or user ('dspace') use environmental variables PGDATABASE
# and PGUSER
#

if [ -z "$PGDATABASE" ] ; then
	dbname="dspace"
else
	dbname=$PGDATABASE
fi

if [ -z "$PGUSER" ] ; then
	dbuser="dspace"
else
	dbuser=$PGUSER
fi

if [ -z "$PGPASSWORD" ] ; then
	echo "Warning: PGPASSWORD not set"
fi

psql $dbname -U $dbuser -h 127.0.0.1 << EOF
select distinct a.text_value "uef.solecris.id", b.text_value "dc.title" 
from ( 
     select dspace_object_id, text_value 
     from metadatavalue 
     where metadata_field_id = (

     	 select metadata_field_id 
	 from metadatafieldregistry r, metadataschemaregistry s 
	 where s.short_id = 'uef' and r.element = 'solecris' 
	 and r.qualifier = 'id' and r.metadata_schema_id = s.metadata_schema_id)) a 

	 join (

	 select dspace_object_id, text_value 
	 from metadatavalue 
	 where metadata_field_id = (

	  	 select metadata_field_id 
		 from metadatafieldregistry r, metadataschemaregistry s 
		 where s.short_id = 'dc' and r.element = 'title' 
		 and r.qualifier is null and r.metadata_schema_id = s.metadata_schema_id)) b 

	 on a.dspace_object_id = b.dspace_object_id;
EOF


