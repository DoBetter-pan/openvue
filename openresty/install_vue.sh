#!/bin/bash

bashpath=`pwd`
cd $bashpath/vueelement
npm install
#npm run dev
#npm run build:stage
npm run build:prod

