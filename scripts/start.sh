#!/bin/sh
service tomcat8 start
service memcached start

fileLocalSettings="/data/LocalSettings.php"
basePath="/var/www/html/bluespice/"
if [ ! -f "$fileLocalSettings" ]; then
  chown www-data:www-data ${basePath} -R
  WIKI_ADMIN_PASS=$(openssl rand -base64 32)
  echo "$WIKI_ADMIN_PASS" > /data/wikisysop_password.txt
  cd "$basePath"; php maintenance/install.php --dbserver "$DB_HOST" --dbport "$DB_PORT" --dbname "$DB_NAME" --dbuser "$DB_USER" --dbpass "$DB_PASSWORD" --pass "$WIKI_ADMIN_PASS" --scriptpath /bluespice "$WIKI_NAME" "$WIKI_ADMIN"

  #post install
  if [ -f "$fileLocalSettings" ]; then
    mv ${basePath}/LocalSettings.php /data/LocalSettings.php
    ln -s /data/LocalSettings.php ${basePath}/LocalSettings.php

    echo "require \"\$IP/LocalSettings.BlueSpice.php\";" >> ${basePath}/LocalSettings.php
    echo "wfLoadExtension('BlueSpiceExtensions/ExtendedSearch');" >> ${basePath}/LocalSettings.php
    echo "wfLoadExtension('BlueSpiceExtensions/UniversalExport');" >> ${basePath}/LocalSettings.php
    echo "wfLoadExtension('BlueSpiceExtensions/UEModulePDF');" >> ${basePath}/LocalSettings.php
  else
    echo "Error occured: installation not successfull, LocalSettings.php is missing"
  fi

else
  ln -s /data/LocalSettings.php ${basePath}/LocalSettings.php
fi

php ${basePath}/maintenance/update.php --quick
php ${basePath}/extensions/BlueSpiceExtensions/ExtendedSearch/maintenance/searchUpdate.php

chown www-data:www-data ${basePath} -R

/usr/sbin/apache2ctl -D FOREGROUND
