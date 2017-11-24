#!/usr/bin/env bash

nohup sh /usr/sbin/bluespice-up-down-jobs.sh > /dev/null 2>&1 &
npm install -g forever
forever start $BLUESPICE_WEBROOT/extensions/BlueSpiceUpgradeHelper/webservices/UpgradeHelper/index.js

service cron start
service tomcat8 start
/usr/sbin/bluespice-install.sh
service memcached start
/usr/sbin/apache2ctl -D FOREGROUND
