#!/bin/sh
set -e

install -d -m 0750 /data \
  /data/config /data/files /data/log /data/marketplace /data/dumps \
  /data/files/_cron /data/files/_graphs /data/files/_lock \
  /data/files/_pictures /data/files/_plugins /data/files/_rss \
  /data/files/_sessions /data/files/_tmp /data/files/_uploads \
  /data/files/_cache

php bin/console --no-interaction glpi:system:check_requirements
php bin/console --no-interaction db:configure \
    --reconfigure \
    --db-host="${MARIADB_HOST:-localhost}" \
    --db-port="${MARIADB_PORT:-3306}" \
    --db-name="${MARIADB_DATABASE:-glpi}" \
    --db-user="${MARIADB_USER:-glpi}" \
    --db-password="${MARIADB_PASSWORD:-glpi}"
php bin/console --no-interaction db:update \
    --${GLPI_TELEMETRY:-enable}-telemetry
