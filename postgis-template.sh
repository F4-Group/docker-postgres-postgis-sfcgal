#!/bin/zsh -e
echo "Creating template postgis"
gosu postgres createdb template_postgis -E UTF8 -T template0
echo "Enabling template_postgis as a template"
gosu postgres postgres -c "UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';"
echo "enabling postgis"
gosu postgres postgres -d template_postgis -c "CREATE EXTENSION postgis;"
gosu postgres postgres -d template_postgis -c "CREATE EXTENSION postgis_topology;"
echo "Loading sfcgal.sql"
gosu postgres postgres -d template_postgis -f /scripts/sfcgal.sql
