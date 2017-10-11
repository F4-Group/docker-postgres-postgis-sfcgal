#!/bin/sh

set -e

PROCESSOR_COUNT=$(nproc)

#from http://postgis.net/source
POSTGIS=http://download.osgeo.org/postgis/source/postgis-$POSTGIS_VERSION.tar.gz

#from http://trac.osgeo.org/geos/
GEOS=http://download.osgeo.org/geos/geos-$GEOS_VERSION.tar.bz2
#from http://trac.osgeo.org/gdal/wiki/DownloadSource
GDAL=http://download.osgeo.org/gdal/$GDAL_VERSION/gdal-$GDAL_VERSION.tar.gz
#from http://proj4.org/download.html
PROJ=http://download.osgeo.org/proj/proj-$PROJ_VERSION.tar.gz
#from https://www.cgal.org/releases.html
CGAL=https://github.com/CGAL/cgal/releases/download/releases%2FCGAL-$CGAL_VERSION/CGAL-$CGAL_VERSION.tar.xz
#from https://github.com/Oslandia/SFCGAL/releases
SFCGAL=https://github.com/Oslandia/SFCGAL/archive/v$SFCGAL_VERSION.tar.gz

mkdir -p /install-postgis/geos
cd /install-postgis/geos
wget -O /install-postgis/geos.tar.bz2 $GEOS
tar xf /install-postgis/geos.tar.bz2 -C /install-postgis/geos --strip-components=1
./configure && make -j $PROCESSOR_COUNT && make install
ldconfig
cd /install-postgis
test -x geos

mkdir -p /install-postgis/gdal
cd /install-postgis/gdal
wget -O /install-postgis/gdal.tar.gz $GDAL
tar xf /install-postgis/gdal.tar.gz -C /install-postgis/gdal --strip-components=1
./configure --with-geos=/usr/local/bin/geos-config && make -j $PROCESSOR_COUNT && make install
ldconfig
cd /install-postgis
test -x gdal

mkdir -p /install-postgis/proj
cd /install-postgis/proj
wget -O /install-postgis/proj.tar.gz $PROJ
tar xf /install-postgis/proj.tar.gz -C /install-postgis/proj --strip-components=1
./configure && make -j $PROCESSOR_COUNT && make install
cd /install-postgis
test -f /usr/local/include/proj_api.h

mkdir -p /install-postgis/cgal
cd /install-postgis/cgal
wget -O /install-postgis/cgal.tar.xz $CGAL
tar xf /install-postgis/cgal.tar.xz -C /install-postgis/cgal --strip-components=1
cmake . && make -j $PROCESSOR_COUNT && make install
cd /install-postgis
test -d /usr/local/lib/CGAL

sfcgal_config=/usr/local/bin/sfcgal-config
mkdir -p /install-postgis/sfcgal
cd /install-postgis/sfcgal
wget -O /install-postgis/sfcgal.tar.gz $SFCGAL
tar xf /install-postgis/sfcgal.tar.gz -C /install-postgis/sfcgal --strip-components=1
cmake . && make -j $PROCESSOR_COUNT && make install
cd /install-postgis
test -x $sfcgal_config

mkdir -p /install-postgis/postgis
cd /install-postgis/postgis
wget -O /install-postgis/postgis.tar.gz $POSTGIS
tar xf /install-postgis/postgis.tar.gz -C /install-postgis/postgis --strip-components=1
./configure --with-geosconfig=/usr/local/bin/geos-config --with-gdalconfig=/usr/local/bin/gdal-config --with-sfcgal=$sfcgal_config --with-projdir=/usr/local --with-raster --with-topology && make
cd /install-postgis/postgis/extensions/postgis
make -j $PROCESSOR_COUNT && make install
cd /install-postgis/postgis/extensions/postgis_topology
make -j $PROCESSOR_COUNT && make install
cd /install-postgis/postgis
make install
cd /install-postgis
ldconfig

cd /
rm -rf /install-postgis
