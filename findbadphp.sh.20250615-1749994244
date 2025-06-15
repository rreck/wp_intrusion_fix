root@wp6:/var/www/www.aab-ai.org/wordpress# find wp-content/uploads/ -type f -name "*.php" -exec sh -c 'd="/root/quarantine/$(date +%s)"; mkdir -p "$d"; mv "$1" "$d"' _ {} \;
root@wp6:/var/www/www.aab-ai.org/wordpress# find wp-content/uploads/ -type f -name "*.php" -delete
find wp-content/uploads/ -type d -exec chmod 755 {} \;
find wp-content/uploads/ -type f -exec chmod 644 {} \;
