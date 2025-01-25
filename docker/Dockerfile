FROM docker.io/nginxinc/nginx-unprivileged:1.27-alpine

USER root

ARG GLPI_VERSION=10.0.17
ARG DATAINJECTION_VERSION=2.14.1
ARG PHP_MAJOR_VERSION=83
ARG TIMEZONE=Europe/Paris

RUN set -e \
 && apk add --update --no-cache \
        php${PHP_MAJOR_VERSION} \
        php${PHP_MAJOR_VERSION}-fpm \
        php${PHP_MAJOR_VERSION}-bcmath \
        php${PHP_MAJOR_VERSION}-bz2 \
        php${PHP_MAJOR_VERSION}-curl \
        php${PHP_MAJOR_VERSION}-ctype \
        php${PHP_MAJOR_VERSION}-dom \
        php${PHP_MAJOR_VERSION}-exif \
        php${PHP_MAJOR_VERSION}-fileinfo \
        php${PHP_MAJOR_VERSION}-gd \
        php${PHP_MAJOR_VERSION}-iconv \
        php${PHP_MAJOR_VERSION}-imap \
        php${PHP_MAJOR_VERSION}-intl \
        php${PHP_MAJOR_VERSION}-ldap \
        php${PHP_MAJOR_VERSION}-mbstring \
        php${PHP_MAJOR_VERSION}-mysqli \
        php${PHP_MAJOR_VERSION}-opcache \
        php${PHP_MAJOR_VERSION}-phar \
        php${PHP_MAJOR_VERSION}-session \
        php${PHP_MAJOR_VERSION}-simplexml \
        php${PHP_MAJOR_VERSION}-sodium \
        php${PHP_MAJOR_VERSION}-xml \
        php${PHP_MAJOR_VERSION}-xmlreader \
        php${PHP_MAJOR_VERSION}-xmlwriter \
        php${PHP_MAJOR_VERSION}-zip \
        jq \
        curl \
        supercronic

RUN set -e \
 && adduser -u 10001 --no-create-home --disabled-password --home /var/www/glpi glpi \
 && install -d -o root -g nginx -m 0755 /var/www \
 && REPO=glpi-project/glpi \
 && VERSION=${GLPI_VERSION} \
 && ARCHIVE=glpi-${VERSION}.tgz \
 && JQ_FILTER='.assets[] | select(.name=="'${ARCHIVE}'") | .browser_download_url' \
 && URL="https://api.github.com/repos/${REPO}/releases/tags/${VERSION}" \
 && SRC=$(curl -sL "${URL}" | jq -r "$JQ_FILTER" ) \
 && curl -sLO "${SRC}" \
 && tar xavf "${ARCHIVE}" -C /var/www \
 && rm "${ARCHIVE}"

RUN set -e \
 && REPO=pluginsGLPI/datainjection \
 && VERSION=${DATAINJECTION_VERSION} \
 && ARCHIVE=glpi-datainjection-${VERSION}.tar.bz2 \
 && JQ_FILTER='.assets[] | select(.name=="'${ARCHIVE}'") | .browser_download_url' \
 && URL="https://api.github.com/repos/${REPO}/releases/tags/${VERSION}" \
 && SRC=$(curl -sL "${URL}" | jq -r "$JQ_FILTER" ) \
 && curl -sLO "${SRC}" \
 && tar xavf "${ARCHIVE}" -C /var/www/glpi/plugins \
 && rm "${ARCHIVE}"

RUN set -e \
 && sed -e 's,^\s*;*\s*date.timezone\s.*$,date.timezone = '${TIMEZONE}',' \
        -i /etc/php${PHP_MAJOR_VERSION}/php.ini \
 && sed -i 's,^\s*;*\s*error_log\s.*$,error_log = /dev/stderr,' /etc/php${PHP_MAJOR_VERSION}/php-fpm.conf \
 && rm /etc/php${PHP_MAJOR_VERSION}/php-fpm.d/www.conf \
 && sed -e 's,session.cookie_httponly = *\(on\|off\|true\|false\|0\|1\)\?,session.cookie_httponly = on,gi' \
        -i /etc/php${PHP_MAJOR_VERSION}/php.ini \
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
ADD glpi.conf /etc/php${PHP_MAJOR_VERSION}/php-fpm.d/
ADD downstream.php /var/www/glpi/inc/downstream.php
ADD init.sh /
           
USER 101

ENTRYPOINT [ "" ]
CMD [ "/bin/sh" ]

WORKDIR /var/www/glpi
