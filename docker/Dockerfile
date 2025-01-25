FROM docker.io/nginxinc/nginx-unprivileged:1.27-alpine

USER root

ARG VERSION_GLPI=10.0.17
ARG VERSION_DATAINJECTION=2.14.1
ARG VERSION_PHP_MAJOR=83
ARG TIMEZONE=Europe/Paris

RUN set -e \
 && php=php${VERSION_PHP_MAJOR} \
 && apk add --update --no-cache \
        ${php} \
        ${php}-fpm \
        ${php}-bcmath \
        ${php}-bz2 \
        ${php}-curl \
        ${php}-ctype \
        ${php}-dom \
        ${php}-exif \
        ${php}-fileinfo \
        ${php}-gd \
        ${php}-iconv \
        ${php}-imap \
        ${php}-intl \
        ${php}-ldap \
        ${php}-mbstring \
        ${php}-mysqli \
        ${php}-opcache \
        ${php}-phar \
        ${php}-session \
        ${php}-simplexml \
        ${php}-sodium \
        ${php}-xml \
        ${php}-xmlreader \
        ${php}-xmlwriter \
        ${php}-zip \
        jq \
        curl \
        supercronic

RUN set -e \
 && adduser -u 10001 --no-create-home --disabled-password --home /var/www/glpi glpi \
 && install -d -o root -g nginx -m 0755 /var/www \
 && REPO=glpi-project/glpi \
 && VERSION=${VERSION_GLPI} \
 && ARCHIVE=glpi-${VERSION}.tgz \
 && JQ_FILTER='.assets[] | select(.name=="'${ARCHIVE}'") | .browser_download_url' \
 && URL="https://api.github.com/repos/${REPO}/releases/tags/${VERSION}" \
 && SRC=$(curl -sL "${URL}" | jq -r "$JQ_FILTER" ) \
 && curl -sLO "${SRC}" \
 && tar xavf "${ARCHIVE}" -C /var/www \
 && rm "${ARCHIVE}"

RUN set -e \
 && REPO=pluginsGLPI/datainjection \
 && VERSION=${VERSION_DATAINJECTION}
 && ARCHIVE=glpi-datainjection-${VERSION}.tar.bz2 \
 && JQ_FILTER='.assets[] | select(.name=="'${ARCHIVE}'") | .browser_download_url' \
 && URL="https://api.github.com/repos/${REPO}/releases/tags/${VERSION}" \
 && SRC=$(curl -sL "${URL}" | jq -r "$JQ_FILTER" ) \
 && curl -sLO "${SRC}" \
 && tar xavf "${ARCHIVE}" -C /var/www/glpi/plugins \
 && rm "${ARCHIVE}"

RUN set -e \
 && php=php${VERSION_PHP_MAJOR} \
 && sed -e 's,^\s*;*\s*date.timezone\s.*$,date.timezone = '${TIMEZONE}',' \
        -i /etc/${php}/php.ini \
 && sed -i 's,^\s*;*\s*error_log\s.*$,error_log = /dev/stderr,' /etc/${php}/php-fpm.conf \
 && rm /etc/${php}/php-fpm.d/www.conf \
 && sed -i 's,session.cookie_httponly = *\(on\|off\|true\|false\|0\|1\)\?,session.cookie_httponly = on,gi' /etc/${php}/php.ini \
 && echo "*/2 * * * * /usr/bin/php /var/www/html/glpi/front/cron.php &>/dev/null" > /etc/crontab-glpi \
 && chown -R glpi:nginx /var/www/glpi \
 && chmod -R o-rwx,g-w,g+rX /var/www/glpi \
 && install -d -o nginx -g nginx -m 0750 /data \
       /data/config /data/files /data/log /data/marketplace /data/dumps \
       /data/files/_cron /data/files/_graphs /data/files/_lock \
       /data/files/_pictures /data/files/_plugins /data/files/_rss \
       /data/files/_sessions /data/files/_tmp /data/files/_uploads \
       /data/files/_cache \
 && sed -e 's,error_log.*,\1error_log  /dev/stderr notice;,' \
        -e 's,access_log.*,access_log  /dev/stdout  main;,' \
        -i  /etc/nginx/nginx.conf

ADD default.conf /etc/nginx/conf.d/
ADD glpi.conf /etc/php83/php-fpm.d/
ADD downstream.php /var/www/glpi/inc/downstream.php
ADD init.sh /
           
USER 101

ENTRYPOINT [ "" ]
CMD [ "/bin/sh" ]

WORKDIR /var/www/glpi
