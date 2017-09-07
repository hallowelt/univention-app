# bluespice-all-in

Full installed BlueSpice Free with webservices (tomcat), using external mysql/mariadb and external data storage. Create bluespice installation within minutes.

Replace Database Settings and mount points as needed for your environement.
```
docker run -it  -p 8081:80 \
 -e "DB_HOST=172.17.0.1" \
 -e "DB_NAME=bluespice_all_in" \
 -e "DB_USER=bluespice_all_in" \
 -e "DB_PASSWORD=w893bzrnhsc" \
 -v /var/mediawiki/data:/data \
 -v /var/mediawiki/images:/var/www/html/w/images \
 -v /var/mediawiki/cache:/var/www/html/w/cache \
 -v /var/mediawiki/extensions/BlueSpiceFoundation/config:/var/www/html/w/extensions/BlueSpiceFoundation/config \
 -v /var/mediawiki/extensions/BlueSpiceFoundation/data:/var/www/html/w/extensions/BlueSpiceFoundation/data \
ljonka/bluespice-all-in
```

Replace "-it" with "-d" for daemon mode.

Point your Browser to http://localhost:8081/w to access the wiki

The installer creates the admin user "WikiSysop" with a random password which can be found in the file wikisysop_password.txt in your /data directory (eg.: /var/mediawiki/data/wikisysop_password.txt).
