#!/bin/bash
LIBS_PATH="/home/floodproofs/fp-libs/"

install_netcdf="FALSE"				#if they are already installed just specify the path 
PATH_NC="${LIBS_PATH}/libs_system/nc4"
PATH_HDF5="${LIBS_PATH}/libs_system/hdf5"
PATH_ZLIB="${LIBS_PATH}/libs_system/zlib"

CDO_INSTALL_PATH="${LIBS_PATH}/libs_system/"

#PATH_NC="$CDO_INSTALL_PATH/nc4_c-4.9.2"
PATH_PROJ5="$CDO_INSTALL_PATH/proj-5.2.0"
PATH_PROJ6="$CDO_INSTALL_PATH/proj-6.1.0"
PATH_ECCODES="$CDO_INSTALL_PATH/eccodes2.37.0"
PATH_CDO="$CDO_INSTALL_PATH/cdo-2.4.3_nc-4.9.2_hdf-1.8.17_eccodes-2.37.0"
PATH_JASPER="$CDO_INSTALL_PATH/jasper-2.0.14"

mkdir -p "$CDO_INSTALL_PATH"
cd $CDO_INSTALL_PATH
mkdir -p "$CDO_INSTALL_PATH/source"
######################## PREREQUISITES ########################
sudo apt-get install cmake
sudo apt-get install 7zip
sudo apt-get install libsqlite3-dev
sudo apt-get install pkg-config
sudo apt-get install libaec-dev
######################## INSTALL NETCDF4.6.1 ########################
if [[ $install_netcdf -eq "TRUE" ]]; then
mkdir -p $PATH_NC

cd source 
wget https://downloads.unidata.ucar.edu/netcdf-c/4.9.2/netcdf-c-4.9.2.tar.gz
tar -xzvf netcdf-c-4.9.2.tar.gz 
cd netcdf-c-4.9.2/

LDFLAGS="-L$PATH_HDF5/lib/ -L$PATH_ZLIB/lib/" CPPFLAGS="-I$PATH_HDF5/include/ -I$PATH_ZLIB/include/" ./configure --enable-netcdf-4 --enable-dap --enable-shared --prefix=$PATH_NC --disable-doxygen --disable-libxml2

make 
make install

cd $CDO_INSTALL_PATH
fi
######################## INSTALL PROJ 5.2.0 -- 6.1.0 ########################
mkdir -p $PATH_PROJ5

cd source
wget http://download.osgeo.org/proj/proj-5.2.0.tar.gz
wget http://download.osgeo.org/proj/proj-datumgrid-1.8.zip
 
# UNTAR AND USE PROJ 5.2.0 WITH PROJ_API (MUST USE WITH CDO 1.9.6)
tar xzf proj-5.2.0.tar.gz
cd proj-5.2.0/nad
7z x ../../proj-datumgrid-1.8.zip # file zip
cd ..
./configure --prefix=$PATH_PROJ5
make
make install

# UNTAR AND USE PROJ 6.1.0 WITHOUT PROJ_API (TROUBLES IN COMPILLING AGAINST OTHER LIBRARIES)
cd $CDO_INSTALL_PATH
mkdir -p $PATH_PROJ6
#
cd source
wget http://download.osgeo.org/proj/proj-6.1.0.tar.gz
tar xzf proj-6.1.0.tar.gz
cd proj-6.1.0/data
yes A | 7z x ../../proj-datumgrid-1.8.zip # file zip
cd ..

./configure --prefix=$PATH_PROJ6
make
make install
cd ..

cd $CDO_INSTALL_PATH
######################## INSTALL JASPER ########################
cd $CDO_INSTALL_PATH
mkdir -p $PATH_JASPER

cd source
wget https://www.ece.uvic.ca/~frodo/jasper/software/jasper-2.0.14.tar.gz
tar -xzvf jasper-2.0.14.tar.gz
mkdir -p $CDO_INSTALL_PATH/source/jasper-2.0.14-Build
cd $CDO_INSTALL_PATH/source/jasper-2.0.14-Build
cmake ../jasper-2.0.14 -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$PATH_JASPER
make 
make install

cd $CDO_INSTALL_PATH
######################## INSTALL ECCODES ########################
mkdir -p $PATH_ECCODES

cd source
wget https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.37.0-Source.tar.gz
tar xzf eccodes-2.37.0-Source.tar.gz
mkdir -p $CDO_INSTALL_PATH/source/eccodes-2.37.0-Build
cd $CDO_INSTALL_PATH/source/eccodes-2.37.0-Build

#export FCFLAGS="-w -fallow-argument-mismatch -O2" can be required for old systems
#export FFLAGS="-w -fallow-argument-mismatch -O2" can be required for old systems

cmake  ../eccodes-2.37.0-Source -DENABLE_NETCDF=ON -DNETCDF_PATH=$PATH_NC -DCMAKE_INSTALL_PREFIX=$PATH_ECCODES -DENABLE_JPG_LIBJASPER=ON

make
make install

#source activate fp_virtualenv_python3_basic
#pip install eccodes-python
#source deactivate
#exit

cd $CDO_INSTALL_PATH

######################## INSTALL CDO ########################
mkdir -p $PATH_CDO

cd source
wget https://code.mpimet.mpg.de/attachments/download/29616/cdo-2.4.3.tar.gz
tar -xvzf cdo-2.4.3.tar.gz
cd cdo-2.4.3

LDFLAGS=-Wl,-rpath,$PATH_ECCODES/lib/ ./configure CC=gcc CFLAGS="-g -O2 -fPIC" CXX=g++ CXXFLAGS="-g -O2" --prefix=$PATH_CDO --with-netcdf=$PATH_NC --with-jasper=$PATH_JASPER --with-hdf5=$PATH_HDF5 --with-eccodes=$PATH_ECCODES --with-proj=$PATH_PROJ5

make
make install

export PATH=$PATH_CDO/bin:$PATH

echo 'export PATH='$PATH_CDO'/bin:$PATH' >> ~/.bashrc 
#source activate fp_virtualenv_python3_basic
#pip install cdo
#source deactivate
