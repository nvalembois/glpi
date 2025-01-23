FROM docker.io/nginxinc/nginx-unprivileged:1.27-alpine

USER root

ARG VERSION_GLPI=10.0.17
ARG VERSION_PHP_MAJOR=83
ARG TIMEZOME=Europe/Paris

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
        cronie \ 
 && echo "date.timezone = \"$TIMEZONE\"" > /etc/${php}/php-fpm.d/www.conf \
 && echo "date.timezone = \"$TIMEZONE\"" > /etc/${php}/conf.d/timezone.ini \
 && sed -i 's,session.cookie_httponly = *\(on\|off\|true\|false\|0\|1\)\?,session.cookie_httponly = on,gi' /etc/${php}/php.ini \
 && adduser -u 10001 --no-create-home --disabled-password --home /var/www/html/glpi glpi \
 && mkdir -p /var/www/html/glpi \
    SRC_GLPI=$(curl -s https://api.github.com/repos/glpi-project/glpi/releases/tags/${VERSION_GLPI} | jq .assets[0].browser_download_url | tr -d \") \
    curl -L ${SRC_GLPI} | tar xzvf - -C /var/www/html
 && chown -R glpi:nginx /var/www \
 && chmod -R o-rwx,g-w,g+rX /var/www

COPY --from=build --chown=aeneria:nginx /var/www/app/public /var/www/app/public

ADD nginx.conf /etc/nginx/nginx.conf
ADD default.conf /etc/nginx/conf.d/

USER nginx

ENTRYPOINT [ "" ]
CMD [ "nginx" ]

WORKDIR /var/www