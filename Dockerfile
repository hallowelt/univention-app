FROM debian:stretch

RUN apt-get update && apt-get -y install apache2

RUN apt-get update && apt-get -y install php7.0 php7.0-mysql php7.0-mbstring php7.0-json php7.0-curl php7.0-xml php7.0-gd php7.0-tidy php7.0-intl curl apache2-mod-php7.0

RUN apt-get update && apt-get -y install tomcat8

RUN apt-get -y install unzip rsync

RUN apt-get -y install git-core

RUN apt-get -y install cron

RUN apt-get install -y python memcached

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY files/* /tmp/

ENV BLUESPICE_WEBROOT="/var/www/html/bluespice"
ENV BLUESPICE_CONFIG_PATH="/etc/bluespice"

RUN cd /tmp && tar xzvf mediawiki.tar.gz && mv mediawiki-1.27.3/ ${BLUESPICE_WEBROOT}
RUN cd /tmp && unzip bluespice.zip && rsync -a bluespice-free/ ${BLUESPICE_WEBROOT} && rm bluespice-free/ -Rf
RUN cd /tmp && rm bluespice.zip mediawiki.tar.gz
RUN find ${BLUESPICE_WEBROOT}/ -name '*.war' -exec mv {} /var/lib/tomcat8/webapps/ \;
RUN mkdir /opt/bluespice/ && mv ${BLUESPICE_WEBROOT}/extensions/BlueSpiceExtensions/ExtendedSearch/webservices/solr/ /opt/bluespice/
RUN cp /opt/bluespice/solr/bluespice/conf/lang/stopwords_de.txt /opt/bluespice/solr/bluespice/conf/stopwords.txt
RUN chown -R tomcat8:tomcat8 /opt/bluespice/solr/
RUN echo "JAVA_OPTS=\"\${JAVA_OPTS} -Dsolr.solr.home=/opt/bluespice/solr\"" >> /etc/default/tomcat8

COPY configs/etc/memcached.conf /etc/memcached.conf
COPY configs/etc/tomcat8/context.xml /etc/tomcat8/context.xml
COPY configs/etc/tomcat8/server.xml /etc/tomcat8/server.xml
COPY configs/etc/php/7.0/apache2/php.ini /etc/php/7.0/apache2/php.ini
COPY configs${BLUESPICE_WEBROOT}/.gitignore ${BLUESPICE_WEBROOT}/.gitignore
COPY configs${BLUESPICE_WEBROOT}/settings.d/005-Memcached.php ${BLUESPICE_WEBROOT}/settings.d/005-Memcached.php
COPY scripts/* /usr/sbin/

RUN mkdir /root/cronjobs
COPY cronjobs/* /root/cronjobs/
RUN crontab /root/cronjobs/runJobs.txt

#mysql data
ENV DB_HOST=""
ENV DB_PORT="3306"
ENV DB_NAME=""
ENV DB_USER=""
ENV DB_PASSWORD=""
#installation data
ENV WIKI_NAME="BlueSpice MediaWiki"
ENV WIKI_ADMIN="WikiSysop"

VOLUME ${BLUESPICE_CONFIG_PATH} ${BLUESPICE_WEBROOT}/images ${BLUESPICE_WEBROOT}/cache ${BLUESPICE_WEBROOT}/extensions/BlueSpiceFoundation/data ${BLUESPICE_WEBROOT}/extensions/BlueSpiceFoundation/config
EXPOSE 80
EXPOSE 8080

ENTRYPOINT /usr/sbin/entrypoint.sh
