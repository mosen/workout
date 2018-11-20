#!/bin/bash

PGSQL_DATABASE=${PGSQL_DATABASE:-"zabbix"}
PGSQL_USER=${PGSQL_USER:-"zabbix"}
PGSQL_PASSWORD=${PGSQL_PASSWORD:-"zabbix"}

# DO NOT RELEASE WITH THIS
echo "php_value date.timezone Australia/Sydney" >> /etc/httpd/conf.d/zabbix.conf

# Initialise PGDATA
su postgres -c "/usr/bin/initdb --username=\"$PGSQL_USER\" --pwfile=<(echo \"$PGSQL_PASSWORD\")"

# internal start of server in order to allow set-up using psql-client
# does not listen on external TCP/IP and waits until start finishes
echo "Starting postgres to initialise the database..."
PGUSER="${PGUSER:-$PGSQL_USER}" \
su postgres -c "pg_ctl -D \"$PGDATA\" -o \"-c listen_addresses=''\" -w start"

export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"
psql=( psql -v ON_ERROR_STOP=1 --username "$PGSQL_USER" --no-password )

"${psql[@]}" --dbname postgres --set db="$PGSQL_DATABASE" <<-'EOSQL'
	CREATE DATABASE :"db" ;
EOSQL

psql+=( --dbname "$PGSQL_DATABASE" )
zcat /usr/share/doc/zabbix-server-pgsql*/create.sql.gz | "${psql[@]}"

echo "Stopping postgres so that supervisord can take over..."
PGUSER="${PGUSER:-$POSTGRES_USER}" \
su postgres -c "pg_ctl -D \"$PGDATA\" -m fast -w stop"

unset PGPASSWORD

echo "DBPassword=${PGSQL_PASSWORD}" >> /etc/zabbix/zabbix_server.conf


/usr/bin/supervisord -n -c /etc/supervisord.conf
