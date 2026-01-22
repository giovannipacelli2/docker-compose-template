# --- Fase 1: Assets ---
FROM node:20-alpine AS assets-builder
WORKDIR /app
COPY . .
RUN npm install
RUN npm ci && npm run prod-build

# --- Fase 2: Build PHP (Composer) ---
FROM php:8.3-alpine AS build

# Installa lo strumento per gestire le estensioni PHP in modo semplice su Alpine
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# Installa le dipendenze di sistema ed estensioni PHP
RUN apk update && apk add --no-cache git unzip
RUN install-php-extensions intl xsl bcmath soap zip gd

# Copia Composer dall'immagine ufficiale
COPY --from=composer:2.8.1 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Gestione Auth e File
ARG COMPOSER_AUTH
ENV COMPOSER_AUTH=$COMPOSER_AUTH

COPY . /app/

# LOCAL TESTING
# 1. Risolve il problema "Host key verification failed" e "SSH"
#RUN git config --global url."https://github.com/".insteadOf git@github.com:

RUN composer install \
    --prefer-dist \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --ignore-platform-req=ext-gd

# Pulisci le credenziali
ENV COMPOSER_AUTH=

FROM php:8.3-apache-bullseye as production

# Impostazioni ambiente
ENV APACHE_HTTP_PORT_NUMBER=8080

# Installazione dipendenze di sistema (unite per ridurre i layer)
RUN apt-get update && apt-get install -y \
    libxml2-dev libxslt-dev libzip-dev zip \
    libpng-dev libjpeg-dev libfreetype6-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Installazione estensioni PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install intl xsl bcmath soap pdo pdo_mysql zip gd opcache

# Configurazione Apache
RUN a2enmod rewrite && \
    sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf

# Copia dei file
COPY --from=build /app /var/www/html
COPY --from=assets-builder /app/public/build /var/www/html/public/build
#COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
#COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Permessi corretti (eseguire prima dell'entrypoint per velocizzare l'avvio)
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
