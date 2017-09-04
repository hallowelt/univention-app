FROM debian:stretch

RUN apt-get update && apt-get -y install apache2

RUN apt-get update && apt-get -y install php7.0 php7.0-mysql php7.0-mbstring php7.0-json php7.0-curl php7.0-xml php7.0-gd php7.0-tidy curl apache2-mod-php7.0

RUN apt-get update && apt-get -y install tomcat8

RUN apt-get -y install unzip rsync

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY files/* /tmp/

RUN cd /tmp && tar xzvf mediawiki.tar.gz && mv mediawiki-1.27.3/ /var/www/html/w
RUN cd /tmp && unzip bluespice.zip && rsync -a bluespice-free/ /var/www/html/w/ && rm bluespice-free/ -Rf
RUN cd /tmp && rm bluespice.zip mediawiki.tar.gz
RUN find /var/www/html/w/ -name '*.war' -exec mv {} /var/lib/tomcat8/webapps/ \;
RUN mkdir /opt/bluespice/ && mv /var/www/html/w/extensions/BlueSpiceExtensions/ExtendedSearch/webservices/solr/ /opt/bluespice/
RUN cp /opt/bluespice/solr/bluespice/conf/lang/stopwords_de.txt /opt/bluespice/solr/bluespice/conf/stopwords.txt
RUN chown -R tomcat8:tomcat8 /opt/bluespice/solr/
RUN echo "JAVA_OPTS=\"\${JAVA_OPTS} -Dsolr.solr.home=/opt/bluespice/solr\"" >> /etc/default/tomcat8

COPY configs/etc/tomcat8/* /etc/tomcat8/

#mysql data
ENV MYSQL_HOST="172.17.0.1"
ENV MYSQL_PORT="3306"
ENV MYSQL_DB="bluespice_all_in"
ENV MYSQL_USER="bluespice_all_in"
ENV MYSQL_PASS="w893bzrn"
#installation data
ENV WIKI_NAME="BlueSpice MediaWiki"
ENV WIKI_ADMIN="WikiSysop"

VOLUME /data /var/www/html/w/images /var/www/html/w/cache/var/www/html/w/cache /var/www/html/w/extensions/BlueSpiceFoundation/data /var/www/html/w/extensions/BlueSpiceFoundation/config
EXPOSE 80
EXPOSE 8080

COPY scripts/* /root/

CMD sh /root/start.sh
