#!/bin/sh

if [ -f $BLUESPICE_FREE_BACKUPFILE ]; then
  rm $BLUESPICE_WEBROOT
  tar xzvf $BLUESPICE_FREE_BACKUPFILE -C $BLUESPICE_WEBROOT
  rm $BLUESPICE_FREE_BACKUPFILE
  php ${BLUESPICE_WEBROOT}/maintenance/update.php --quick
  php ${BLUESPICE_WEBROOT}/maintenance/rebuildall.php
  chown www-data:www-data ${BLUESPICE_WEBROOT} -R
fi
