#!/bin/bash

while :
do
   mysql \
     -h docker-v5.hung.org.hk -P 3306 -D test \
     -u john -p'passw0rd' -e 'source /root/mysql/traffic.sql'
  sleep 1
done
