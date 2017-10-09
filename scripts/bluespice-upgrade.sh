#!/bin/sh
# upgrade bluespice free docker container to bluespice pro
# use git to track changes, revert possible after test period

bluespice-backup-free.sh

#download bluespice from hallowelt server before running this script, put into /data/ directory ...
#collect needed data:
if [ -f $BLUESPICE_CONFIG_PATH/$BLUESPICE_PRO_KEY_FILE ]; then
  TOKEN=$(cat $BLUESPICE_CONFIG_PATH/$BLUESPICE_PRO_KEY_FILE)
else
  TOKEN=""
fi

rm -f $BLUESPICE_PRO_FILE
curl --fail -i $BLUESPICE_AUTOSERVICE_URL -H "Authorization: Bearer $TOKEN" -o $BLUESPICE_PRO_FILE

#install bluespice pro and save snapshot
if [ -f $BLUESPICE_PRO_FILE  ] && [ -f $BLUESPICE_FREE_BACKUPFILE ]; then
  rm $BLUESPICE_WEBROOT
  tar xzvf $BLUESPICE_PRO_FILE -C $BLUESPICE_WEBROOT
  rm $BLUESPICE_PRO_FILE
  cd $BLUESPICE_WEBROOT

  #update data and webservices
  find $BLUESPICE_WEBROOT -name '*.war' -exec mv {} /var/lib/tomcat8/webapps/ \;
  php ${BLUESPICE_WEBROOT}/maintenance/update.php --quick
  php ${BLUESPICE_WEBROOT}/maintenance/rebuildall.php
  chown www-data:www-data ${BLUESPICE_WEBROOT} -R

  #cronjobs ...
fi
