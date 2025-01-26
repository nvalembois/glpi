#!/bin/sh
set -e

for d in config files log marketplace dumps \
  files/_cron files/_graphs files/_lock \
  files/_pictures files/_plugins files/_rss \
  files/_sessions files/_tmp files/_uploads \
  files/_cache
do
  [[ -d /data/$d ]] || mkdir /data/$d
done

php bin/console --no-interaction system:check_requirements
if [[ ! -f /data/config/glpicrypt.key ]] # install not executed
then
  php bin/console --no-interaction db:install \
      --reconfigure \
      --db-host="${MARIADB_HOST:-localhost}" \
      --db-port="${MARIADB_PORT:-3306}" \
      --db-name="${MARIADB_DATABASE:-glpi}" \
      --db-user="${MARIADB_USER:-glpi}" \
      --db-password="${MARIADB_PASSWORD:-glpi}" \
      --${GLPI_TELEMETRY:-enable}-telemetry
else
  php bin/console --no-interaction db:configure \
      --reconfigure \
      --db-host="${MARIADB_HOST:-localhost}" \
      --db-port="${MARIADB_PORT:-3306}" \
      --db-name="${MARIADB_DATABASE:-glpi}" \
      --db-user="${MARIADB_USER:-glpi}" \
      --db-password="${MARIADB_PASSWORD:-glpi}"
  php bin/console --no-interaction db:update \
      --${GLPI_TELEMETRY:-enable}-telemetry
fi

