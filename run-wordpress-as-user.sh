#!/bin/bash

# Exit on error
set -e

# Define your WordPress path (edit if needed)
WP_PATH="/var/www/html"

# Get current user
CURRENT_USER=$(whoami)

# PHP version (edit if different)
PHP_VERSION="8.3"

# Pool file path
POOL_FILE="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

echo "🧰 Updating WordPress permissions and PHP-FPM pool for user: $CURRENT_USER"

# 1. Change ownership of WordPress files
echo "📁 Setting ownership of $WP_PATH to $CURRENT_USER..."
sudo chown -R $CURRENT_USER:$CURRENT_USER "$WP_PATH"

# 2. Update PHP-FPM pool to run as current user
echo "⚙️ Updating $POOL_FILE..."

sudo sed -i "s/^user = .*/user = $CURRENT_USER/" $POOL_FILE
sudo sed -i "s/^group = .*/group = $CURRENT_USER/" $POOL_FILE

sudo sed -i "s/^listen.owner = .*/listen.owner = $CURRENT_USER/" $POOL_FILE || \
  echo "listen.owner = $CURRENT_USER" | sudo tee -a $POOL_FILE

sudo sed -i "s/^listen.group = .*/listen.group = $CURRENT_USER/" $POOL_FILE || \
  echo "listen.group = $CURRENT_USER" | sudo tee -a $POOL_FILE

sudo sed -i "s/^listen.mode = .*/listen.mode = 0660/" $POOL_FILE || \
  echo "listen.mode = 0660" | sudo tee -a $POOL_FILE

# 3. Add www-data to the current user's group to allow Nginx to talk to PHP
echo "👥 Adding www-data to $CURRENT_USER group..."
sudo usermod -aG "$CURRENT_USER" www-data

# 4. Set secure file permissions for WordPress
echo "🔐 Setting file and directory permissions..."
find "$WP_PATH" -type d -exec chmod 755 {} \;
find "$WP_PATH" -type f -exec chmod 644 {} \;

# 5. Restart services
echo "🔁 Restarting PHP-FPM and reloading Nginx..."
sudo systemctl restart "php${PHP_VERSION}-fpm"
sudo systemctl reload nginx

echo "✅ Done. WordPress now runs under user: $CURRENT_USER"
