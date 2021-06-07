#!/bin/bash

bashpath=`pwd`
workdir="/opt/openresty/openvue"
cd $bashpath
#git pull
echo "update...."
if [ ! -d ${workdir} ]; then
    mkdir -p ${workdir}
fi
./bin/install.sh
echo "copy...."
sed -i "s/listen 80;/listen 7654;/g" ${workdir}/conf/openvue.conf

#web
cp $bashpath/vueelement/dist ${workdir}/html/openvue -fr

echo "switch to test mode...."
./bin/openvue.sh reload
#service adxproxy reload
#service adxproxy reload
echo "reload...."
