FROM centos:7.5.1804
LABEL org.label-schema.name = "Zabbix Omnibus Workout of the Day"

ARG POSTGRES_VERSION=9.2.24
ARG ZABBIX_VERSION=4.0.1
ARG CONFD_VERSION=0.16.0

ENV CONFD_SHA256 255d2559f3824dd64df059bdc533fd6b697c070db603c76aaf8d1d5e6b0cc334

RUN echo "Building with PostgreSQL Version: ${POSTGRES_VERSION}"
RUN echo "Building with Zabbix Version: ${ZABBIX_VERSION}"

ENV PGDATA /var/lib/postgresql/data

RUN rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-7 \
	https://repo.zabbix.com/RPM-GPG-KEY-ZABBIX \
	https://repo.zabbix.com/RPM-GPG-KEY-ZABBIX-A14FE591 \
	https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7

# Needs EPEL just for supervisord
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
RUN yum-config-manager --enable rhel-7-server-optional-rpms

# Necessary to get SQL schema because default is nodocs which wont install the .sql.gz
RUN yum -y --setopt tsflags= install zabbix-server-pgsql

RUN yum install -y \
	postgresql-server-${POSTGRES_VERSION} \
	postgresql-${POSTGRES_VERSION} \
	zabbix-web-pgsql-${ZABBIX_VERSION} \
	zabbix-agent-${ZABBIX_VERSION} \
	supervisor

# PostgreSQL - Portions are from the docker hub `Dockerfile` for PgSQL v11
RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 2777 /var/run/postgresql
RUN mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 777 "$PGDATA"
VOLUME ["/var/lib/postgresql/data", "/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts"]

# confd
RUN curl -L -o /usr/sbin/confd https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64
RUN chmod +x /usr/sbin/confd
RUN mkdir -p /etc/confd/{conf.d,templates}
RUN echo "$CONFD_SHA256 /usr/sbin/confd" | sha256sum -c
COPY ./docker/confd /etc/confd

# Use more container friendly defaults for server configuration file.
COPY ./docker/zabbix_server.docker.conf /etc/zabbix/zabbix_server.conf

# init related
COPY ./docker/supervisord.conf /etc/supervisord.conf
COPY ./docker/entry.sh /entry.sh
RUN chmod 755 /entry.sh

# Ports

# Zabbix-Web
EXPOSE 80
EXPOSE 443

# If external pgsql access required
# EXPOSE 5432

# Zabbix-Server
EXPOSE 10051

CMD ["/bin/bash", "/entry.sh"]
