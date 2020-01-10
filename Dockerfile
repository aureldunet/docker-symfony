FROM debian:buster-slim AS symfony-apache

RUN apt-get update \
&&  apt-get install -y --no-install-recommends \
	software-properties-common \
	apt-transport-https \
	lsb-release \
	ca-certificates \
&&  apt-get update \
&&  apt-get install -y --no-install-recommends \
    gnupg \
    gnupg1 \
    gnupg2 \
	ssl-cert \
	git \
	vim \
	wget \
	curl \
	cron \
	unzip

RUN apt-get update \
&&  apt-get install -y --no-install-recommends \
	supervisor

COPY docker/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY docker/supervisor/conf.d/apache.conf /etc/supervisor/conf.d/

RUN apt-get update \
&&  wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - \
&&  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

RUN apt-get update \
&&  apt-get install -y \
    apache2 \
    libapache2-mod-php7.4 \
    php7.4 \
    php7.4-cli \
    php7.4-common \
    php7.4-curl \
    php7.4-mbstring \
    php7.4-mysql \
    php7.4-xml \
    php7.4-gd \
    php7.4-intl \
    php7.4-zip

COPY docker/php/*.ini /etc/php/7.4/cli/

COPY docker/apache/envvars /etc/apache2/envvars

COPY docker/apache/sites-available/*.conf /etc/apache2/sites-available/

COPY docker/apache/*.conf /etc/apache2/

RUN rm /etc/apache2/sites-enabled/*

RUN ln -sf /etc/apache2/sites-available/server.conf /etc/apache2/sites-enabled/server.conf

RUN a2enmod rewrite \
&&  a2enmod headers \
&&  a2enmod ssl

RUN rm -rf /var/www/html/*

RUN usermod -u 1000 www-data \
&&  chsh -s /bin/bash www-data \
&&  chown www-data:www-data /var/www /var/www/html/.*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

EXPOSE 80 443

WORKDIR /var/www/html

CMD ["/usr/bin/supervisord"]

FROM debian:buster-slim AS symfony-node

RUN apt-get update \
&&  apt-get install -y --no-install-recommends \
	software-properties-common \
	apt-transport-https \
	lsb-release \
	ca-certificates \
&&  apt-get update \
&&  apt-get install -y --no-install-recommends \
    gnupg \
    gnupg1 \
    gnupg2 \
	git \
	vim \
	wget \
	curl

RUN apt-get update \
&&  apt-get install -y --no-install-recommends \
	supervisor

COPY docker/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

RUN apt-get update \
&&  curl -sL https://deb.nodesource.com/setup_12.x | bash - \
&&  apt-get install -y --no-install-recommends \
    nodejs

RUN apt-get update \
&&  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
&&  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update \
&&  apt-get install -y --no-install-recommends \
    yarn

RUN mkdir -p /var/www/html

RUN usermod -u 1000 www-data \
&&  chsh -s /bin/bash www-data \
&&  chown www-data:www-data /var/www /var/www/html/.*

EXPOSE 8888

WORKDIR /var/www/html

CMD ["/usr/bin/supervisord"]