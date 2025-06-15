#!/bin/bash
#
# Script Name: quarantine-php.sh
# Version: 1.2.0
#
# Description:
#   Scans a specified WordPress directory (default: /var/www/www.aab-ai.org/wordpress)
#   for .php files under wp-content/uploads. In dry-run mode (default), shows files
#   that would be quarantined. With -f, moves them to a timestamped quarantine directory.
#   Also audits/fixes permissions.
#
# Usage:
#   ./quarantine-php.sh [-r root_wordpress_dir] [-d] [-f] [-v]
#
# Options:
#   -r    Root WordPress directory (default: /var/www/www.aab-ai.org/wordpress)
#   -d    Dry run (default: true)
#   -f    Force move (overrides dry run)
#   -v    Verbose output
#
# Author: Ronald Reck
# Copyright 2025 Association for the Advancement of Business AI (AABAI)
# License: MIT

# Defaults
ROOT_DIR="/var/www/www.aab-ai.org/wordpress"
REL_PATH="wp-content/uploads"
QUARANTINE_DIR="/root/quarantine"
VERBOSE=false
DRYRUN=true
FORCE=false

# Usage
usage() {
    echo "Usage: $0 [-r root_wordpress_dir] [-d] [-f] [-v]"
    exit 1
}

# Parse args
while getopts "r:dfv" opt; do
    case $opt in
        r) ROOT_DIR="$OPTARG" ;;
        d) DRYRUN=true ;;
        f) DRYRUN=false; FORCE=true ;;
        v) VERBOSE=true ;;
        *) usage ;;
    esac
done

TARGET_DIR="$ROOT_DIR/$REL_PATH"

# Check target
[ -d "$TARGET_DIR" ] || { echo "Error: $TARGET_DIR not found. Check -r root path."; exit 1; }

# Quarantine path
EPOCH_DIR="$QUARANTINE_DIR/$(date +%s)"
[ "$FORCE" = true ] && mkdir -p "$EPOCH_DIR"

# Find .php files
PHP_FILES=$(find "$TARGET_DIR" -type f -name "*.php")

if [ -z "$PHP_FILES" ]; then
    $VERBOSE && echo "No PHP files found in $TARGET_DIR"
    exit 0
fi

# Dry run or force
if [ "$DRYRUN" = true ]; then
    echo "Dry run: the following files would be moved to $EPOCH_DIR"
    echo "$PHP_FILES"
else
    echo "$PHP_FILES" | while IFS= read -r file; do
        mv "$file" "$EPOCH_DIR" || exit 1
        $VERBOSE && echo "Moved $file"
    done
    find "$TARGET_DIR" -type f -name "*.php" -delete
fi

# Permissions audit + fix
fix_perm() {
    find "$1" -type "$2" ! -perm "$3" -exec chmod "$3" {} + | {
        changed=0
        while IFS= read -r _; do changed=1; done
        return $changed
    }
}

fix_perm "$TARGET_DIR" d 755 && $VERBOSE && echo "Fixed dir perms"
fix_perm "$TARGET_DIR" f 644 && $VERBOSE && echo "Fixed file perms"
