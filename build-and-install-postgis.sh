#!/bin/sh

set -e

PROCESSOR_COUNT=$(nproc)
BUILD_DIR=/install-postgis
INSTALL_DIR=/usr/local

#from http://postgis.net/source
POSTGIS=http://download.osgeo.org/postgis/source/postgis-$POSTGIS_VERSION.tar.gz

#from http://trac.osgeo.org/geos/
GEOS=http://download.osgeo.org/geos/geos-$GEOS_VERSION.tar.bz2
#from http://trac.osgeo.org/gdal/wiki/DownloadSource
GDAL=http://download.osgeo.org/gdal/$GDAL_VERSION/gdal-$GDAL_VERSION.tar.gz
#from http://proj4.org/download.html
PROJ=http://download.osgeo.org/proj/proj-$PROJ_VERSION.tar.gz
#from https://www.cgal.org/releases.html
CGAL=https://github.com/CGAL/cgal/archive/releases/CGAL-$CGAL_VERSION.tar.gz
#from https://github.com/Oslandia/SFCGAL/releases
SFCGAL=https://github.com/Oslandia/SFCGAL/archive/v$SFCGAL_VERSION.tar.gz

mkdir -p $BUILD_DIR/geos
cd $BUILD_DIR/geos
wget -O $BUILD_DIR/geos.tar.bz2 $GEOS
tar xf $BUILD_DIR/geos.tar.bz2 -C $BUILD_DIR/geos --strip-components=1
./configure --prefix=$INSTALL_DIR --disable-shared --enable-static && make -j $PROCESSOR_COUNT && make install
ldconfig
cd $BUILD_DIR
test -x geos

mkdir -p $BUILD_DIR/gdal
cd $BUILD_DIR/gdal
wget -O $BUILD_DIR/gdal.tar.gz $GDAL
tar xf $BUILD_DIR/gdal.tar.gz -C $BUILD_DIR/gdal --strip-components=1
./configure --prefix=$INSTALL_DIR --disable-shared --enable-static --with-geos=$INSTALL_DIR/bin/geos-config && make -j $PROCESSOR_COUNT && make install
ldconfig
cd $BUILD_DIR
test -x gdal

mkdir -p $BUILD_DIR/proj
cd $BUILD_DIR/proj
wget -O $BUILD_DIR/proj.tar.gz $PROJ
tar xf $BUILD_DIR/proj.tar.gz -C $BUILD_DIR/proj --strip-components=1
./configure --prefix=$INSTALL_DIR --disable-shared --enable-static && make -j $PROCESSOR_COUNT && make install
cd $BUILD_DIR
test -f $INSTALL_DIR/include/proj_api.h

mkdir -p $BUILD_DIR/cgal
cd $BUILD_DIR/cgal
wget -O $BUILD_DIR/cgal.tar.xz $CGAL
tar xf $BUILD_DIR/cgal.tar.xz -C $BUILD_DIR/cgal --strip-components=1
cmake -DBUILD_SHARED_LIBS=OFF . && make -j $PROCESSOR_COUNT && make install
cd $BUILD_DIR
test -d $INSTALL_DIR/lib/CGAL

sfcgal_config=$INSTALL_DIR/bin/sfcgal-config
mkdir -p $BUILD_DIR/sfcgal
cd $BUILD_DIR/sfcgal
wget -O $BUILD_DIR/sfcgal.tar.gz $SFCGAL
tar xf $BUILD_DIR/sfcgal.tar.gz -C $BUILD_DIR/sfcgal --strip-components=1
cmake -DSFCGAL_USE_STATIC_LIBS=ON . && make -j $PROCESSOR_COUNT && make install
cd $BUILD_DIR
test -x $sfcgal_config

mkdir -p $BUILD_DIR/postgis
cd $BUILD_DIR/postgis
wget -O $BUILD_DIR/postgis.tar.gz $POSTGIS
tar xf $BUILD_DIR/postgis.tar.gz -C $BUILD_DIR/postgis --strip-components=1
./configure --with-geosconfig=$INSTALL_DIR/bin/geos-config --with-gdalconfig=$INSTALL_DIR/bin/gdal-config --with-sfcgal=$sfcgal_config --with-projdir=$INSTALL_DIR --with-raster --with-topology && make
cd $BUILD_DIR/postgis/extensions/postgis
make -j $PROCESSOR_COUNT && make install
cd $BUILD_DIR/postgis/extensions/postgis_topology
make -j $PROCESSOR_COUNT && make install
cd $BUILD_DIR/postgis
make install
cd $BUILD_DIR
ldconfig

cd /
rm -rf $BUILD_DIR
