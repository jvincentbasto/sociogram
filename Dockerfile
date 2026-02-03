# ============================
# Laravel + MongoDB Dockerfile for Render Free Tier
# ============================
FROM php:8.2-apache

# ----------------------------
# 1️⃣ Install system dependencies
# ----------------------------
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libssl-dev \
    libonig-dev \
    libzip-dev \
    zip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# 2️⃣ Install MongoDB PHP extension
# ----------------------------
RUN pecl install mongodb-1.21.4 \
    && docker-php-ext-enable mongodb

# ----------------------------
# 3️⃣ Enable Apache rewrite module
# ----------------------------
RUN a2enmod rewrite

# ----------------------------
# 4️⃣ Set working directory
# ----------------------------
WORKDIR /var/www/html

# ----------------------------
# 5️⃣ Copy Laravel project files
# ----------------------------
COPY . .

# ----------------------------
# 6️⃣ Copy Composer binary
# ----------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ----------------------------
# 7️⃣ Install PHP dependencies
# ----------------------------
RUN composer install --no-dev --optimize-autoloader

RUN php artisan storage:link

# ----------------------------
# 8️⃣ Set permissions for Laravel
# ----------------------------
RUN chown -R www-data:www-data storage bootstrap/cache

# ----------------------------
# 9️⃣ Configure Apache to serve Laravel public folder
# ----------------------------
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf \
    && printf '<Directory /var/www/html/public>\n\
    AllowOverride All\n\
    Require all granted\n\
    </Directory>\n' >> /etc/apache2/apache2.conf \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

# ----------------------------
# 10️⃣ Expose HTTP port
# ----------------------------
EXPOSE 80

# ----------------------------
# 11️⃣ Start Apache
# ----------------------------
CMD ["apache2-foreground"]
