#!/bin/bash

while :
do
   mysql \
     -h 192.168.28.134 -P 3306 -D test \
     -u john -p'passw0rd' -e 'source /root/mysql/traffic.sql'
  sleep 1
done
