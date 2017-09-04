#!/bin/sh
service tomcat8 start

fileLocalSettings="/data/LocalSettings.php"
basePath="/var/www/html/w/"
if [ ! -f "$fileLocalSettings" ]; then
  chown www-data:www-data ${basePath} -R
  WIKI_ADMIN_PASS=$(openssl rand -base64 32)
  echo "$WIKI_ADMIN_PASS" > /data/wikisysop_password.txt
  cd "$basePath"; php maintenance/install.php --dbserver "$MYSQL_HOST" --dbport "$MYSQL_PORT" --dbname "$MYSQL_DB" --dbuser "$MYSQL_USER" --dbpass "$MYSQL_PASS" --pass "$WIKI_ADMIN_PASS" --scriptpath /w "$WIKI_NAME" "$WIKI_ADMIN"
  mv ${basePath}/LocalSettings.php /data/LocalSettings.php
  ln -s /data/LocalSettings.php ${basePath}/LocalSettings.php

  echo "require \"\$IP/LocalSettings.BlueSpice.php\";" >> /var/www/html/w/LocalSettings.php
  echo "wfLoadExtension('BlueSpiceExtensions/ExtendedSearch');" >> /var/www/html/w/LocalSettings.php
  echo "wfLoadExtension('BlueSpiceExtensions/UniversalExport');" >> /var/www/html/w/LocalSettings.php
  echo "wfLoadExtension('BlueSpiceExtensions/UEModulePDF');" >> /var/www/html/w/LocalSettings.php

  php ${basePath}/maintenance/update.php --quick
  php ${basePath}/extensions/BlueSpiceExtensions/ExtendedSearch/maintenance/searchUpdate.php
else
  ln -s /data/LocalSettings.php ${basePath}/LocalSettings.php
fi

chown www-data:www-data ${basePath} -R

/usr/sbin/apache2ctl -D FOREGROUND
