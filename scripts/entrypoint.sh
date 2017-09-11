#!/usr/bin/env bash

/usr/sbin/bluespice-install.sh; \
service tomcat8 start; \
service memcached start; \
/usr/sbin/apache2ctl -D FOREGROUND
