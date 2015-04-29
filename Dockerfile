FROM postgres:9.4
MAINTAINER F4<contact@f4-group.com>

###Versions

#from http://postgis.net/source
ENV POSTGIS_VERSION=2.1.7
ENV POSTGIS http://download.osgeo.org/postgis/source/postgis-$POSTGIS_VERSION.tar.gz

#from http://trac.osgeo.org/geos/
ENV GEOS http://download.osgeo.org/geos/geos-3.4.2.tar.bz2
#from http://trac.osgeo.org/gdal/wiki/DownloadSource
ENV GDAL http://download.osgeo.org/gdal/1.11.2/gdal-1.11.2.tar.gz
#from https://trac.osgeo.org/proj/
ENV PROJ http://download.osgeo.org/proj/proj-4.9.1.tar.gz
#from https://gforge.inria.fr/frs/?group_id=52
ENV CGAL https://gforge.inria.fr/frs/download.php/34705/CGAL-4.6.tar.xz
#from https://github.com/Oslandia/SFCGAL/releases
ENV SFCGAL https://github.com/Oslandia/SFCGAL/archive/v1.1.0.tar.gz

#TODO make PROCESSOR_COUNT dynamic
#built by docker.io, so reducing to 1. increase to match build server processor count as needed
ENV PROCESSOR_COUNT 1

##Installation

RUN apt-get -y update

# postgis required packages
# PG_MAJOR from parent container
RUN apt-get -y install build-essential postgresql-server-dev-$PG_MAJOR libxml2-dev libjson0-dev

#lib building packages
RUN apt-get -y install cmake libboost-dev libgmp-dev libmpfr-dev libboost-thread-dev libboost-system-dev

WORKDIR /install-postgis

WORKDIR /install-postgis/geos
ADD $GEOS /install-postgis/geos.tar.bz2
RUN tar xf /install-postgis/geos.tar.bz2 -C /install-postgis/geos --strip-components=1
RUN ./configure && make -j $PROCESSOR_COUNT && make install
RUN ldconfig
WORKDIR /install-postgis
RUN test -x geos

WORKDIR /install-postgis/gdal
ADD $GDAL /install-postgis/gdal.tar.gz
RUN tar xf /install-postgis/gdal.tar.gz -C /install-postgis/gdal --strip-components=1
RUN ./configure --with-geos=$geos_config && make -j $PROCESSOR_COUNT && make install
RUN ldconfig
WORKDIR /install-postgis
RUN test -x gdal

WORKDIR /install-postgis/proj
ADD $PROJ /install-postgis/proj.tar.gz
RUN tar xf /install-postgis/proj.tar.gz -C /install-postgis/proj --strip-components=1
RUN ./configure && make -j $PROCESSOR_COUNT && make install
WORKDIR /install-postgis
RUN test -f /usr/local/include/proj_api.h

WORKDIR /install-postgis/cgal
ADD $CGAL /install-postgis/cgal.tar.xz
RUN tar xf /install-postgis/cgal.tar.xz -C /install-postgis/cgal --strip-components=1
RUN cmake . && make -j $PROCESSOR_COUNT && make install
WORKDIR /install-postgis
RUN test -d /usr/local/lib/CGAL

WORKDIR /install-postgis/sfcgal
ADD $SFCGAL /install-postgis/sfcgal.tar.gz
RUN tar xf /install-postgis/sfcgal.tar.gz -C /install-postgis/sfcgal --strip-components=1
RUN cmake . && make -j $PROCESSOR_COUNT && make install
WORKDIR /install-postgis
RUN test -x $sfcgal_config

WORKDIR /install-postgis/postgis
ADD $POSTGIS /install-postgis/postgis.tar.gz
RUN tar xf /install-postgis/postgis.tar.gz -C /install-postgis/postgis --strip-components=1
RUN ./configure --with-geosconfig=/usr/local/bin/geos-config --with-gdalconfig=/usr/local/bin/gdal-config --with-sfcgal=/usr/local/bin/sfcgal-config --with-projdir=/usr/local --with-raster --with-topology && make
WORKDIR /install-postgis/postgis/extensions/postgis
RUN make -j $PROCESSOR_COUNT && make install
WORKDIR /install-postgis/postgis/extensions/postgis_topology
RUN make -j $PROCESSOR_COUNT && make install
WORKDIR /install-postgis/postgis
RUN make install
WORKDIR /install-postgis
RUN ldconfig

WORKDIR /
RUN rm -rf /install-postgis