FROM tutum/lamp:latest

ENV DVWS_DOMAIN="dvws.wallarm-demo.com"

RUN apt-get update \
    && apt-get install -y git curl

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer
RUN chmod +x /usr/bin/composer

# RUN git clone https://github.com/vgartvich-wallarm/dvws.git /app
COPY . /app
COPY conf/setup_dvws.sh /app
COPY conf/supervisord-ws-server.conf /etc/supervisor/conf.d/supervisord-ws-server.conf
RUN /app/setup_dvws.sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && sed -i 's!Listen 80!Listen 81!g' /etc/apache2/ports.conf \
    && echo "export DVWS_DOMAIN=$(echo $DVWS_DOMAIN)" >> /etc/apache2/envvars \
    && sed -i 's!80!81!g' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's!80!81!g' /etc/apache2/sites-enabled/000-default.conf \
    && sed -i "s#SetEnvIf x-forwarded-proto https HTTPS=on#SetEnvIf x-forwarded-proto https HTTPS=on\nSetEnv DVWS_DOMAIN=$(echo $DVWS_DOMAIN)#g" /etc/apache2/sites-available/000-default.conf \
    && sed -i "s#SetEnvIf x-forwarded-proto https HTTPS=on#SetEnvIf x-forwarded-proto https HTTPS=on\nSetEnv DVWS_DOMAIN=$(echo $DVWS_DOMAIN)#g" /etc/apache2/sites-enabled/000-default.conf

EXPOSE 81 8080

ONBUILD RUN cd /app \
            && composer update --no-interaction

CMD ["/run.sh"]
