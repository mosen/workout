# Overview

This repository contains the contents for "Monitoring DevOps WOD".

## Docker

### Building

	$ docker build . --tag zabbixwod
	
### Running

    $ docker run -p 8080:80 -p 10051:10051 -v /var/lib/postgresql/data zabbixwod
	
### Environment Variables

- `POSTGRES_USER` (default: **zabbix**) The postgres user to create and grant access to the zabbix database.
- `POSTGRES_PASSWORD` (default: **zabbix**) The password for the postgres user.
- `POSTGRES_DATABASE` (default: **zabbix**) The database created at start time.
- `PHP_TZ` (default: **UTC**) The timezone to use for PHP.
- `ZABBIX_USER` (default: **Admin**) The zabbix admin user.
- `ZABBIX_PASSWORD` (default: **zabbix**) The zabbix admin password.


## Ansible Playbooks

The `zabbix_host` module requires **zabbix-api >= 0.5.3**


