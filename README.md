# Setup Larvel - MongoDB

## Navigate to mongodb docs [mongodb-docs](https://www.mongodb.com/docs/) | [larvel-mongodb](https://www.mongodb.com/docs/drivers/php/laravel-mongodb/current/)

- Go to: Client Libraries -> php -> laravel mongodb
- Install: composer global require laravel/installer
- php artisan key:generate
- php artisan storage:link
- php artisan ui vue --auth -> php artisan migrate | (yes if fresh, else no)

```sh
# env

# mongodb
DB_CONNECTION=mongodb
DB_URI=mongodb://localhost:27017
DB_DATABASE=your-db-name

# SESSION_DRIVER=file
# SESSION_CONNECTION=file
SESSION_DRIVER=mongodb
SESSION_CONNECTION=mongodb
CACHE_STORE=mongodb
```

```php
// Go to: config -> database.php -> connections 

'connections' => [
  // mongodb
  'mongodb' => [
      'driver' => 'mongodb',
      'dsn' => env('DB_URI'),
      'database' => env('DB_DATABASE', 'your-db-name'),
  ],
],

```

```php
// Go to: config -> cache.php -> stores 

'stores' => [
  // mongodb
  'mongodb' => [
    'driver' => 'mongodb',
    'connection' => 'mongodb',
    'collection' => 'cache',
    'lock_connection' => 'mongodb',
    'lock_collection' => 'cache_locks',
    'lock_lottery' => [2, 100],
    'lock_timeout' => 86400,
  ],
],

```

```php
// Go to: config -> session.php

  'connection' => env('SESSION_CONNECTION',null),

```

```php
// Go to: bootstrap -> providers.php 

return [
    // mongodb
    MongoDB\Laravel\MongoDBServiceProvider::class,
];

```

```php
// Go to: app -> providers -> AppServiceProvider.php 
// Add this to force https since the Dockerfile setup apache at http

use Illuminate\Support\Facades\URL;

public function boot(): void
{
    //
    if (app()->environment('production')) {
    URL::forceScheme('https');
  }
}

```

```sh
# public/.htaccess
# add this line to force https at Apache level (optional)

RewriteCond %{HTTP:X-Forwarded-Proto} !=https
RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

```

- Run: php artisan serve

## Deploy app on Render

```Dockerfile
# File: Dockerfile


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
```

```sh
# Steps on render:

# Create project -> Git Repo -> Web Service
# Language: Docker | Set Envs
```

```sh
# Set env on render

# only show generated key
php artisan key:generate --show

# 
APP_ENV=production
APP_KEY=base64:xxxx
APP_DEBUG=false

# mongodb
DB_CONNECTION=mongodb
DB_URI=mongodb://localhost:27017
DB_DATABASE=your-db-name

# SESSION_DRIVER=file
# CACHE_STORE=file

SESSION_DRIVER=mongodb
SESSION_CONNECTION=mongodb
CACHE_STORE=mongodb

# add your app url later
# add this to force https along with AppServiceProvider setup
APP_URL=https://your-app.onrender.com
```

## Setup Cloudinary

```sh
# install
composer require cloudinary-labs/cloudinary-laravel

# publish config (optional but recommended)
php artisan vendor:publish --tag=cloudinary

# cloudinary url
CLOUDINARY_URL=cloudinary://API_KEY:API_SECRET@CLOUD_NAME
# or
CLOUDINARY_CLOUD_NAME=you-cloud-name
CLOUDINARY_KEY=
CLOUDINARY_SECRET=
# CLOUDINARY_SECURE=true
# CLOUDINARY_PREFIX=
FILESYSTEM_DISK=cloudinary



```
