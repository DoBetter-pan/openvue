#! /bin/bash

workdir="/opt/openresty/openvue"
openresty="/opt/openresty/nginx/sbin/nginx"

if [ ! -d ${workdir} ]; then
    mkdir -p ${workdir}
fi
cp -fr conf ${workdir}
cp -fr script ${workdir}
cp -fr src ${workdir}
cp -fr bin ${workdir}
cp -fr tools ${workdir}
cp -fr data ${workdir}
cp -fr html ${workdir}

#create log directories
if [ ! -d ${workdir}/logs/openvue_access ]; then
    mkdir -p ${workdir}/logs/openvue_access
fi

