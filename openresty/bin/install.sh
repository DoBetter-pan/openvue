#! /bin/bash

workdir="/opt/openresty/openvue"
openresty="/opt/openresty/nginx/sbin/nginx"

if [ ! -d ${workdir} ]; then
    mkdir -p ${workdir}
fi
cp conf ${workdir} -fr
cp script ${workdir} -fr
cp src ${workdir} -fr
cp bin ${workdir} -fr
cp tools ${workdir} -fr
cp data ${workdir} -fr
cp html ${workdir} -fr

#create log directories
if [ ! -d ${workdir}/logs/openvue_access ]; then
    mkdir -p ${workdir}/logs/openvue_access
fi

