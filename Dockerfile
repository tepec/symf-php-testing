FROM php:7.2-fpm-alpine

ENV WORKDIR "/var/www/app"

RUN apk upgrade --update && apk --no-cache add \
    git autoconf tzdata openntpd libcurl curl-dev coreutils \
    libmcrypt-dev freetype-dev libxpm-dev libjpeg-turbo-dev libvpx-dev \
    libpng-dev libxml2-dev icu-dev openssl-dev \
    $PHPIZE_DEPS

RUN docker-php-ext-configure intl \
    && docker-php-ext-configure opcache \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    --with-xpm-dir=/usr/include/

RUN pecl install mcrypt-1.0.1

RUN docker-php-ext-install -j$(nproc) gd iconv pdo pdo_mysql curl \
    bcmath mbstring json xml xmlrpc zip intl opcache
    
RUN docker-php-ext-enable mcrypt

# Add timezone
RUN rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/UTC /etc/localtime && \
    "date"

# Install composer
RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/local/bin --filename=composer

# Cleanup
RUN rm -rf /var/cache/apk/* \
    && find / -type f -iname \*.apk-new -delete \
    && rm -rf /var/cache/apk/*

RUN mkdir -p ${WORKDIR}
RUN chown www-data:www-data -R ${WORKDIR}

WORKDIR ${WORKDIR}

EXPOSE 9000

CMD ["php-fpm"]
