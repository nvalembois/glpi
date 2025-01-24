FROM docker.io/nginxinc/nginx-unprivileged:1.27-alpine

USER root

ARG VERSION_GLPI=10.0.17
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
        ${php}-dom \
        ${php}-fileinfo \
        ${php}-gd \
        ${php}-imap \
        ${php}-intl \
        ${php}-ldap \
        ${php}-mbstring \
        ${php}-mysqli \
        ${php}-session \
        ${php}-simplexml \
        ${php}-xml \
        ${php}-xmlreader \
        ${php}-xmlwriter \
        ${php}-zip \
        jq \
        curl \
        supercronic
RUN set -e \
 && adduser -u 10001 --no-create-home --disabled-password --home /var/www/html/glpi glpi \
 && install -d -o glpi -g nginx -m 0755 /var/www/html \
 && SRC_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/tags/${VERSION_GLPI} | jq -r .assets[0].browser_download_url) \
 && curl -sL ${SRC_GLPI} | tar xzvf - -C /var/www/html
RUN set -e \
 && php=php${VERSION_PHP_MAJOR} \
 && echo 'date.timezone = "'$TIMEZONE'"' >> /etc/${php}/php.ini \
 && echo 'date.timezone = "'$TIMEZONE'"' >> /etc/${php}/conf.d/timezone.ini \
 && sed -i 's,^\s*;*\s*error_log\s.*$,error_log = /dev/stderr,' /etc/${php}/php-fpm.conf \
 && echo 'access.log = /dev/stdout' >>/etc/${php}/php-fpm.d/www.conf \
 && echo 'slowlog = /dev/stdout' >>/etc/${php}/php-fpm.d/www.conf \
 && echo 'php_admin_value[error_log] = /dev/stderr' >>/etc/${php}/php-fpm.d/www.conf \
 && sed -e 's,user\s,;user ,' \
        -e 's,group\s,;group ,' \
        -e 's,listen\s.*,listen = /run/php/php-fpm.sock,' \
        -i  /etc/${php}/php-fpm.d/www.conf \
 && sed -i 's,session.cookie_httponly = *\(on\|off\|true\|false\|0\|1\)\?,session.cookie_httponly = on,gi' /etc/${php}/php.ini \
 && echo "*/2 * * * * /usr/bin/php /var/www/html/glpi/front/cron.php &>/dev/null" > /etc/crontab-glpi \
 && chown -R glpi:nginx /var/www \
 && install -d -o nginx -g nginx -m 0750 /data \
 && chmod -R o-rwx,g-w,g+rX /var/www \
 && sed -e 's,error_log.*,\1error_log  /dev/stderr notice;,' \
        -e 's,access_log.*,access_log  /dev/stdout  main;,' \
        -i  /etc/nginx/nginx.conf
#           && mkdir -p /var/www/html/glpi \
# && sed -i 's,^\s*;*\s*error_log\s.*$,error_log = /data/log/phpfpm.error.log,' /etc/${php}/php-fpm.conf \
# && echo 'access.log = /data/log/phpfpm-$pool.access.log' >>/etc/${php}/php-fpm.d/www.conf \
# && echo 'slowlog = /data/log/phpfpm-$pool.slowlog.log' >>/etc/${php}/php-fpm.d/www.conf \
# && echo 'php_admin_value[error_log] = /data/log/phpfpm-$pool.error.log' >>/etc/${php}/php-fpm.d/www.conf \

ADD default.conf /etc/nginx/conf.d/
ADD downstream.php /var/www/html/glpi/inc/downstream.php
ADD init.sh /
           
USER 101

ENTRYPOINT [ "" ]
CMD [ "/bin/sh" ]

WORKDIR /var/www
