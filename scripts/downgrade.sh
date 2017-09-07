#!/bin/sh
WIKI_BASE_PATH="/var/www/html/w"
cd $WIKI_BASE_PATH; git checkout master
php ${WIKI_BASE_PATH}/maintenance/update.php --quick
