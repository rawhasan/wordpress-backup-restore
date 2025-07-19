#!/bin/bash

# === CONFIGURATION ===
SITE_NAME="example.com"
WP_PATH="/sites/example.com/public"
BACKUP_DIR="/sites/example.com/backups"
DB_HOST="localhost"

# === PROMPT FOR DATABASE CREDENTIALS ===
read -p "Enter MySQL database name: " DB_NAME
read -p "Enter MySQL username: " DB_USER
read -s -p "Enter MySQL password: " DB_PASS
echo ""

# === DATE FORMATTING ===
DATE=$(date +"%Y-%m-%d")
BACKUP_NAME="${SITE_NAME}-wp-${DATE}"
TEMP_DIR="/tmp/${BACKUP_NAME}_backup"
ARCHIVE_PATH="$BACKUP_DIR/$BACKUP_NAME.tar.gz"

# === PREPARE TEMP DIR ===
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# === BACKUP wp-content ===
echo "📦 Backing up wp-content..."
tar -czf "$TEMP_DIR/wp-content.tar.gz" -C "$WP_PATH" wp-content

# === BACKUP DATABASE ===
echo "🛢️ Backing up MySQL database..."
mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$TEMP_DIR/db.sql"

# === CREATE FINAL ARCHIVE ===
echo "🗜️ Creating final archive: $ARCHIVE_PATH"
mkdir -p "$BACKUP_DIR"
tar -czf "$ARCHIVE_PATH" -C "$TEMP_DIR" .

# === CLEAN UP ===
rm -rf "$TEMP_DIR"

# === DONE ===
echo "✅ Backup created: $ARCHIVE_PATH"
