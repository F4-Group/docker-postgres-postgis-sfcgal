#!/bin/sh -e
#inspired by https://github.com/appropriate/docker-postgis/blob/master/9.4-2.1/initdb-postgis.sh

echo "Creating template_postgis as a template"
gosu postgres postgres --single -E <<EOSQL
CREATE DATABASE template_postgis TEMPLATE template0 ENCODING 'UTF8';
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

POSTGIS_CONFIG=/usr/share/postgresql/$PG_MAJOR/contrib/postgis-$POSTGIS_MAJOR
#postgres does not allow CREATE EXTENSION in single user mode
gosu postgres postgres --single -j template_postgis < $POSTGIS_CONFIG/postgis.sql
gosu postgres postgres --single -j template_postgis < $POSTGIS_CONFIG/topology.sql
gosu postgres postgres --single -j template_postgis < $POSTGIS_CONFIG/spatial_ref_sys.sql
gosu postgres postgres --single -j template_postgis < $POSTGIS_CONFIG/sfcgal.sql
