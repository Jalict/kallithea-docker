#!/bin/bash
set -e

CONFIG_FILE="/opt/kallithea/my.ini"
DB_FILE="/opt/kallithea/kallithea.db"
REPO_ROOT=${REPO_ROOT:-/opt/repos}
ADMIN_USER=${ADMIN_USER:-admin}
ADMIN_PASS=${ADMIN_PASS:-password}
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@example.com}

# Activate virtualenv
. /opt/venv/bin/activate

# Create config if not exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Creating default config file..."
  kallithea-cli config-create "$CONFIG_FILE" http_server=waitress host=0.0.0.0 port=5000
fi

# Create repos folder if not exists
mkdir -p "$REPO_ROOT"

#ui language
if [ -n "$KALLITHEA_LANG" ]; then
    echo "Setting language to ${KALLITHEA_LANG}"
    sed -i "s/^lang =/lang = ${KALLITHEA_LANG}/1" $CONFIG_FILE
fi

# Initialize DB if not already present
if [ ! -f "$DB_FILE" ]; then
  echo "SQLite DB not found at $DB_FILE, initializing..."
  kallithea-cli db-create -c "$CONFIG_FILE" \
    --user="$ADMIN_USER" \
    --password="$ADMIN_PASS" \
    --email="$ADMIN_EMAIL" \
    --repos="$REPO_ROOT" \
    --force-yes
else
  echo "Database exists at $DB_FILE, skipping initialization."
fi


# Run Kallithea server
echo "Starting Kallithea..."
exec gearbox serve -c "$CONFIG_FILE"

