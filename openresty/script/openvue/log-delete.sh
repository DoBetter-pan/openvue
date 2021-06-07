#!/bin/bash

dateStr=` date -d "-2 day" "+%Y-%m-%d" `
#dateStr=` date -d "-5 day" "+%Y%m%d" `
dirpath="/opt/openresty/openvue/logs/openvue_access/"
rm -f ${dirpath}*${dateStr}*
