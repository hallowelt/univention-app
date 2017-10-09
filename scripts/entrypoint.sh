#!/usr/bin/env bash

nohup sh /usr/sbin/bluespice-up-down-jobs.sh > /dev/null 2>&1 &

service cron start
service tomcat8 start
#sleep 5 #wait for tomcat service - solr
/usr/sbin/bluespice-install.sh
service memcached start
/usr/sbin/apache2ctl -D FOREGROUND
