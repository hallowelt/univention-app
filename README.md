# BlueSpice Mediawiki Docker Image

Full installed BlueSpice Free with webservices (tomcat), using external mysql/mariadb and external data storage. Create bluespice and mediawiki installation within minutes.

Replace Database Settings and mount points as needed for your environement.
```
docker run -it  -p 8081:80 \
 -e "DB_HOST=172.17.0.1" \
 -e "DB_NAME=mediawiki" \
 -e "DB_USER=mediawiki" \
 -e "DB_PASSWORD=my_secret" \
 -v /var/bluespice/:/var/bluespice \
 -v /etc/bluespice:/etc/bluespice \
bluespice/mediawiki
```

Replace "-it" with "-d" for daemon mode.

Point your Browser to http://localhost:8081/w to access the wiki

The installer creates the admin user "WikiSysop" with a random password which can be found in the file wikisysop_password.txt in your config directory (eg.: /etc/bluespice/wikisysop_password.txt).
