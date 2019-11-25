#!/usr/bin/env bash

chmod o+r /etc/machine.secret

echo "SetEnv DB_NAME ${DB_NAME}" >> /etc/apache2/conf-available/setenv.conf
echo "SetEnv DB_PASSWORD ${DB_PASSWORD}" >> /etc/apache2/conf-available/setenv.conf
echo "SetEnv DB_PORT ${DB_PORT}" >> /etc/apache2/conf-available/setenv.conf
echo "SetEnv DB_USER ${DB_USER}" >> /etc/apache2/conf-available/setenv.conf
echo "SetEnv LDAP_BASE ${LDAP_BASE}" >> /etc/apache2/conf-available/setenv.conf
echo "SetEnv LDAP_HOSTDN ${LDAP_HOSTDN}" >> /etc/apache2/conf-available/setenv.conf
echo "SetEnv LDAP_MASTER ${LDAP_MASTER}" >> /etc/apache2/conf-available/setenv.conf
echo "SetEnv LDAP_MASTER_PORT ${LDAP_MASTER_PORT}" >> /etc/apache2/conf-available/setenv.conf
echo "SetEnv LDAP_SERVER_IP ${LDAP_SERVER_IP}" >> /etc/apache2/conf-available/setenv.conf
echo "SetEnv LDAP_SERVER_NAME ${LDAP_SERVER_NAME}" >> /etc/apache2/conf-available/setenv.conf
echo "SetEnv LDAP_SERVER_PORT ${LDAP_SERVER_PORT}" >> /etc/apache2/conf-available/setenv.conf
echo "SetEnv LOCALE_DEFAULT ${LOCALE_DEFAULT}" >> /etc/apache2/conf-available/setenv.conf

a2enconf setenv

# SET CA CERT
cat /etc/univention/ssl/ucsCA/CAcert.pem > /opt/ca/ca.crt

# START ELASTICSEARCH
service elasticsearch start

# START JETTY
service jetty9 start

# START MEMCACHED
service memcached start

# START PARSOID
screen -dmS Parsoid /usr/local/bin/start_parsoid

# START APACHE2
service apache2 start



fileLocalSettings="${BLUESPICE_CONFIG_PATH}/LocalSettings.php"
fileWikiSysopPass="${BLUESPICE_CONFIG_PATH}/wikisysop_password.txt"

mkdir -p ${BLUESPICE_DATA_PATH}/cache
mkdir -p ${BLUESPICE_DATA_PATH}/images
mkdir -p ${BLUESPICE_DATA_PATH}/data
mkdir -p ${BLUESPICE_DATA_PATH}/config
mkdir -p ${BLUESPICE_DATA_PATH}/compiled_templates

#if [ ! -f $fileLocalSettings ]; then
  if [ ! -f $fileWikiSysopPass ]; then
    WIKI_ADMIN_PASS=$(openssl rand -base64 32)
    echo $WIKI_ADMIN_PASS > $fileWikiSysopPass
  else
    WIKI_ADMIN_PASS=$( cat $fileWikiSysopPass )
  fi

  cd "$BLUESPICE_WEBROOT"; php maintenance/install.php --dbserver "$DB_HOST" --dbport "$DB_PORT" --dbname "$DB_NAME" --dbuser "$DB_USER" --dbpass "$DB_PASSWORD" --pass "$WIKI_ADMIN_PASS" --scriptpath /bluespice "$WIKI_NAME" "$WIKI_ADMIN"

  #post install
  if [ -f ${BLUESPICE_WEBROOT}/LocalSettings.php ]; then

	cp ${BLUESPICE_WEBROOT}/extensions/BlueSpiceFoundation/config.template/* ${BLUESPICE_DATA_PATH}/config/.
    cp ${BLUESPICE_WEBROOT}/extensions/BlueSpiceFoundation/data.template/* ${BLUESPICE_DATA_PATH}/data/.
    cp ${BLUESPICE_WEBROOT}/images/* ${BLUESPICE_DATA_PATH}/images/.

	rm -rf ${BLUESPICE_WEBROOT}/cache
	rm -rf ${BLUESPICE_WEBROOT}/images
	rm -rf ${BLUESPICE_WEBROOT}/extensions/BlueSpiceFoundation/data
	rm -rf ${BLUESPICE_WEBROOT}/extensions/BlueSpiceFoundation/config
	rm -rf ${BLUESPICE_WEBROOT}/extensions/Widgets/compiled_templates

    mv ${BLUESPICE_WEBROOT}/LocalSettings.php $fileLocalSettings

  else
    echo "Error occured: installation not successfull, LocalSettings.php is missing"
  fi
#fi

ln -s $fileLocalSettings ${BLUESPICE_WEBROOT}/LocalSettings.php

ln -s ${BLUESPICE_DATA_PATH}/cache ${BLUESPICE_WEBROOT}/cache
ln -s ${BLUESPICE_DATA_PATH}/images ${BLUESPICE_WEBROOT}/images
ln -s ${BLUESPICE_DATA_PATH}/data ${BLUESPICE_WEBROOT}/extensions/BlueSpiceFoundation/data
ln -s ${BLUESPICE_DATA_PATH}/config ${BLUESPICE_WEBROOT}/extensions/BlueSpiceFoundation/config
ln -s ${BLUESPICE_DATA_PATH}/compiled_templates ${BLUESPICE_WEBROOT}/extensions/Widgets/compiled_templates


# ACTIVATE EXTENDEDSEARCH
sed -i 's/return;//g' ${BLUESPICE_WEBROOT}/settings.d/020-BlueSpiceExtendedSearch.php
sed -i 's/return;//g' ${BLUESPICE_WEBROOT}/settings.d/020-VisualEditor.php
sed -i 's/return;//g' ${BLUESPICE_WEBROOT}/settings.d/020-BlueSpiceVisualEditorConnector.php


php ${BLUESPICE_WEBROOT}/maintenance/update.php --quick

echo "Changing permissions..."
setWikiPerm ${BLUESPICE_WEBROOT}
echo "done"

php ${BLUESPICE_WEBROOT}/extensions/BlueSpiceExtendedSearch/maintenance/purgeIndexes.php --quick
php ${BLUESPICE_WEBROOT}/extensions/BlueSpiceExtendedSearch/maintenance/initBackends.php --quick
php ${BLUESPICE_WEBROOT}/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick
php ${BLUESPICE_WEBROOT}/extensions/BlueSpiceExtendedSearch/maintenance/rebuildIndex.php --quick


while [ true ]; do
	sleep 3600
done
