FROM php:7.4-fpm
ARG MIX_DSN_PUBLIC=localhost:8000
ENV MIX_DSN_PUBLIC=$MIX_DSN_PUBLIC

RUN apt-get update
RUN apt-get install -y nginx

RUN curl --silent --location https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

RUN curl -sS https://getcomposer.org/installer | php && \
mv composer.phar /usr/local/bin/composer

RUN apt-get install -y git unzip zip libxslt-dev
RUN apt-get install -y \
        libzip-dev \
        librabbitmq-dev \
        zip \
  && docker-php-ext-install zip

RUN apt-get install -y supervisor
RUN pecl install amqp
RUN docker-php-ext-enable amqp
RUN docker-php-ext-install sockets
RUN docker-php-ext-install xsl mysqli pdo pdo_mysql
RUN docker-php-ext-install opcache
RUN apt-get update --fix-missing

RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

COPY . /var/www
WORKDIR /var/www
COPY nginx.conf /etc/nginx/sites-available/default

RUN composer install --no-dev
RUN ./afterInstall.sh

EXPOSE 80
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD php artisan cache:clear && php artisan migrate --force && /usr/bin/supervisord



