#!/usr/bin/env bash

service tomcat8 start
/usr/sbin/bluespice-install.sh
service memcached start
/usr/sbin/apache2ctl -D FOREGROUND
