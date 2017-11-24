# univention-app-image

Full installed BlueSpice Free with webservices (tomcat), using external mysql/mariadb and external data storage. Create bluespice and mediawiki installation within minutes.

Replace Database Settings and mount points as needed for your environement.
```
docker run -it  -p 8081:80 \
 -e DB_HOST=$(/sbin/ifconfig docker0 | grep 'inet Adresse' | cut -d: -f2 | awk '{print $1}') \
 -e DB_NAME=$(cat /etc/bluespice/mysql_dbname.txt) \
 -e DB_USER=$(cat /etc/bluespice/mysql_dbuser.txt) \
 -e DB_PASSWORD=$(cat /etc/bluespice/mysql_dbpwd.txt)
	-v /var/bluespice/:/var/bluespice \
	-v /etc/bluespice:/etc/bluespice \
bluespice/univention-app-image:2.27.2
```

Replace "-it" with "-d" for daemon mode.

The installer creates the admin user "WikiSysop" with a random password which can be found in the file wikisysop_password.txt in your /etc/bluespice directory (eg.: /etc/bluespice/wikisysop_password.txt).

Point your Browser to http://localhost:8081/bluespice to access the wiki
