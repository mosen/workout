#!/bin/bash

DB_NAME=${DB_NAME:-"zabbix"}
DB_USER=${DB_USER:-"zabbix"}
DB_PASSWORD=${DB_PASSWORD:-"zabbix"}
TZ=${TZ:-"UTC"}

echo "Setting PHP timezone to ${TZ}"
echo "date.timezone=\"${TZ}\"" > /etc/php.d/timezone.ini

# Initialise PGDATA if required
if [[ ! -r "/var/lib/postgresql/data/postgresql.conf" ]]; then
    su postgres -c "/usr/bin/initdb --username=\"$DB_USER\" --pwfile=<(echo \"$DB_USER\")"

    # internal start of server in order to allow set-up using psql-client
    # does not listen on external TCP/IP and waits until start finishes
    echo "Starting postgres to initialise the database..."
    PGUSER="${PGUSER:-$DB_USER}" \
    su postgres -c "pg_ctl -D \"$PGDATA\" -o \"-c listen_addresses=''\" -w start"

    export PGPASSWORD="${PGPASSWORD:-$DB_PASSWORD}"
    psql=( psql -v ON_ERROR_STOP=1 --username "$DB_USER" --no-password )

    "${psql[@]}" --dbname postgres --set db="$DB_NAME" <<-'EOSQL'
        CREATE DATABASE :"db" ;
EOSQL

    psql+=( --dbname "$DB_NAME" )
    zcat /usr/share/doc/zabbix-server-pgsql*/create.sql.gz | "${psql[@]}"

    echo "Stopping postgres so that supervisord can take over..."
    su postgres -c "pg_ctl -D \"$PGDATA\" -m fast -w stop"

    unset PGPASSWORD
else
    echo "Database already initialised, not creating new schema..."
fi

echo "Generating configuration..."
/usr/sbin/confd -onetime -backend env

echo "Starting supervisord..."
/usr/bin/supervisord -n -c /etc/supervisord.conf