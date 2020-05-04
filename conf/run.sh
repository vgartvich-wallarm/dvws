#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"
    /create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi

sed -i 's!Listen 80!Listen 81!g' /etc/apache2/ports.conf
echo "export DVWS_DOMAIN=$(echo $DVWS_DOMAIN)" >> /etc/apache2/envvars
sed -i 's!80!81!g' /etc/apache2/sites-available/000-default.conf
sed -i 's!80!81!g' /etc/apache2/sites-enabled/000-default.conf
sed -i "s#SetEnvIf x-forwarded-proto https HTTPS=on#SetEnvIf x-forwarded-proto https HTTPS=on\n\tSetEnv DVWS_DOMAIN=$(echo $DVWS_DOMAIN)#g" /etc/apache2/sites-available/000-default.conf
sed -i "s#SetEnvIf x-forwarded-proto https HTTPS=on#SetEnvIf x-forwarded-proto https HTTPS=on\n\tSetEnv DVWS_DOMAIN=$(echo $DVWS_DOMAIN)#g" /etc/apache2/sites-enabled/000-default.conf

exec supervisord -n
