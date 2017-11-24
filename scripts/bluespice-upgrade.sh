#!/bin/sh
# upgrade bluespice free docker container to bluespice pro

#download bluespice from hallowelt server before running this script, put into /data/ directory ...
#collect needed data:

#1. token available
touch $BLUESPICE_CONFIG_PATH/token_available.task
if [ -f $BLUESPICE_CONFIG_PATH/$BLUESPICE_PRO_KEY_FILE ]; then
  TOKEN=$(cat $BLUESPICE_CONFIG_PATH/$BLUESPICE_PRO_KEY_FILE)
		rm -f $BLUESPICE_CONFIG_PATH/token_available.error
else
  TOKEN=""
		touch $BLUESPICE_CONFIG_PATH/token_available.error
fi
rm $BLUESPICE_CONFIG_PATH/token_available.task

if [ -f $BLUESPICE_CONFIG_PATH/token_available.error ] ; then
  exit
fi

#2. token check
touch $BLUESPICE_CONFIG_PATH/token_check.task

token_status=$(curl -o -I -L -s -w %{http_code} -H "Authorization: Bearer $TOKEN" $BLUESPICE_AUTOSERVICE_URL_INFO)
if [ "$token_status" != "200" ]; then
	touch $BLUESPICE_CONFIG_PATH/token_check.error
else
	rm -f $BLUESPICE_CONFIG_PATH/token_check.error
fi
rm $BLUESPICE_CONFIG_PATH/token_check.task

if [ -f $BLUESPICE_CONFIG_PATH/token_check.error ] ; then
  exit
fi

#3. download
touch $BLUESPICE_CONFIG_PATH/download.task

# cleanup old files
rm -f $BLUESPICE_PRO_FILE
rm -f $BLUESPICE_CONFIG_PATH/$BLUESPICE_UPGRADE_ERRORFILE
curl --fail -o $BLUESPICE_PRO_FILE -H "Authorization: Bearer $TOKEN" $BLUESPICE_AUTOSERVICE_URL

if [ ! -f $BLUESPICE_PRO_FILE ]; then
  touch $BLUESPICE_CONFIG_PATH/download.error
	else
		rm -f $BLUESPICE_CONFIG_PATH/download.error
fi
rm $BLUESPICE_CONFIG_PATH/download.task

if [ -f $BLUESPICE_CONFIG_PATH/download.error ] ; then
  exit
fi

#4. backup
touch $BLUESPICE_CONFIG_PATH/backup.task
bluespice-backup-free.sh
rm $BLUESPICE_CONFIG_PATH/backup.task

#5. do_upgrade
touch $BLUESPICE_CONFIG_PATH/do_upgrade.task

#install bluespice pro and save snapshot
LOOKUP_BACKUP=`find $BLUESPICE_DATA_PATH/backup -name bluespice_* | wc -l`
if [ -f $BLUESPICE_PRO_FILE  ] && [ $LOOKUP_BACKUP -ge 3 ]; then
  {
    rm -Rf $BLUESPICE_WEBROOT
    mkdir $BLUESPICE_WEBROOT
    unzip $BLUESPICE_PRO_FILE -d $BLUESPICE_WEBROOT
    rm $BLUESPICE_PRO_FILE
    cd $BLUESPICE_WEBROOT

    fileLocalSettings="${BLUESPICE_CONFIG_PATH}/LocalSettings.php"
    ln -s $fileLocalSettings ${BLUESPICE_WEBROOT}/LocalSettings.php

    #remove bad things added from installer
    sed -i '/^wfLoadSkin/d' $fileLocalSettings

    #update data and webservices
    find $BLUESPICE_WEBROOT -name '*.war' -exec mv {} /var/lib/tomcat8/webapps/ \;
    php ${BLUESPICE_WEBROOT}/maintenance/update.php --quick
    php ${BLUESPICE_WEBROOT}/maintenance/rebuildall.php
    chown www-data:www-data ${BLUESPICE_WEBROOT} -R
  } || {
    #restore original if something went wrong
    touch $BLUESPICE_CONFIG_PATH/do_upgrade.error
    touch $BLUESPICE_CONFIG_PATH/$BLUESPICE_DOWNGRADE_JOBFILE
  }

  #cronjobs ...
else
  echo "Error: upgrade- or backup-file missing" > $BLUESPICE_CONFIG_PATH/$BLUESPICE_UPGRADE_ERRORFILE
fi

rm $BLUESPICE_CONFIG_PATH/do_upgrade.task
