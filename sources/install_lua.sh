#!/bin/bash
path=$1
echo "lua will be install in ${path}"
tar xvfz lua-5.1.4.tar.gz
cd lua-5.1.4
#yum install readline-devel
mkdir -p /opt/openresty/lua
make linux install INSTALL_TOP=/opt/openresty/lua
cd ..

#tar xvfz luarocks-2.2.2.tar.gz
#cd luarocks-2.2.2
#./configure --prefix=/opt/openresty/luarocks  --with-lua=/opt/openresty/lua
#make build
#make install
#cd ..

#tar xvfz busted.tar.gz
#cd busted
#/opt/openresty/luarocks/bin/luarocks make
#cd ..

#/opt/openresty/luarocks/bin/luarocks install luacov
