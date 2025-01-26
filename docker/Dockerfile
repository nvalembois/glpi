################# Sources
FROM docker.io/library/alpine:3.21.2 AS source

ARG GLPI_VERSION=10.0.17
ARG DATAINJECTION_VERSION=2.14.1

# User and packages
RUN set -e \
 && adduser -u 10001 --no-create-home --disabled-password --home /var/www/glpi glpi \
 && install -d -o root -g glpi -m 0755 /var/www \
 && apk add --update --no-cache jq curl

# Download gpli
RUN set -e \
 && REPO=glpi-project/glpi \
 && VERSION=${GLPI_VERSION} \
 && ARCHIVE=glpi-${VERSION}.tgz \
 && JQ_FILTER='.assets[] | select(.name=="'${ARCHIVE}'") | .browser_download_url' \
 && URL="https://api.github.com/repos/${REPO}/releases/tags/${VERSION}" \
 && SRC=$(curl -sL "${URL}" | jq -r "$JQ_FILTER" ) \
 && curl -sLO "${SRC}" \
 && tar xavf "${ARCHIVE}" -C /var/www \
 && rm "${ARCHIVE}"

# Download datainjection
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
 
# Configure GPLI data pathes for docker
ADD downstream.php /var/www/glpi/inc/downstream.php
 
# Fix file owner and permissions
RUN chown -R root:glpi /var/www/glpi \
 && chmod -R o-rwx,g-w,g+rX /var/www/glpi

################### Init
FROM docker.io/library/alpine:3.21.2 AS init

ARG PHP_MAJOR_VERSION=83
ARG TIMEZONE=Europe/Paris

# User and packages
RUN set - \
 && adduser -u 10001 --no-create-home --disabled-password --home /var/www/glpi glpi \
 && apk add --update --no-cache \
       php${PHP_MAJOR_VERSION} \
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
       php${PHP_MAJOR_VERSION}-zip
# Configure PHP
RUN set -e \
 && sed -e 's,^\s*;*\s*date.timezone\s.*$,date.timezone = '${TIMEZONE}',' \
        -i /etc/php${PHP_MAJOR_VERSION}/php.ini \
 && sed -e 's,session.cookie_httponly = *\(on\|off\|true\|false\|0\|1\)\?,session.cookie_httponly = on,gi' \
        -i /etc/php${PHP_MAJOR_VERSION}/php.ini
# Add GLPI and plugins
COPY --from=source /var/www /var/www
# Add init script
ADD init.sh /init/
        
USER 10001
WORKDIR /var/www/glpi

ENTRYPOINT [ "" ]
CMD [ "/bin/sh", "/init/init.sh" ]

################## php-fpm
FROM init AS php-fpm

ARG PHP_MAJOR_VERSION=83
USER root

# Packages
RUN set -e \
 && apk add --update --no-cache php${PHP_MAJOR_VERSION}-fpm
# Configure php-fpm
# remove GLPI install scripts
# Remove php-fpm default pool
RUN set -e \
 && sed -i 's,^\s*;*\s*error_log\s.*$,error_log = /dev/stderr,' /etc/php${PHP_MAJOR_VERSION}/php-fpm.conf \
 && rm /etc/php${PHP_MAJOR_VERSION}/php-fpm.d/www.conf \
 && rm -r /init /var/www/glpi/install
# Add php-fpm GLPI pool
ADD glpi.conf /etc/php${PHP_MAJOR_VERSION}/php-fpm.d/

USER 10001
ENTRYPOINT [ "" ]
CMD [ "/usr/sbin/php-fpm${PHP_MAJOR_VERSION}", "-F" ]

################## cron
FROM init AS cron

USER root

# User and packages
# Configure cron
# remove GLPI install scripts
RUN set -e \
 && apk add --update --no-cache supercronic \
 && echo "*/2 * * * * /usr/bin/php /var/www/glpi/front/cron.php &>/dev/null" > /etc/crontab-glpi \
 && rm -r /init /var/www/glpi/install

USER 10001
ENTRYPOINT [ "" ]
CMD [ "/usr/bin/supercronic", "/etc/crontab-glpi" ]
        
################## nginx
FROM docker.io/nginxinc/nginx-unprivileged:1.27-alpine AS nginx

USER root

# Add GLPI public files 
COPY --from=php-fpm /var/www/glpi/public /var/www/glpi/
# Add GLPI site
ADD default.conf /etc/nginx/conf.d/
# Configure nginx
# Fix GLPI and nginx config files ownership and permissions
RUN set -e \
 && sed -e 's,error_log.*,\1error_log  /dev/stderr notice;,' \
        -e 's,access_log.*,access_log  /dev/stdout  main;,' \
        -i  /etc/nginx/nginx.conf \
 && chown -R root:nginx /var/www/glpi /etc/nginx/conf.d/\
 && chmod -R o-rwx,g-w,g+rX /var/www/glpi /etc/nginx/conf.d/

USER 101
WORKDIR /var/www/glpi

ENTRYPOINT [ "" ]
CMD [ "/sbin/nginx", "-g", "daemon off;" ]
