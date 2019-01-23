FROM debian:9

# CONIFGURE APT REPORTING
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# UPDATE PACKAGES
RUN apt update; apt -y upgrade; apt -y dist-upgrade; apt -y autoremove; apt -y purge $(dpkg --list |grep '^rc' |awk '{print $2}'); apt clean

# INSTALL NEEDED TOOLS
RUN apt update; apt -y install apt-utils bzip2 composer cron curl g++ gcc git-core gnupg gnupg1 gnupg2 make screen unzip vim wget

# INSTALL APACHE
RUN apt update; apt -y install apache2

# INSTALL MARIADB
#RUN apt update; apt -y install mariadb-server

# INSTALL PHP
RUN apt update; apt -y install php7.0 php7.0-cli php7.0-common php7.0-curl php7.0-gd php7.0-intl php7.0-json php7.0-ldap php7.0-mbstring php7.0-mysql php7.0-opcache php7.0-tidy php7.0-xml php7.0-zip php-pear libapache2-mod-php7.0

# INSTALL PEAR MAIL
# RUN pear install mail
# RUN pear install net_smtp
# INSTALL PEAR MAIL
RUN git clone https://github.com/pear/Mail.git /tmp/mail; \
	cd /tmp/mail; \
	pear package; \
	pear install -f package.xml; \
	git clone https://github.com/pear/Net_SMTP.git /tmp/net_smtp; \
	cd /tmp/net_smtp; \
	pear package; \
	pear install -f package.xml; \
	cd /tmp; \
	rm -rf /tmp/mail; \
	rm -rf /tmp/net_smtp


# INSTALL TOMCAT
RUN apt update; apt -y install jetty9

# INSTALL ELASTICSEARCH
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN apt update; apt -y install apt-transport-https
RUN echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" > /etc/apt/sources.list.d/elastic-6.x.list
RUN apt update; apt -y install elasticsearch=6.3.1
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install -b ingest-attachment
RUN echo "elasticsearch hold" | dpkg --set-selections

# INSTALL MEMCACHED
RUN apt update; apt -y install memcached

# INSTALL PYTHON
RUN apt update; apt -y install python3

# INSTALL PHANTOMJS
RUN cd /tmp; wget --no-check-certificate https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN cd /tmp; tar xjf phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN cp /tmp/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin
RUN rm -rf /tmp/phantomjs-2.1.1-linux-x86_64; rm -f /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2

# INSTALL NODEJS
RUN curl -sL https://deb.nodesource.com/setup_8.x -o /tmp/setup_nodejs
RUN sed -i 's/apt-key add/APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add/g' /tmp/setup_nodejs
RUN bash /tmp/setup_nodejs
RUN rm /tmp/setup_nodejs
RUN apt update; apt -y install nodejs

# INSTALL PARSOID
RUN cd /usr/local; git clone https://gerrit.wikimedia.org/r/p/mediawiki/services/parsoid parsoid
RUN rm -rf /usr/local/parsoid/.git
RUN find /usr/local/parsoid -iname '.git*' -exec rm -rf {} \;
RUN cd /usr/local/parsoid; npm install

# INSTALL GHOSTSCRIPT
RUN cd /tmp; wget --no-check-certificate https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs925/ghostscript-9.25-linux-x86_64.tgz
RUN cd /tmp; tar xzf ghostscript-9.25-linux-x86_64.tgz
RUN cp /tmp/ghostscript-9.25-linux-x86_64/gs-925-linux-x86_64 /usr/local/bin/gs
RUN rm -rf /tmp/ghostscript-9.25-linux-x86_64; rm -f /tmp/ghostscript-9.25-linux-x86_64.tgz

# INSTALL GRAPHICAL UTILS
RUN apt update; apt -y install imagemagick inkscape poppler-utils

# CREATE SSL BASICS
RUN mkdir -p /opt/ca
RUN cd /tmp; openssl rand -base64 32 > passwd.txt
RUN cd /opt/ca; echo 01 > ca.srl

# CREATE SSL ROOT CA
RUN cd /opt/ca; openssl genrsa -des3 -out ca.key -passout pass:`cat /tmp/passwd.txt` 4096
RUN cd /opt/ca; openssl req -new -x509 -days 3650 -passin pass:`cat /tmp/passwd.txt` -key ca.key -out ca.crt -subj "/C=DE/ST=Bavaria/L=Regensburg/O=Hallo Welt GmbH/CN=Parsoid CA"

# CREATE SSL PARSOID
RUN cd /opt/ca; openssl genrsa -des3 -out parsoid.key -passout pass:`cat /tmp/passwd.txt` 4096
RUN cd /opt/ca; openssl req -new -key parsoid.key -out parsoid.csr -passin pass:`cat /tmp/passwd.txt` -subj "/C=DE/ST=Bavaria/L=Regensburg/O=Hallo Welt GmbH/CN=parsoid"
RUN cd /opt/ca; openssl x509 -req -days 3650 -passin pass:`cat /tmp/passwd.txt` -in parsoid.csr -CA ca.crt -CAkey ca.key -out parsoid.crt
RUN cd /opt/ca; openssl rsa -in parsoid.key -out parsoid.key -passin pass:`cat /tmp/passwd.txt`

# CREATE SSL APACHE
RUN cd /opt/ca; openssl genrsa -des3 -out httpd.key -passout pass:`cat /tmp/passwd.txt` 4096
RUN cd /opt/ca; openssl req -new -key httpd.key -out httpd.csr -passin pass:`cat /tmp/passwd.txt` -subj "/C=DE/ST=Bavaria/L=Regensburg/O=Hallo Welt GmbH/CN=httpd"
RUN cd /opt/ca; openssl x509 -req -days 3650 -passin pass:`cat /tmp/passwd.txt` -in httpd.csr -CA ca.crt -CAkey ca.key -out httpd.crt
RUN cd /opt/ca; openssl rsa -in httpd.key -out httpd.key -passin pass:`cat /tmp/passwd.txt`

# CREATE SSL CLEAN UP
RUN rm -f /tmp/passwd.txt

# CONFIGURE VIM
RUN sed -i 's/set mouse=a/set mouse-=a/g' /usr/share/vim/vim80/defaults.vim
RUN echo "set paste" >> /usr/share/vim/vim80/defaults.vim

# CONFIGURE APACHE2
COPY ./config/httpd/bluespice.conf /etc/apache2/sites-available
RUN rm /etc/apache2/sites-enabled/000-default.conf
RUN ln -s /etc/apache2/sites-available/bluespice.conf /etc/apache2/sites-enabled/bluespice.conf
COPY ./config/httpd/server-name.conf /etc/apache2/conf-available
RUN ln -s /etc/apache2/conf-available/server-name.conf /etc/apache2/conf-enabled/server-name.conf
RUN a2enmod proxy; a2enmod proxy_http; a2enmod rewrite; a2enmod ssl

# CONFIGURE PHP
RUN sed -i 's/^max_execution_time.*$/max_execution_time = 300/g' /etc/php/7.0/apache2/php.ini
RUN sed -i 's/^post_max_size.*$/post_max_size = 128M/g' /etc/php/7.0/apache2/php.ini
RUN sed -i 's/^upload_max_filesize.*$/upload_max_filesize = 128M/g' /etc/php/7.0/apache2/php.ini
RUN sed -i 's/^;date.timezone.*$/date.timezone = Europe\/Berlin/g' /etc/php/7.0/apache2/php.ini
RUN sed -i 's/^;opcache.enable=.*$/opcache.enable=1/g' /etc/php/7.0/apache2/php.ini
RUN sed -i 's/^;opcache.memory_consumption.*$/opcache.memory_consumption=512/g' /etc/php/7.0/apache2/php.ini
RUN sed -i 's/^;opcache.max_accelerated_files.*$/opcache.max_accelerated_files=10000/g' /etc/php/7.0/apache2/php.ini
RUN sed -i 's/^;opcache.validate_timestamps.*$/opcache.validate_timestamps=1/g' /etc/php/7.0/apache2/php.ini
RUN sed -i 's/^;opcache.revalidate_freq.*$/opcache.revalidate_freq=2/g' /etc/php/7.0/apache2/php.ini
RUN sed -i 's/^;curl.cainfo.*$/curl.cainfo = \/opt\/ca\/ca.crt/g' /etc/php/7.0/apache2/php.ini

# CONFIGURE JETTY
RUN echo "JAVA_OPTIONS=\"-Xms512m -Xmx1024m\"" >> /etc/default/jetty9

# CONFIGURE MEMCACHED
RUN sed -i 's/-m 64/-m 128/g' /etc/memcached.conf

# CONFIGURE PARSOID
COPY ./config/parsoid/config.yaml /usr/local/parsoid
COPY ./config/parsoid/localsettings.js /usr/local/parsoid

# CONFIGURE WEBSERVICES
RUN cd /tmp; wget https://buildservice.bluespice.com/webservices3.tar.gz
RUN cd /tmp; tar xzf webservices3.tar.gz
RUN mv /tmp/webservices/*.war /var/lib/jetty9/webapps
RUN rm -f /tmp/webservices3.tar.gz
RUN rm -rf /tmp/webservices

# CONFIGURE CRONJOBS
COPY ./config/httpd/bluespice-cron /etc/cron.d/bluespice-cron
RUN chmod 0644 /etc/cron.d/bluespice-cron
RUN touch /var/log/bluespice-cron.log

# INSTALL EXECUTABLES
COPY ./bin/* /usr/local/bin/
RUN chown root.staff /usr/local/bin/*
RUN chmod +x /usr/local/bin/*

COPY codebase/* /tmp/

ENV BLUESPICE_WEBROOT="/var/www/bluespice"
ENV BLUESPICE_DATA_PATH="/opt/bluespice"
ENV BLUESPICE_CONFIG_PATH="/etc/bluespice"
#ENV BLUESPICE_FREE_BACKUPFILE="/var/backups/bluespice_free.zip"
#ENV BLUESPICE_PRO_FILE="/tmp/bluespice_pro.zip"
#ENV BLUESPICE_FREE_FILE="/tmp/bluespice.zip"
#ENV BLUESPICE_PRO_KEY_FILE=bluespice_pro_key.txt
#ENV BLUESPICE_UPGRADE_JOBFILE=upgrade.task
#ENV BLUESPICE_DOWNGRADE_JOBFILE=downgrade.task
#ENV BLUESPICE_AUTOSERVICE_URL="http://172.16.100.11:8083/frontend/download/docker/2.27.2/bluespice.zip"


RUN cd /tmp; tar -xzf bluespice-free.tar.gz
RUN mv /tmp/bluespice-free ${BLUESPICE_WEBROOT}
COPY ./config/settings.d/* ${BLUESPICE_WEBROOT}/settings.d/

#RUN mkdir -p ${BLUESPICE_WEBROOT}
#RUN git clone --depth=1 -b REL1_31 https://github.com/hallowelt/mediawiki ${BLUESPICE_WEBROOT}
#RUN cd ${BLUESPICE_WEBROOT}; composer update
#RUN find . -name "*.git*" -print0 | xargs -0 rm -rf;
#
#RUN rm -rf /root/.ssh

#mysql data
ENV DB_HOST=""
ENV DB_PORT="3306"
ENV DB_NAME=""
ENV DB_USER=""
ENV DB_PASSWORD=""
#installation data
ENV WIKI_NAME="BlueSpice MediaWiki"
ENV WIKI_ADMIN="WikiSysop"

# PORTS
EXPOSE 80
EXPOSE 443
#EXPOSE 8000
#EXPOSE 8001
VOLUME ${BLUESPICE_CONFIG_PATH} ${BLUESPICE_DATA_PATH}

# SET ENTRYPOINT
ENTRYPOINT /usr/local/bin/entry.sh
