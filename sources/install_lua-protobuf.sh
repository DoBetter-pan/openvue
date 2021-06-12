#!/bin/bash
path=$1
echo "lua-protobuf will be install in ${path}"
tar xvfz lua-protobuf-20190701.tar.gz
cd lua-protobuf-20190701
gcc -O2 -shared -fPIC pb.c -o pb.so -I${path}/luajit/include/luajit-2.1/ 
#gcc -O2 -shared -undefined dynamic_lookup pb.c -o pb.so -I${path}/luajit/include/luajit-2.1/ 
if [ -d ${path}/lualib ]; then
    cp pb.so ${path}/lualib
    cp protoc.lua ${path}/lualib
fi
cd ..
