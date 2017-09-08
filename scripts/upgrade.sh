#!/bin/sh
# upgrade bluespice free docker container to bluespice pro
# use git to track changes, revert possible after test period
WIKI_BASE_PATH="/var/www/html/bluespice"

#download bluespice from hallowelt server before running this script, put into /data/ directory ...
#...
#install bluespice pro and save snapshot
if [ -f /data/bluespice.zip ]; then
  cp /data/bluespice.zip /tmp/; cd /tmp; unzip bluespice.zip
fi
if [ -d /tmp/bluespice-pro/ ]; then
  rsync -a /tmp/bluespice-pro/ $WIKI_BASE_PATH; rm /tmp/bluespice-pro/ -R
  cd $WIKI_BASE_PATH;
  git checkout -B bluespice_pro; git add -A; git commit -m 'bluespice pro'

  #update data and webservices
  find $WIKI_BASE_PATH -name '*.war' -exec mv {} /var/lib/tomcat8/webapps/ \;
  php ${WIKI_BASE_PATH}/maintenance/update.php --quick
  php ${WIKI_BASE_PATH}/maintenance/rebuildall.php
  chown www-data:www-data ${WIKI_BASE_PATH} -R

  #cronjobs ...

fi
