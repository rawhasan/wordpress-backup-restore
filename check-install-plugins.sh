#!/bin/bash

# ========== CONFIGURATION ==========
domain="example.com"
wp_path="/sites/$domain/public"
temp_dir="/tmp/wp-plugin-installer-$domain"

declare -A plugins=(
  ["Redis Object Cache"]="redis-cache"
  ["Post SMTP"]="post-smtp"
  ["Nginx Helper"]="nginx-helper"
)
# ===================================

# Ensure WordPress installation exists
if [ ! -f "$wp_path/wp-config.php" ]; then
  echo "❌ wp-config.php not found at $wp_path. Is WordPress installed?"
  exit 1
fi

# Check WP-CLI
if ! command -v wp &> /dev/null; then
  echo "❌ WP-CLI not found in PATH."
  exit 1
fi

# Create temp directory for downloads
mkdir -p "$temp_dir"
cd "$wp_path" || exit

echo "📂 Working in: $wp_path"
echo

# Loop through plugins
for name in "${!plugins[@]}"; do
  slug=${plugins[$name]}
  echo "🔍 Checking: $name ($slug)..."

  if wp plugin is-installed "$slug" &> /dev/null; then
    echo "✅ $name is already installed."
    echo
  else
    echo "⚠️ $name is not installed."
    read -p "👉 Do you want to install $name? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      zip_url="https://downloads.wordpress.org/plugin/${slug}.latest-stable.zip"
      zip_file="$temp_dir/${slug}.zip"

      echo "⬇️ Downloading $name..."
      curl -sSL "$zip_url" -o "$zip_file"

      if [ -f "$zip_file" ]; then
        echo "📦 Installing $name..."
        wp plugin install "$zip_file" --activate
        if [ $? -eq 0 ]; then
          echo "✅ Successfully installed and activated $name."
        else
          echo "❌ Installation failed for $name."
        fi
      else
        echo "❌ Failed to download $name from $zip_url"
      fi
      echo
    else
      echo "⏩ Skipped $name."
      echo
    fi
  fi
done

# Clean up temp files
echo "🧹 Cleaning up temporary files..."
rm -rf "$temp_dir"
echo "✅ Done."
