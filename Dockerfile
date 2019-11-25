FROM debian:buster

ENV BS_DATA_DIR="/var/www/bluespice"
ENV BLUESPICE_DATA_PATH="/opt/bluespice"
ENV BLUESPICE_CONFIG_PATH="/etc/bluespice"

# CONIFGURE APT REPORTING
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# UPDATE PACKAGES
RUN apt-get update; \
	apt-get -y upgrade; \
	apt-get -y dist-upgrade; \
	apt-get -y autoremove; \
	apt-get -y purge $(dpkg --list |grep '^rc' |awk '{print $2}'); \
	apt-get clean

# INSTALL NEEDED TOOLS
RUN apt-get update; \
	apt-get -y install \
		apache2 \
		apt-transport-https \
		apt-utils \
		bzip2 \
		cron \
		curl \
		dvipng \
		g++ \
		gcc \
		git-core \
		gnupg \
		gnupg1 \
		gnupg2 \
		imagemagick \
		inkscape \
		jetty9 \
		krb5-config \
		krb5-locales \
 		krb5-user \
		libapache2-mod-auth-kerb \
		libapache2-mod-php7.3 \
		logrotate \
		make \
		mariadb-client \
		memcached \
		ocaml-nox \
		php7.3 \
		php7.3-cli \
		php7.3-common \
		php7.3-curl \
		php7.3-gd \
		php7.3-intl \
		php7.3-json \
		php7.3-ldap \
		php7.3-mbstring \
		php7.3-mysql \
		php7.3-opcache \
		php7.3-xml \
		php7.3-zip \
		php-pear \
		poppler-utils \
		python3 \
		screen \
		sudo \
		texlive-latex-base \
		texlive-latex-extra \
		vim \
		nodejs \
		npm \
		unzip \
		wget; \
	apt-get clean


# INSTALL PEAR MAIL
RUN pear channel-update pear.php.net; \
	pear install --alldeps mail net_smtp

# INSTALL ELASTICSEARCH
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN apt-get update; apt-get -y install apt-transport-https
RUN echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" > /etc/apt/sources.list.d/elastic-6.x.list
RUN apt-get update; apt-get -y install elasticsearch
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install -b ingest-attachment
RUN echo "elasticsearch hold" | dpkg --set-selections

# INSTALL NODEJS
RUN curl -sL https://deb.nodesource.com/setup_8.x -o /tmp/setup_nodejs; \
	sed -i 's/apt-key add/APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add/g' /tmp/setup_nodejs; \
	bash /tmp/setup_nodejs; \
	rm /tmp/setup_nodejs
RUN apt-get update; \
	apt-get -y install nodejs npm; \
	apt-get clean

# INSTALL PARSOID
RUN cd /usr/local; \
	git clone --depth 1 --branch v0.10.0 https://gerrit.wikimedia.org/r/p/mediawiki/services/parsoid parsoid; \
	cd /usr/local/parsoid; \
	npm install; \
	find /usr/local/parsoid -iname '.git*' | xargs rm -rf

# INSTALL GHOSTSCRIPT
RUN cd /tmp; \
	wget --no-check-certificate https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs926/ghostscript-9.26-linux-x86_64.tgz; \
	tar xzf ghostscript-9.26-linux-x86_64.tgz; \
	cp /tmp/ghostscript-9.26-linux-x86_64/gs-926-linux-x86_64 /usr/local/bin/gs; \
	rm -rf /tmp/ghostscript-9.26-linux-x86_64; \
	rm -f /tmp/ghostscript-9.26-linux-x86_64.tgz

# INSTALL PHANTOMJS
RUN cd /tmp; \
	wget --no-check-certificate https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2; \
	tar xjf phantomjs-2.1.1-linux-x86_64.tar.bz2; \
	mv /tmp/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin; \
	chmod +x /usr/local/bin/phantomjs; \
	rm -rf /tmp/phantomjs-2.1.1-linux-x86_64; \
	rm -rf /tmp/phantomjs-2.1.1-linux-x86_64.tar.bz2

# CONFIGURE VIM
RUN sed -i 's/set mouse=a/set mouse-=a/g' /usr/share/vim/vim81/defaults.vim
RUN echo "set paste" >> /usr/share/vim/vim81/defaults.vim

# CONFIGURE APACHE2
RUN rm /etc/apache2/sites-available/*; \
	rm /etc/apache2/sites-enabled/*; \
	mkdir /etc/apache2/ssl; \
	a2enmod rewrite; \
	a2enmod ssl
COPY ./config/apache2/sites-available/* /etc/apache2/sites-available/

# CONFIGURE PHP
RUN sed -i 's/^max_execution_time.*$/max_execution_time = 600/g' /etc/php/7.3/apache2/php.ini; \
	sed -i 's/^post_max_size.*$/post_max_size = 128M/g' /etc/php/7.3/apache2/php.ini; \
	sed -i 's/^upload_max_filesize.*$/upload_max_filesize = 128M/g' /etc/php/7.3/apache2/php.ini; \
	sed -i 's/^;date.timezone.*$/date.timezone = Europe\/Berlin/g' /etc/php/7.3/apache2/php.ini; \
	sed -i 's/^memory_limit*$/memory_limit = 512M/g' /etc/php/7.3/apache2/php.ini; \
	sed -i 's/^;opcache.enable=.*$/opcache.enable=1/g' /etc/php/7.3/apache2/php.ini; \
	sed -i 's/^;opcache.memory_consumption.*$/opcache.memory_consumption=512/g' /etc/php/7.3/apache2/php.ini; \
	sed -i 's/^;opcache.max_accelerated_files.*$/opcache.max_accelerated_files=1000000/g' /etc/php/7.3/apache2/php.ini; \
	sed -i 's/^;opcache.validate_timestamps.*$/opcache.validate_timestamps=1/g' /etc/php/7.3/apache2/php.ini; \
	sed -i 's/^;opcache.revalidate_freq.*$/opcache.revalidate_freq=2/g' /etc/php/7.3/apache2/php.ini; \
	sed -i 's/^;opcache.optimization_level.*$/opcache.optimization_level=0x7FFF9FFF/g' /etc/php/7.3/apache2/php.ini; \
	sed -i 's/^;opcache.blacklist_filename.*$/opcache.blacklist_filename=/etc/php/opcache.blacklist/g' /etc/php/7.3/apache2/php.ini; \
	sed -i 's/^zlib.output_compression.*$/zlib.output_compression=On/g' /etc/php/7.3/apache2/php.ini; \
	sed -i 's/^;zlib.output_compression_level.*$/zlib.output_compression_level=9/g' /etc/php/7.3/apache2/php.ini

# CONFIGURE OPCACHE BLACKIST
RUN echo "${BS_DATA_DIR}/w/extensions/BlueSpiceFoundation/config/*" > /etc/php/opcache.blacklist

# CONFIGURE MEMCACHED
RUN sed -i 's/-m 64/-m 512/g' /etc/memcached.conf

# CONFIGURE JETTY
RUN echo "JAVA_OPTIONS=\"-Xms512m -Xmx1024m -Djetty.host=127.0.0.1\"" >> /etc/default/jetty9

# CONFIGURE PARSOID
COPY ./config/parsoid/* /usr/local/parsoid/

# CONFIGURE WEBSERVICES
# TODO: do it

# CONFIGURE CRONJOBS
COPY ./config/system/bluespice-cron /etc/cron.d/bluespice-cron
COPY ./config/system/bluespice-logrotate /etc/logrotate.d/
RUN chmod 0644 /etc/cron.d/bluespice-cron; \
	mkdir /var/log/bluespice; \
	touch /var/log/bluespice/cron.log

# INSTALL BLUESPICE CODEBASE
COPY codebase/bluespice.zip /tmp/

RUN rm -rf ${BS_DATA_DIR}; \
	mkdir -p ${BS_DATA_DIR}; \
    unzip /tmp/bluespice.zip; \
    mv /tmp/bluespice ${BS_DATA_DIR}/w; \


#	git clone --depth 1 -b ${GIT_BRANCH} ${GIT_REPO} ${BS_DATA_DIR}/w; \
	cd ${BS_DATA_DIR}/w; \
#	composer update --no-dev; \
#	find ${BS_DATA_DIR}/w -iname '.git*' | xargs rm -rf; \
#	rm -rf ${BS_DATA_DIR}/w/_bluespice; \
	rm -rf ${BS_DATA_DIR}/w/images; \
	mkdir ${BS_DATA_DIR}/w/images; \
	mkdir ${BS_DATA_DIR}/w/extensions/BlueSpiceFoundation/config; \
	mkdir ${BS_DATA_DIR}/w/extensions/BlueSpiceFoundation/data; \
	mkdir -p /opt/bluespice; \
	mv ${BS_DATA_DIR}/w/settings.d /opt/bluespice; \
	mkdir ${BS_DATA_DIR}/w/settings.d












COPY codebase/* /tmp/

RUN cd /tmp; tar -xzf bluespice-pro.tar.gz
#bluespice-free.tar.gz
RUN mv /tmp/bluespice-pro ${BS_DATA_DIR}
COPY ./config/settings.d/* ${BS_DATA_DIR}/settings.d/


# INSTALL GRAPHICAL UTILS
RUN apt-get update; apt-get -y install imagemagick inkscape poppler-utils

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

# CONFIGURE NodeJS
RUN npm config set registry http://registry.npmjs.org
RUN npm -g install npm@latest

# CONFIGURE JETTY
RUN echo "JAVA_OPTIONS=\"-Xms512m -Xmx1024m\"" >> /etc/default/jetty9

# CONFIGURE MEMCACHED
RUN sed -i 's/-m 64/-m 256/g' /etc/memcached.conf

# CONFIGURE PARSOID
COPY ./config/parsoid/config.yaml /usr/local/parsoid

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

# INSTALL MATH
RUN cd /var/www/bluespice/extensions/Math/math; \
	make; \
	cp -a /var/www/bluespice/extensions/Math/math/texvc /usr/local/bin

# INSTALL EXECUTABLES
COPY ./bin/* /usr/local/bin/
RUN chown root.staff /usr/local/bin/*
RUN chmod +x /usr/local/bin/*

#ENV BLUESPICE_FREE_BACKUPFILE="/var/backups/bluespice_free.zip"
#ENV BLUESPICE_PRO_FILE="/tmp/bluespice_pro.zip"
#ENV BLUESPICE_FREE_FILE="/tmp/bluespice.zip"
#ENV BLUESPICE_PRO_KEY_FILE=bluespice_pro_key.txt
#ENV BLUESPICE_UPGRADE_JOBFILE=upgrade.task
#ENV BLUESPICE_DOWNGRADE_JOBFILE=downgrade.task
#ENV BLUESPICE_AUTOSERVICE_URL="http://172.16.100.11:8083/frontend/download/docker/2.27.2/bluespice.zip"


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
VOLUME ${BLUESPICE_CONFIG_PATH} ${BLUESPICE_DATA_PATH}

# SET ENTRYPOINT
ENTRYPOINT /usr/local/bin/entry.sh
