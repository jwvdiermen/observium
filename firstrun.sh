#!/bin/bash

atd

# Check if PHP database config exists. If not, copy in the default config
if [ -f /config/config.php ]; then
	echo "Using existing PHP database config file."
	echo "/opt/observium/discovery.php -u" | at -M now + 1 minute
else
	echo "Loading PHP config from default."
	mkdir -p /config/databases
	cp /opt/observium/config.php.default /config/config.php
	chown nobody:users /config/config.php
fi

ln -s /config/config.php /opt/observium/config.php
chown nobody:users -R /opt/observium
chmod 755 -R /opt/observium

if [ -f /etc/container_environment/TZ ] ; then
	sed -i "s#\;date\.timezone\ \=#date\.timezone\ \=\ $TZ#g" /etc/php5/cli/php.ini
	sed -i "s#\;date\.timezone\ \=#date\.timezone\ \=\ $TZ#g" /etc/php5/apache2/php.ini
else
	echo "Timezone not specified by environment variable"
	echo UTC > /etc/container_environment/TZ
	sed -i "s#\;date\.timezone\ \=#date\.timezone\ \=\ UTC#g" /etc/php5/cli/php.ini
	sed -i "s#\;date\.timezone\ \=#date\.timezone\ \=\ UTC#g" /etc/php5/apache2/php.ini
fi

if [ ! -f /etc/container_environment/POLLER ] ; then
	POLLER=16
fi
sed -i "s/#PC#/$POLLER/g" /etc/cron.d/observium

DB_TYPE=${DB_TYPE:-}
DB_HOST=${DB_HOST:-}
DB_PORT=${DB_PORT:-}
DB_NAME=${DB_NAME:-}
DB_USER=${DB_USER:-}
DB_PASS=${DB_PASS:-}
DB_POOL=${DB_POOL:-10}

if [ -n "${MYSQL_PORT_3306_TCP_ADDR}" ]; then
	DB_TYPE=${DB_TYPE:-mysql}
	DB_HOST=${DB_HOST:-${MYSQL_PORT_3306_TCP_ADDR}}
	DB_PORT=${DB_PORT:-${MYSQL_PORT_3306_TCP_PORT}}

	# support for linked sameersbn/mysql image
	DB_USER=${DB_USER:-${MYSQL_ENV_DB_USER}}
	DB_PASS=${DB_PASS:-${MYSQL_ENV_DB_PASS}}
	DB_NAME=${DB_NAME:-${MYSQL_ENV_DB_NAME}}	
	
	# support for linked orchardup/mysql and enturylink/mysql image
	# also supports official mysql image
	DB_USER=${DB_USER:-${MYSQL_ENV_MYSQL_USER}}
	DB_PASS=${DB_PASS:-${MYSQL_ENV_MYSQL_PASSWORD}}
	DB_NAME=${DB_NAME:-${MYSQL_ENV_MYSQL_DATABASE}}
fi

if [ -z "${DB_HOST}" ]; then
  echo "ERROR: "
  echo "  Please configure the database connection."
  echo "  Cannot continue without a database. Aborting..."
  exit 1
fi

# use default port number if it is still not set
case "${DB_TYPE}" in
  mysql) DB_PORT=${DB_PORT:-3306} ;;
  *)
    echo "ERROR: "
    echo "  Please specify the database type in use via the DB_TYPE configuration option."
    echo "  Accepted value \"mysql\". Aborting..."
    exit 1
    ;;
esac

# set default user and database
DB_USER=${DB_USER:-root}
DB_NAME=${DB_NAME:-gitlabhq_production}

sed -i -e 's/PASSWORD/'$DB_PASS'/g' /config/config.php
sed -i -e 's/USERNAME/'$DB_USER'/g' /config/config.php
sed -i -e "s/$config['db_name'] = 'observium';/$config['db_name'] = '$DB_NAME';/g" /config/config.php