#!/bin/bash

POSTGRES_DATABASE=${POSTGRES_DATABASE:-"zabbix"}
POSTGRES_USER=${POSTGRES_USER:-"zabbix"}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-"zabbix"}

if [[ ! -z "${TZ}" ]]; then
    echo "Setting PHP timezone to ${TZ}"
    echo "date.timezone=\"${TZ}\"" > /etc/php.d/timezone.ini
fi

# Initialise PGDATA if required
if [[ ! -r "/var/lib/postgresql/data/postgresql.conf" ]]; then
    su postgres -c "/usr/bin/initdb --username=\"$POSTGRES_USER\" --pwfile=<(echo \"$POSTGRES_USER\")"

    # internal start of server in order to allow set-up using psql-client
    # does not listen on external TCP/IP and waits until start finishes
    echo "Starting postgres to initialise the database..."
    PGUSER="${PGUSER:-$POSTGRES_USER}" \
    su postgres -c "pg_ctl -D \"$PGDATA\" -o \"-c listen_addresses=''\" -w start"

    export PGPASSWORD="${PGPASSWORD:-$POSTGRES_PASSWORD}"
    psql=( psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --no-password )

    "${psql[@]}" --dbname postgres --set db="$POSTGRES_DATABASE" <<-'EOSQL'
        CREATE DATABASE :"db" ;
EOSQL

    psql+=( --dbname "$POSTGRES_DATABASE" )
    zcat /usr/share/doc/zabbix-server-pgsql*/create.sql.gz | "${psql[@]}"

    echo "Stopping postgres so that supervisord can take over..."
    PGUSER="${PGUSER:-$POSTGRES_USER}" \
    su postgres -c "pg_ctl -D \"$PGDATA\" -m fast -w stop"
else
    echo "Database already initialised, not creating new schema..."
fi


unset PGPASSWORD

echo "DBPassword=${POSTGRES_PASSWORD}" >> /etc/zabbix/zabbix_server.conf

echo "Starting supervisord..."
/usr/bin/supervisord -n -c /etc/supervisord.conf