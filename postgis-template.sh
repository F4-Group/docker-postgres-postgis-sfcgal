#!/bin/bash -e
# file is sourced from a bash script so shebang is not used
#inspired by https://github.com/appropriate/docker-postgis/blob/master/9.4-2.1/initdb-postgis.sh

echo "Creating template_postgis as a template"
psql --username "$POSTGRES_USER" <<EOSQL
CREATE DATABASE template_postgis TEMPLATE template0 ENCODING 'UTF8';
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

#http://stackoverflow.com/questions/27547933/how-to-create-postgis-extension-for-postgresql-in-docker
POSTGIS_CONFIG=/usr/share/postgresql/$PG_MAJOR/contrib/postgis-$POSTGIS_MAJOR
#postgres does not allow CREATE EXTENSION in single user mode
psql --username "$POSTGRES_USER" --dbname template_postgis < $POSTGIS_CONFIG/postgis.sql
psql --username "$POSTGRES_USER" --dbname template_postgis < $POSTGIS_CONFIG/topology.sql
psql --username "$POSTGRES_USER" --dbname template_postgis < $POSTGIS_CONFIG/spatial_ref_sys.sql
psql --username "$POSTGRES_USER" --dbname template_postgis < $POSTGIS_CONFIG/rtpostgis.sql
psql --username "$POSTGRES_USER" --dbname template_postgis < $POSTGIS_CONFIG/sfcgal.sql

#also enable it on given POSTGRES_DB (default to postgres)
psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < $POSTGIS_CONFIG/postgis.sql
psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < $POSTGIS_CONFIG/topology.sql
psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < $POSTGIS_CONFIG/spatial_ref_sys.sql
psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < $POSTGIS_CONFIG/rtpostgis.sql
psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < $POSTGIS_CONFIG/sfcgal.sql
