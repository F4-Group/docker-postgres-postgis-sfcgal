#!/bin/zsh -e
echo "Creating template_postgis as a template"
gosu postgres postgres --single -E <<EOSQL
CREATE DATABASE template_postgis TEMPLATE template0 ENCODING 'UTF8';
EOSQL

gosu postgres postgres --single -jE <<EOSQL
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

gosu postgres postgres --single -jE template_postgis <<EOSQL
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
EOSQL

gosu postgres postgres --single -jE template_postgis << /scripts/sfcgal.sql
