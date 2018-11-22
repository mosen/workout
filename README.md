# Overview

This repository contains the contents for "Monitoring DevOps WOD".

## Docker

This container is based on a CentOS 7 image and contains a complete
Zabbix stack (server, web, agent) and Postgres instance.



### Building

You can build the container by changing to the root of this git repository,
and entering the following command:

	$ docker build . --tag workout/zabbix:1.0

### Running

#### With Docker

To run the container with defaults, and a persistent database volume:

    $ docker run -p 8080:80 -p 10051:10051 -v /var/lib/postgresql/data workout/zabbix:1.0
	
You can then access your Zabbix instance by opening your browser to http://localhost:8080/zabbix/

#### Build Arguments

The `Dockerfile` takes the following as build arguments:

- `POSTGRES_VERSION`: The version of PostgreSQL to build with.
- `ZABBIX_VERSION`: The version of Zabbix to build with.
	
### Runtime Environment Variables

- `POSTGRES_USER` (default: **zabbix**) The postgres user to create and grant access to the zabbix database.
- `POSTGRES_PASSWORD` (default: **zabbix**) The password for the postgres user.
- `POSTGRES_DATABASE` (default: **zabbix**) The database created at start time.
- `TZ` (default: **UTC**) The timezone to use for PHP.
- TODO: `ZABBIX_USER` (default: **Admin**) The zabbix admin user.
- TODO: `ZABBIX_PASSWORD` (default: **zabbix**) The zabbix admin password.


## Ansible Playbooks

These playbooks make use of the `zabbix_host` and `zabbix_template` modules.

These modules require **zabbix-api >= 0.5.3**.

### testhost-playbook.yml

This playbook contains a single task, which is to create a test host on a Zabbix instance.

### export-playbook.yml

This playbook contains task(s) to export a single template from a Zabbix host into the same directory.


