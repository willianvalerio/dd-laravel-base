FROM php:7.2-apache

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install REDIS  extension
RUN pecl install -o -f redis && docker-php-ext-enable redis

# Install MongoDB extension
ENV MONGO_VERSION 1.5.5
RUN pecl install -o -f mongodb-${MONGO_VERSION} && docker-php-ext-enable mongodb

# Install Datadog Tracer
ENV DD_TRACE_VERSION 0.48.0
RUN curl -LO https://github.com/DataDog/dd-trace-php/releases/download/${DD_TRACE_VERSION}/datadog-php-tracer_${DD_TRACE_VERSION}_amd64.deb && \
    dpkg -i datadog-php-tracer_${DD_TRACE_VERSION}_amd64.deb && \
    rm -f datadog-php-tracer_${DD_TRACE_VERSION}_amd64.deb

# Apache settings
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Set working directory
WORKDIR /var/www
