#!/bin/bash
path=$1
echo "openresty will be install in ${path}"
tar xvfz openresty-1.15.8.1.tar.gz
cd openresty-1.15.8.1
./configure --with-debug --prefix=${path}
make
make install
cd ..
