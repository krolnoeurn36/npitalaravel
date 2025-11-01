# Start from the official PHP 8.3 image with Apache
FROM php:8.3-apache

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN docker-php-ext-install pdo_mysql
    # && apt-get clean && rm -rf /var/lib/apt/lists/*
# RUN apt-get update && apt-get install -y \
    # git \
    # curl \
    # zip \
    # unzip \
    # libpng-dev \
    # libjpeg-dev \
    # libfreetype6-dev \
    # libonig-dev \
    # libxml2-dev \
    # libzip-dev \
# RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
#     && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite (needed for Laravel pretty URLs)
RUN a2enmod rewrite

# Copy existing application files to container
COPY . .

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www/html

# Set proper permissions for Laravel storage and cache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

# Install Composer globally
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install Laravel dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Set Apache DocumentRoot to Laravel's public directory
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Update Apache configuration to use the new DocumentRoot
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Expose port 80
EXPOSE 9000

# Start Apache
CMD ["apache2-foreground"]
