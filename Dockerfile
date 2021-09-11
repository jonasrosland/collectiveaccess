FROM ubuntu:20.04

ENV APACHE_RUN_USER     www-data
ENV APACHE_RUN_GROUP    www-data
ENV APACHE_LOG_DIR      /var/log/apache2
ENV APACHE_PID_FILE     /var/run/apache2.pid
ENV APACHE_RUN_DIR      /var/run/apache2
ENV APACHE_LOCK_DIR     /var/lock/apache2
ENV APACHE_LOG_DIR      /var/log/apache2

ENV CA_PROVIDENCE_VERSION=1.7.12
ENV CA_PROVIDENCE_DIR=/var/www/html/providence
ENV CA_PAWTUCKET_VERSION=1.7.12
ENV CA_PAWTUCKET_DIR=/var/www/html/pawtucket2

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y mysql-server \
	apache2 \
	redis-server \
	php \
	php-cli \
	php-common \
	php-gd \
	php-curl \
	php-mysqlnd \
	php-zip \
	php-fileinfo \
	php-gmagick \
	php-opcache \
	#php-process \
	php-xml \
	php-mbstring \
	php-gmagick \
	graphicsmagick \
	libgraphicsmagick-dev \
	ffmpeg \
	ghostscript \
	libreoffice \
	dcraw \
	mediainfo \
	#poppler \
	#perl-Image-ExifTool \
	curl \
	zip \
	libapache2-mod-php \
	php-mbstring \
	php-xmlrpc \
	php-gd \
	php-xml \
	php-intl \
	php-mysql \
	php-cli \
	php-zip \
	php-curl \
	php-posix \
	php-dev \
	php-pear \
	php-redis \
	php-gmagick \
	php-gmp \
	libpoppler-dev \
	poppler-utils \
	libimage-exiftool-perl

RUN curl -SsL https://github.com/collectiveaccess/providence/archive/$CA_PROVIDENCE_VERSION.tar.gz | tar -C /var/www/ -xzf -
RUN mv /var/www/providence-$CA_PROVIDENCE_VERSION /var/www/html/providence
RUN cd $CA_PROVIDENCE_DIR && cp setup.php-dist setup.php

RUN curl -SsL https://github.com/collectiveaccess/pawtucket2/archive/$CA_PAWTUCKET_VERSION.tar.gz | tar -C /var/www/ -xzf -
RUN mv /var/www/pawtucket2-$CA_PAWTUCKET_VERSION /var/www/html/pawtucket2
RUN cd $CA_PAWTUCKET_DIR && cp setup.php-dist setup.php

#RUN sed -i "s@DocumentRoot \/var\/www\/html@DocumentRoot \/var\/www@g" /etc/apache2/sites-available/000-default.conf
RUN ln -s /$CA_PROVIDENCE_DIR/media /$CA_PAWTUCKET_DIR/media

RUN chown -R www-data:www-data /var/www/html

# Create a backup of the default conf files in case directory is mounted
RUN mkdir -p /var/ca/providence/conf
RUN cp -r $CA_PROVIDENCE_DIR/app/conf/* /var/ca/providence/conf

# Copy our local files
COPY php.ini /etc/php/7.4/apache2/php.ini
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Run apcache from entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD [ "/usr/sbin/apache2", "-DFOREGROUND" ]