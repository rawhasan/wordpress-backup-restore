#!/bin/bash

set -e

# CONFIGURATION
DOMAIN="example.com"
PHP_VERSION="8.3"
WP_PATH="/sites/$DOMAIN/public"
POOL_FILE="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
BACKUP_FILE="/tmp/www.conf.bak.$(date +%s)"
CURRENT_USER=$(whoami)

echo "🧰 Starting update for: $DOMAIN (as $CURRENT_USER)"
echo "📁 WordPress path: $WP_PATH"

# --- ROLLBACK FUNCTION ---
rollback() {
  echo "❌ Error occurred. Rolling back changes..."

  if [ -f "$BACKUP_FILE" ]; then
    echo "🔄 Restoring original PHP-FPM config..."
    sudo cp "$BACKUP_FILE" "$POOL_FILE"
  fi

  if id -nG www-data | grep -qw "$CURRENT_USER"; then
    echo "👥 Removing www-data from $CURRENT_USER group..."
    sudo gpasswd -d www-data "$CURRENT_USER" || true
  fi

  echo "🔁 Restarting services to apply rollback..."
  sudo systemctl restart "php${PHP_VERSION}-fpm"
  sudo systemctl reload nginx

  echo "✅ Rollback complete."
  exit 1
}

trap rollback ERR

# --- BACKUP ---
echo "📦 Backing up $POOL_FILE to $BACKUP_FILE"
sudo cp "$POOL_FILE" "$BACKUP_FILE"

# --- OWNERSHIP & PERMISSIONS ---
echo "📁 Changing ownership of $WP_PATH to $CURRENT_USER"
sudo chown -R "$CURRENT_USER:$CURRENT_USER" "$WP_PATH"

echo "🔐 Setting WordPress permissions..."
find "$WP_PATH" -type d -exec chmod 755 {} \;
find "$WP_PATH" -type f -exec chmod 644 {} \;

# --- PHP-FPM CONFIG ---
echo "✏️ Updating PHP-FPM pool: $POOL_FILE"
sudo sed -i "s/^user = .*/user = $CURRENT_USER/" "$POOL_FILE"
sudo sed -i "s/^group = .*/group = $CURRENT_USER/" "$POOL_FILE"

sudo sed -i "s/^listen.owner = .*/listen.owner = $CURRENT_USER/" "$POOL_FILE" || \
  echo "listen.owner = $CURRENT_USER" | sudo tee -a "$POOL_FILE"

sudo sed -i "s/^listen.group = .*/listen.group = $CURRENT_USER/" "$POOL_FILE" || \
  echo "listen.group = $CURRENT_USER" | sudo tee -a "$POOL_FILE"

sudo sed -i "s/^listen.mode = .*/listen.mode = 0660/" "$POOL_FILE" || \
  echo "listen.mode = 0660" | sudo tee -a "$POOL_FILE"

# --- GROUP MODIFICATION ---
echo "👥 Adding www-data to $CURRENT_USER group"
sudo usermod -aG "$CURRENT_USER" www-data

# --- RESTART SERVICES ---
echo "🔁 Restarting PHP-FPM and Nginx"
sudo systemctl restart "php${PHP_VERSION}-fpm"
sudo systemctl reload nginx

echo "✅ WordPress now runs as $CURRENT_USER for domain: $DOMAIN"
