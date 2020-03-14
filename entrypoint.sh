#!/bin/bash
set -e

#DATABASE INIT/CONFIG
mysql -h $MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -h $MYSQL_PORT_3306_TCP_ADDR -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER' IDENTIFIED BY '$DB_PW';"

# Create necessary directories and own them to www-data
cd $CA_PROVIDENCE_DIR/media/collectiveaccess && mkdir -p tilepics images
cd $CA_PAWTUCKET_DIR && chown www-data:www-data . -R && chmod -R u+rX .
cd $CA_PROVIDENCE_DIR && chown www-data:www-data . -R && chmod -R u+rX .

if [ "$(ls -A /$CA_PROVIDENCE_DIR/app/conf/)" ]; then
	# Config files already exist
else
	cp /var/ca/providence/conf/* /$CA_PROVIDENCE_DIR/app/conf/
fi

sweep() {
	local ca="$ca"
	sed -i -e "/__CA_DB_HOST__/s/'.*'/$MYSQL_PORT_3306_TCP_ADDR/" setup.php
	sed -i -e "/__CA_DB_USER__/s/'.*'/$DB_USER/" setup.php
	sed -i -e "/__CA_DB_PASSWORD__/s/'.*'/$DB_PW/" setup.php
	sed -i -e "/__CA_DB_DATABASE__/s/'.*'/$DB_NAME/" setup.php

	if [[ "$DISPLAY_NAME" != "" ]];then
		sed -i -e "/__CA_APP_DISPLAY_NAME__/s/'.*'/$DISPLAY_NAME/" setup.php
	fi
	if [[ "$ADMIN_EMAIL" != "" ]];then
		sed -i -e "/__CA_ADMIN_EMAIL__/s/'.*'/$ADMIN_EMAIL/" setup.php
	fi
	if [[ "$SMTP_SERVER" != "" ]];then
		sed -i -e "/__CA_SMTP_SERVER__/s/'.*'/$SMTP_SERVER/g" setup.php
	fi
}
cd $CA_PROVIDENCE_DIR
ca='pro'
sweep $ca
cd $CA_PAWTUCKET_DIR
ca='paw'
sweep $ca

exec "$@"
