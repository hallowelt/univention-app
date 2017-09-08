#!/bin/sh
WIKI_BASE_PATH="/var/www/html/bluespice"
cd $WIKI_BASE_PATH; git checkout bluespice_free
php ${WIKI_BASE_PATH}/maintenance/update.php --quick
php ${WIKI_BASE_PATH}/maintenance/rebuildall.php
chown www-data:www-data ${WIKI_BASE_PATH} -R
