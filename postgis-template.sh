#!/bin/bash -e
# file is sourced from a bash script so shebang is not used
#inspired by https://github.com/appropriate/docker-postgis/blob/master/9.4-2.1/initdb-postgis.sh

echo "Creating template_postgis as a template"
psql --username "$POSTGRES_USER" <<- EOSQL
CREATE DATABASE template_postgis TEMPLATE template0 ENCODING 'UTF8';
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

#http://stackoverflow.com/questions/27547933/how-to-create-postgis-extension-for-postgresql-in-docker
psql --username "$POSTGRES_USER" --dbname "template_postgis" <<- 'EOSQL'
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
CREATE EXTENSION postgis_sfcgal;
EOSQL

#also enable it on given POSTGRES_DB (default to postgres)
psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<- 'EOSQL'
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
CREATE EXTENSION postgis_sfcgal;
EOSQL
