# Use the official PHP 8.3 image with FPM
FROM php:8.3-fpm

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install exif \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js 18 and npm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Add a new user with a login shell
RUN useradd -ms /bin/bash devuser

# Copy existing application directory contents
COPY . /var/www

# Ensure the application runs as the new user
RUN chown -R devuser:devuser /var/www

# Change current user to the new user
USER devuser

# Install Vite and other frontend dependencies
RUN npm install

# Expose port 9000 and start php-fpm server
EXPOSE 9000

CMD ["php-fpm"]
