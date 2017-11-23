#!/bin/sh

#lookup last backup files: webroot, keep new files and db,
#you know, in case of emergency, db and files are also there for manual restore ;-)

touch $BLUESPICE_CONFIG_PATH/do_downgrade.task
# now: get backup of free version while this is call for downgrade
LAST_FREE_BACKUP=`find $BLUESPICE_DATA_PATH/backup -name bluespice_webroot_* 2>/dev/null | sort -n | tail -1`

if [ -n "$LAST_FREE_BACKUP" ] && [ -f $LAST_FREE_BACKUP ]; then
  {
    rm -R $BLUESPICE_WEBROOT
    mkdir $BLUESPICE_WEBROOT
    unzip $LAST_FREE_BACKUP -d $BLUESPICE_WEBROOT
    php ${BLUESPICE_WEBROOT}/maintenance/update.php --quick
    php ${BLUESPICE_WEBROOT}/maintenance/rebuildall.php
    chown www-data:www-data ${BLUESPICE_WEBROOT} -R
  } || {
    echo "Error while installing backup file" > $BLUESPICE_CONFIG_PATH/$BLUESPICE_DOWNGRADE_ERRORFILE
				touch $BLUESPICE_CONFIG_PATH/do_downgrade.error
  }
else
  echo "Error: no Backup file found" > $BLUESPICE_CONFIG_PATH/$BLUESPICE_DOWNGRADE_ERRORFILE
		touch $BLUESPICE_CONFIG_PATH/do_downgrade.error
fi
rm $BLUESPICE_CONFIG_PATH/do_downgrade.task
