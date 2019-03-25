#
# Dockerfile for the geOrchestra openldap service
#

FROM debian:stretch

ENV OPENLDAP_VERSION 2.4.44
ENV RUN_AS_UID 101
ENV RUN_AS_GID 101

# set timezone
RUN echo $TZ > /etc/timezone && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        slapd=${OPENLDAP_VERSION}*
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*

RUN mv /etc/ldap /etc/ldap.dist

COPY docker/modules/ /etc/ldap.dist/modules

# RUN apt-get update && \
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ldap-utils procps
#    rm -rf /var/lib/apt/lists/*

# add packages for geosync
#RUN apt-get update && \
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python python-ldap cron sasl2-bin && \
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python python-ldap cron

# bug... sasl2-bin ne peut plus être installé en même temps que les autres paquets
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y sasl2-bin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# prepare georchestra users
USER openldap
ADD groupofmembers.ldif /etc/ldap.dist/modules/
ADD docker/indexes.ldif /tmp/
ADD memberof.ldif /tmp/
ADD georchestra.ldif /tmp/

# change default testadmin password
ADD testadmin.ldif /tmp/

# prepare entrypoint
USER root
RUN mkdir /docker-entrypoint.d
ADD docker/docker-entrypoint.d/* /docker-entrypoint.d/
ADD docker/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.d/*

# add ldif files which will be integrated by docker-entrypoint.d
RUN mkdir                 /tmp/LDAP
ADD cn-config.ldif        /tmp/LDAP/cn-config.ldif
ADD open-user.ldif        /tmp/LDAP/open-user.ldif
ADD rsct-user.ldif        /tmp/LDAP/rsct-user.ldif
ADD open-user-groups.ldif /tmp/LDAP/open-user-groups.ldif
ADD rsct-user-groups.ldif /tmp/LDAP/rsct-user-groups.ldif

# configure saslauth
ADD saslauthd      /etc/default/saslauthd
ADD saslauthd.conf /etc/saslauthd.conf

# add configuration files for LDAP
ADD slapd.conf     /tmp/LDAP/slapd.conf
ADD ldap.conf      /tmp/LDAP/ldap.conf

# openldap must be in sasl group
RUN adduser openldap sasl

# create a log directory for georchestra
RUN mkdir /var/log/georchestra

# root will integrate AD users in georchestra LDAP
ADD dot.ldap.conf   /root/.ldap.conf
ADD ad2ldap_sync.py /root/ad2ldap_sync.py
RUN chmod +x        /root/ad2ldap_sync.py

ADD root_crontab /var/spool/cron/crontabs/root
RUN chmod 0600   /var/spool/cron/crontabs/root

EXPOSE 389

VOLUME ["/etc/ldap", "/var/lib/ldap"]

# start.sh will start the container
ADD start.sh /root/
RUN chmod +x /root/start.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD ["/root/start.sh"]
#CMD [ "sh", "-c", "exec slapd -d 32768 -u ${RUN_AS_UID} -g ${RUN_AS_GID}" ]

HEALTHCHECK --interval=30s --timeout=10s \
  CMD ldapsearch \
      -D "cn=admin,dc=georchestra,dc=org" \
      -w "${SLAPD_PASSWORD}" \
      -b "dc=georchestra,dc=org" \
      "cn=geoserver_privileged_user,ou=users,dc=georchestra,dc=org"
