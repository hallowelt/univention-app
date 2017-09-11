#!/bin/sh
# upgrade bluespice free docker container to bluespice pro
# use git to track changes, revert possible after test period

bluespice-backup-free.sh

#download bluespice from hallowelt server before running this script, put into /data/ directory ...
#...
#install bluespice pro and save snapshot
if [ -f ${BLUESPICE_CONFIG_PATH}/bluespice.zip ]; then
  cp ${BLUESPICE_CONFIG_PATH}/bluespice.zip /tmp/; cd /tmp; unzip bluespice.zip; rm bluespice.zip
fi
if [ -d /tmp/bluespice-pro/ ]; then
  rsync -a /tmp/bluespice-pro/ $BLUESPICE_WEBROOT
  rm /tmp/bluespice-pro/ -R
  cd $BLUESPICE_WEBROOT

  #update data and webservices
  find $BLUESPICE_WEBROOT -name '*.war' -exec mv {} /var/lib/tomcat8/webapps/ \;
  php ${BLUESPICE_WEBROOT}/maintenance/update.php --quick
  php ${BLUESPICE_WEBROOT}/maintenance/rebuildall.php
  chown www-data:www-data ${BLUESPICE_WEBROOT} -R

  git checkout -B bluespice_pro && git add -A && git commit -m 'bluespice pro'

  #cronjobs ...

fi
