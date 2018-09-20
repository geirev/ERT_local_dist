#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/ecl/macros:/home/geve/bin
export PYTHONPATH=/usr/lib/python2.7/dist-packages:/usr/lib/python2.7
export LD_LIBRARY_PATH=/usr/local/lib


PREFIX=/usr/local
INSTALL=/usr/local
MODULES=/usr/local/share/cmake/Modules

pip_inst=0
pymake_inst=0
libecl_inst=0
libres_inst=0
ert_inst=0
site_inst=1


# pip.install
if [[ $pip_inst -eq 1 ]]
then
   sudo apt-get install python-pip python-dev build-essential 
   sudo pip install --upgrade pip 
   sudo pip install --upgrade virtualenv
   sudo pip install requests
   sudo pip install yaml
fi


# pymake.install
if [[ $pymake_inst -eq 1 ]]
then
   if [[ -r pycmake ]]
   then
      pushd pycmake
      git fetch origin
   else
      git clone https://github.com/Statoil/pycmake.git
      pushd pycmake
      mkdir build
   fi
   cd build
   cmake ..
   sudo make install
   popd
fi


# libecl.install
#option( BUILD_TESTS         "Should the tests be built"                               OFF)
#option( BUILD_APPLICATIONS  "Should we build small utility applications"              OFF)
#option( BUILD_ECL_SUMMARY   "Build the commandline application ecl_summary"           OFF)
#option( BUILD_PYTHON        "Run py_compile on the python wrappers"                   OFF)
#option( ENABLE_PYTHON       "Build and install the Python wrappers"                   OFF)
#option( BUILD_SHARED_LIBS   "Build shared libraries"                                  ON )
#option( ERT_USE_OPENMP      "Use OpenMP"                                              OFF )
#option( RST_DOC             "Build RST documentation"                                 OFF)
#option( ERT_BUILD_CXX       "Build some CXX wrappers"                                 ON)
#option( USE_RPATH           "Don't strip RPATH from libraries and binaries"           OFF)
#option( INSTALL_ERT_LEGACY  "Add ert legacy wrappers"                                 OFF)
if [[ $libecl_inst -eq 1 ]]
then
   if [ -r libecl ]
   then
      rm -rf libecl
   fi
   git clone https://github.com/Statoil/libecl
   pushd libecl
   sudo pip install -r requirements.txt
   mkdir build
   cd build
   cmake .. -DENABLE_PYTHON=ON \
            -DCMAKE_INSTALL_PREFIX=$INSTALL \
            -DCMAKE_MODULE_PATH=$INSTALL/share/cmake/Modules\
            -DBUILD_TESTS=ON\
            -DBUILD_APPLICATIONS=ON\
            -DBUILD_ECL_SUMMARY=ON\
            -DBUILD_PYTHON=ON\
            -DERT_USE_OPENMP=ON\
            -DUSE_RPATH=ON\
            -DINSTALL_ERT_LEGACY=ON

   make
   sudo make install
   popd
fi




# libres.install
#option( BUILD_APPLICATIONS  "Build some small - mostly stale  -applications" OFF)
#option( BUILD_TESTS         "Should the tests be built"             OFF)
#option( BUILD_PYTHON        "Run py_compile on the python wrappers" OFF)
#option( ENABLE_PYTHON       "Enable the python wrappers"            ON )
#option( RST_DOC             "Build RST documentation"               OFF)
#option( USE_RPATH           "Should we embed path to libraries"     ON )
#option( INSTALL_ERT_LEGACY  "Install legacy ert code"               OFF)
#option( ERT_LSF_SUBMIT_TEST "Build and run tests of LSF submit"     OFF)

if [[ $libres_inst -eq 1 ]]
then
   if [ -r libres ]
   then
      rm -rf libres
   fi
   git clone https://github.com/Statoil/libres
   pushd libres
   sudo pip install -r requirements.txt
   mkdir build
   cd build
   cmake .. -DENABLE_PYTHON=ON \
            -DCMAKE_INSTALL_PREFIX=$INSTALL \
            -DCMAKE_MODULE_PATH=$INSTALL/share/cmake/Modules\
            -DBUILD_TESTS=ON\
            -DINSTALL_ERT_LEGACY=ON
   make
   sudo make install
   popd
fi


if [[ $ert_inst -eq 1 ]]
then
   if [ -r ert ]
   then
      rm -rf ert
   fi
#   sudo apt-get install python-qt4
   git clone https://github.com/Statoil/ert

   pushd ert
   sudo pip install -r requirements.txt
   mkdir build
   cd build
   cmake .. -DCMAKE_INSTALL_PREFIX=$INSTALL \
            -DBUILD_TESTS=ON\
            -DCMAKE_MODULE_PATH=$INSTALL/share/cmake/Modules
   make
   sudo make install
   popd
fi

if [[ $site_inst -eq 1 ]]
then
   sudo cp ERTshared/site-config $INSTALL/share
   sudo cp ERTshared/site-config $INSTALL/lib/python2.7/dist-packages/res/fm/ecl
   sudo mkdir $INSTALL/share/bin
   sudo cp ERTshared/bin/* $INSTALL/share/bin
   sudo mkdir $INSTALL/share/config/jobs
   sudo cp ERTshared/config/jobs/* $INSTALL/share/config/jobs
   pushd $INSTALL/share/config/jobs
   for i in *
   do
       sudo sed -i 's_INSTALL_/usr/local_g' $i
   done
   popd
fi


echo "To install torque follow instructions from:"
echo "https://jabriffa.wordpress.com/2015/02/11/installing-torquepbs-job-scheduler-on-ubuntu-14-04-lts/"
