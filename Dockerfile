FROM tutum/lamp:latest

ENV DVWS_DOMAIN="dvws.local"

RUN apt-get update \
    && apt-get install -y git curl

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer
RUN chmod +x /usr/bin/composer

COPY . /app
COPY conf/supervisord-ws-server.conf /etc/supervisor/conf.d/supervisord-ws-server.conf
RUN /app/conf/setup_dvws.sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY conf/run.sh /run.sh

EXPOSE 81 8080

ONBUILD RUN cd /app \
            && composer update --no-interaction

CMD ["/run.sh"]
