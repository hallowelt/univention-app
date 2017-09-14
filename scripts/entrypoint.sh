#!/usr/bin/env bash

service tomcat8 start
#sleep 5 #wait for tomcat service - solr
/usr/sbin/bluespice-install.sh
service memcached start
/usr/sbin/apache2ctl -D FOREGROUND
