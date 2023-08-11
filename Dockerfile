FROM composer:2 AS composer

RUN composer create-project --prefer-dist laravel/laravel /app

FROM php:8.1-apache

COPY --from=composer /app /var/www/html/
COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apt-get update && \
    apt-get install -y \
    zip \
    unzip \
    git \
    libpq-dev \
    && docker-php-ext-install \
    pdo_mysql \
    && docker-php-ext-enable \
    pdo_mysql

RUN chown -R www-data:www-data /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html/bootstrap/cache

RUN a2enmod rewrite && \
    sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

RUN composer dump-autoload --optimize \
    && php artisan optimize

EXPOSE 80

CMD ["apache2-foreground"]
