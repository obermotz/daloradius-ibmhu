FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_RFC3339="1970-01-01T00:00:00Z"
ARG COMMIT
ARG VERSION

LABEL org.opencontainers.image.ref.name="daloradius-ibmhu" \
      org.opencontainers.image.created=$BUILD_RFC3339 \
      org.opencontainers.image.authors="obermotz" \
      org.opencontainers.image.documentation="https://github.com/obermotz/daloradius-ibmhu/blob/master/README.md" \
      org.opencontainers.image.description="Docker image with freeradius, daloradius, apache2, php. You need to supply your own MariaDB-Server." \
      org.opencontainers.image.licenses="GPLv3" \
      org.opencontainers.image.source="https://github.com/obermotz/daloradius-ibmhu" \
      org.opencontainers.image.revision=$COMMIT \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.url="https://hub.docker.com/r/obermotz/daloradius-ibmhu"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

STOPSIGNAL SIGKILL

ENV MYSQL_USER=radius
ENV MYSQL_PASSWORD=dalodbpass
ENV MYSQL_HOST=localhost
ENV MYSQL_PORT=3306
ENV MYSQL_DATABASE=radius
ENV TZ=Europe/Budapest

RUN apt-get update \
 && apt-get install --yes \
                    apt-utils \
                    tzdata \
                    apache2 \
                    libapache2-mod-php \
                    cron \
                    freeradius-config \
                    freeradius-utils \
                    freeradius \
                    freeradius-common \
                    freeradius-mysql \
                    net-tools \
                    php \
                    php-common \
                    php-gd \
                    php-curl \
                    php-mail \
                    php-mail-mime \
                    php-db \
                    php-mysql \
                    mariadb-client \
                    libmysqlclient-dev \
                    supervisor \
                    unzip \
                    wget \
                    vim \
                    iputils-ping\
                    curl\
                    iproute2\
                    tcpdump\
                    mc\
                    traceroute\
 && rm -rf /var/lib/apt/lists/*
 
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
 && update-ca-certificates -f \
 && mkdir -p /tmp/pear/cache \
 && wget http://pear.php.net/go-pear.phar \
 && php go-pear.phar \
 && rm go-pear.phar \
 && pear channel-update pear.php.net \
 && pear install -a -f DB \
 && pear install -a -f Mail \
 && pear install -a -f Mail_Mime

ENV DALO_VERSION 1.3

RUN wget https://github.com/lirantal/daloradius/archive/"$DALO_VERSION".zip \
 && unzip "$DALO_VERSION".zip \
 && rm "$DALO_VERSION".zip \
 && rm -rf /var/www/html/index.html \
 && mv daloradius-"$DALO_VERSION"/* daloradius-"$DALO_VERSION"/.gitignore daloradius-"$DALO_VERSION"/.htaccess daloradius-"$DALO_VERSION"/.htpasswd /var/www/html \
 && mv /var/www/html/library/daloradius.conf.php.sample /var/www/html/library/daloradius.conf.php \
 && chown -R www-data:www-data /var/www/html \
 && chmod 644 /var/www/html/library/daloradius.conf.php

EXPOSE 1812 1813 80

COPY files/supervisor-apache2.conf /etc/supervisor/conf.d/apache2.conf
COPY files/supervisor-freeradius.conf /etc/supervisor/conf.d/freeradius.conf
COPY files/supervisor-dalocron.conf /etc/supervisor/conf.d/supervisor-dalocron.conf
COPY files/freeradius-default-site /etc/freeradius/3.0/sites-available/default

COPY files/init.sh /cbs/
COPY files/supervisor.conf /etc/

RUN set -ex \
  # Enable SQL in freeradius
  && sed -i 's|driver = "rlm_sql_null"|driver = "rlm_sql_mysql"|' /etc/freeradius/3.0/mods-available/sql \
  && sed -i 's|dialect = "sqlite"|dialect = "mysql"|' /etc/freeradius/3.0/mods-available/sql \
  && sed -i 's|dialect = ${modules.sql.dialect}|dialect = "mysql"|' /etc/freeradius/3.0/mods-available/sqlcounter \
  && sed -i '/tls {/,/}/s/\(.*\)/#AUTO_COMMENT#&/' /etc/freeradius/3.0/mods-available/sql \
  && sed -i 's|#\s*read_clients = yes|read_clients = yes|' /etc/freeradius/3.0/mods-available/sql \
  && ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/sql \
  && ln -s /etc/freeradius/3.0/mods-available/sqlcounter /etc/freeradius/3.0/mods-enabled/sqlcounter \
  && sed -i 's|instantiate {|instantiate {\nsql|' /etc/freeradius/3.0/radiusd.conf \
  # Enable status in freeadius
  && ln -s /etc/freeradius/3.0/sites-available/status /etc/freeradius/3.0/sites-enabled/status

CMD ["sh", "/cbs/init.sh"]

#CMD ["sh", "-c", "while :; do echo 'just looping here... nothing special'; sleep 10; done"]

