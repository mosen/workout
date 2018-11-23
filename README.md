# Overview

This repository contains the contents for "Monitoring DevOps WOD".

## Docker

This container is based on a CentOS 7 image and contains a complete
Zabbix stack (server, web, agent) and Postgres instance.

Configuration is exposed via environmental variables using [confd](https://github.com/kelseyhightower/confd)

### Building

You can build the container by changing to the root of this git repository,
and entering the following command:

	$ docker build . --tag workout/zabbix:1.0

Several build arguments are available to control dependency versions.

### Running

#### With Docker

To run the container with defaults, and a persistent database volume:

    $ docker run -p 8080:80 -p 10051:10051 -v workout-db-data:/var/lib/postgresql/data workout/zabbix:1.0
	
You can then access your Zabbix instance by opening your browser to 
[http://localhost:8080/zabbix](http://localhost:8080/zabbix/)

If you used the default database configuration, you can run through the setup with all the defaults as is.

If you changed the `DB_USER`, `DB_PASSWORD` or `DB_NAME` variables, you will need to enter those connection
details at the relevant step(s).

The default admin credentials are `Admin` / `zabbix`.

#### With Docker Compose

For ease of testing, a `docker-compose.yml` file has also been supplied in the root of this
repository. Just type `docker-compose build` to build, and `docker-compose up` to bring up the container.

#### Build Arguments

Build arguments have been provided to ensure the reproduceability of the container build(s).

The `Dockerfile` takes the following as build arguments:

- `POSTGRES_VERSION`: The version of PostgreSQL to build with.
- `ZABBIX_VERSION`: The version of Zabbix to build with.


### Runtime Environment Variables

- `DB_USER` (default: **zabbix**) The postgres user to create and grant access to the zabbix database.
- `DB_PASSWORD` (default: **zabbix**) The password for the postgres user.
- `DB_NAME` (default: **zabbix**) The database created at start time.
- `TZ` (default: **UTC**) The timezone to use for PHP.

*NOTE:* The env vars `DB_USER` and `DB_PASSWORD` are also written into
the **zabbix_server.conf** file by confd to match the db.

*ALSO:* If you change connection details after the db volume has been initialised,
your connections will fail. 

#### Zabbix Configuration

Most zabbix_server.conf variables are also exposed via **confd** and can be supplied as environmental variables:

- `DEBUGLEVEL`: A debug level from 0-5. Default is 3
- `DB_HOST`: Hostname of a postgres db to connect to other than the one running in the container.
- `DB_PORT`: Database port number if different to default.
- `DB_SCHEMA`: Schema (if using Postgres)
- `DB_SOCKET`: Local socket path (if using MySQL/MariaDB)
- `HISTORY_STORAGEURL`: History storage HTTP[S] URL. 
- `HISTORY_STORAGETYPES`: Comma separated list of value types to be sent to the history storage.
- `HISTORY_STORAGEDATEINDEX`: Enable preprocessing of history values in history storage to store values in different indices based on date.
- `EXPORT_DIR`: Events export directory
- `EXPORT_FILESIZE`: (Default **1G**)

Worker Processes

- `START_POLLERS`: (Default 5)
- `START_IPMIPOLLERS`: (Default 0)
- `START_PREPROCESSORS`: (Default 3)
- `START_TRAPPERS`: (Default 5)
- `START_PINGERS`: (Default 1)
- `START_DISCOVERERS`: (Default 1)
- `START_HTTPPOLLERS`: (Default 1)
- `START_TIMERS`: (Default 1)
- `START_ESCALATORS`: (Default 1) Number of pre-forked instances of escalators.
- `START_ALTERTERS`: (Default 3) Number of pre-forked instances of alerters. 
- `START_JAVAPOLLERS`: (Default 0) Number of pre-forked instances of Java pollers.
- `START_VMWARECOLLECTORS`: (Default 0) Number of pre-forked vmware collector instances.
- `START_SNMPTRAPPER`: (Default 0) If 1, SNMP trapper process is started.
- `START_DBSYNCERS`: (Default 4) Number of pre-forked instances of DB Syncers.


Java Gateway

- `JAVA_GATEWAY`: IP address (or hostname) of Zabbix Java gateway.
- `JAVA_GATEWAYPORT`: (Default 10052) Java gateway port

VMware

- `VMWARE_FREQUENCY`: (Default 60) How often Zabbix will connect to VMware service to obtain a new data.
- `VMWARE_PERFFREQUENCY`: (Default 60) How often Zabbix will connect to VMware service to obtain performance data.
- `VMWARE_CACHESIZE`: (Default **8M**) Size of VMware cache, in bytes.
- `VMWARE_TIMEOUT`: (Default 10) Specifies how many seconds vmware collector waits for response from VMware service.

Cache

- `CACHE_SIZE`: (Default **8M**) Size of configuration cache, in bytes.
- `CACHE_UPDATEFREQUENCY`: (Default 60) How often Zabbix will perform update of configuration cache, in seconds.

History

- `HISTORY_CACHESIZE`: (Default **16M**) Size of history cache, in bytes.
- `HISTORY_INDEXCACHESIZE`: (Default **4M**) Size of history index cache, in bytes.

- `HOUSEKEEPINGFREQUENCY`: (Default 1) How often Zabbix will perform housekeeping procedure (in hours).
- `MAXHOUSEKEEPERDELETE`: (Default 5000) No more than 'MaxHousekeeperDelete' rows will be deleted per one task in one housekeeping cycle.
- `TRENDCACHESIZE`: (Default **4M**) Size of trend cache, in bytes.
- `VALUECACHESIZE`: (Default **8M**) Size of history value cache, in bytes.
- `TIMEOUT`: (Default 4) Specifies how long we wait for agent, SNMP device or external check (in seconds).
- `TRAPPERTIMEOUT`: (Default 300) Specifies how many seconds trapper may spend processing new data.

- `UNREACHABLEPERIOD`: (Default 45) After how many seconds of unreachability treat a host as unavailable.
- `UNAVAILABLEDELAY`: (Default 60) How often host is checked for availability during the unavailability period, in seconds.
- `UNREACHABLEDELAY`: (Default 15) How often host is checked for availability during the unreachability period, in seconds.
- `LOGSLOWQUERIES`: (Default 3000) How long a database query may take before being logged (in milliseconds).

## Ansible Playbooks

These playbooks make use of the `zabbix_host` and `zabbix_template` modules.

These modules require **zabbix-api >= 0.5.3**.

### testhost-playbook.yml

This playbook contains a single task, which is to create a test host on a Zabbix instance.
You can run the playbook by changing into the `ansible-playbooks` directory and executing:

    $ ansible-playbook ./testhost-playbook.yml

### export-playbook.yml

This playbook contains task(s) to export a single template from a Zabbix host into the same directory
as `export_zabbix_agent.template`.

You can run the playbook by changing into the `ansible-playbooks` directory and executing:

    $ ansible-playbook ./export-playbook.yml

