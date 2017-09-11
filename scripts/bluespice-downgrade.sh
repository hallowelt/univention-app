#!/bin/sh

cd $BLUESPICE_WEBROOT
git checkout `git log --pretty=oneline | tail -1 | sed 's/ .*$//'`
php ${BLUESPICE_WEBROOT}/maintenance/update.php --quick
php ${BLUESPICE_WEBROOT}/maintenance/rebuildall.php
chown www-data:www-data ${BLUESPICE_WEBROOT} -R
