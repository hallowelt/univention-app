FROM debian:stretch

RUN apt-get update && apt-get -y install apache2

RUN apt-get update && apt-get -y install php7.0 php7.0-mysql php7.0-mbstring php7.0-json php7.0-curl php7.0-xml php7.0-gd php7.0-tidy php7.0-intl php7.0-ldap curl apache2-mod-php7.0

RUN apt-get update && apt-get -y install tomcat8

RUN apt-get update && apt-get -y install unzip rsync zip

RUN apt-get update && apt-get -y install git-core

RUN apt-get update && apt-get -y install cron inotify-tools

RUN apt-get update && apt-get install -y python memcached

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY files/* /tmp/

ENV BLUESPICE_WEBROOT="/var/www/html/bluespice"
ENV BLUESPICE_DATA_PATH="/var/bluespice"
ENV BLUESPICE_CONFIG_PATH="/etc/bluespice"
ENV BLUESPICE_FREE_BACKUPFILE="/var/backups/bluespice_free.zip"
ENV BLUESPICE_PRO_FILE="/tmp/bluespice_pro.zip"
ENV BLUESPICE_FREE_FILE="/tmp/bluespice.zip"
ENV BLUESPICE_PRO_KEY_FILE=bluespice_pro_key.txt
ENV BLUESPICE_UPGRADE_JOBFILE=upgrade.task
ENV BLUESPICE_DOWNGRADE_JOBFILE=downgrade.task
ENV BLUESPICE_AUTOSERVICE_URL="http://172.17.0.1:8083/frontend/download/docker/2.27.2/bluespice.zip"

RUN mkdir ${BLUESPICE_WEBROOT} -p
RUN unzip ${BLUESPICE_FREE_FILE} -d ${BLUESPICE_WEBROOT} && rm ${BLUESPICE_FREE_FILE}
RUN find ${BLUESPICE_WEBROOT}/ -name '*.war' -exec mv {} /var/lib/tomcat8/webapps/ \;
RUN mkdir /opt/bluespice/ && mv ${BLUESPICE_WEBROOT}/extensions/BlueSpiceExtensions/ExtendedSearch/webservices/solr/ /opt/bluespice/
RUN cp /opt/bluespice/solr/bluespice/conf/lang/stopwords_de.txt /opt/bluespice/solr/bluespice/conf/stopwords.txt
RUN chown -R tomcat8:tomcat8 /opt/bluespice/solr/
RUN echo "JAVA_OPTS=\"\${JAVA_OPTS} -Dsolr.solr.home=/opt/bluespice/solr\"" >> /etc/default/tomcat8

COPY configs/etc/memcached.conf /etc/memcached.conf
COPY configs/etc/tomcat8/* /etc/tomcat8/
COPY configs/etc/php/7.0/apache2/php.ini /etc/php/7.0/apache2/php.ini
COPY configs${BLUESPICE_WEBROOT}/.gitignore ${BLUESPICE_WEBROOT}/.gitignore
COPY configs${BLUESPICE_WEBROOT}/settings.d/* ${BLUESPICE_WEBROOT}/settings.d/
COPY scripts/* /usr/sbin/

RUN mkdir /root/cronjobs
COPY cronjobs/* /root/cronjobs/
RUN crontab /root/cronjobs/jobs.txt

#mysql data
ENV DB_HOST=""
ENV DB_PORT="3306"
ENV DB_NAME=""
ENV DB_USER=""
ENV DB_PASSWORD=""
#installation data
ENV WIKI_NAME="BlueSpice MediaWiki"
ENV WIKI_ADMIN="WikiSysop"

VOLUME ${BLUESPICE_CONFIG_PATH} ${BLUESPICE_DATA_PATH}
EXPOSE 80
EXPOSE 8080

ENTRYPOINT /usr/sbin/entrypoint.sh
