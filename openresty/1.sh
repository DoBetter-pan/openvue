#!/bin/bash

curl -i -d @data/login.json 'http://192.168.1.7:7654/openservice/user/login'

curl -i 'http://192.168.1.7:7654/openservice/user/info?token=admin-token'
