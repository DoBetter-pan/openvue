#!/bin/bash

cd /opt/openresty/openvue/logs/
time=$(date -d "-1 hour" +"%Y-%m-%d-%H")
#time=$(date -d "-10 min" +"%Y-%m-%d-%H-%M")

logs=`ls *.log`
for log in $logs
do
   mv $log $log.$time
done
kill -USR1 `cat /opt/openresty/openvue/logs/openvue.pid`
