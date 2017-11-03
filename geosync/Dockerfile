# à partir d'une image ubuntu, à cause de owncloudcmd
FROM ubuntu:latest

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# install locales
# https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-docker-container
RUN apt-get update && \
    apt-get install -y locales locales-all \
 && rm -rf /var/lib/apt/lists/*
RUN update-locale LC_ALL=C.UTF-8 LANG=fr_FR.UTF-8
ENV LC_ALL='C.UTF-8' LANG='fr_FR.UTF-8'

# environment variables
ENV GEO_USER_PASS  georchestra-ouvert

# install packages
RUN apt-get update && apt-get install -y \
    cron \
    python \
    python-dev \
    python-owslib \
    python-lxml \
    libxml2-utils \
    ca-certificates \
    curl \
    gdal-bin \
    postgis \
    default-jre-headless \
    libsaxonb-java \
    dbview \
    owncloud-client-cmd \
    colordiff less vim openssh-client \
 && rm -rf /var/lib/apt/lists/*

# bash_profile and bashrc 
ADD dot.bash_profile /root/.bash_profile
ADD dot.bashrc /root/.bashrc

# create geosync group users
RUN groupadd --gid 991 geosync

# add geosync user : georchestra-ouvert
ADD georchestra-ouvert /home/georchestra-ouvert
RUN useradd -s /bin/bash \
            -p $(echo "print crypt("${GEO_USER_PASS:-password}", "salt")" | perl) \
            --uid 992 --gid 991 georchestra-ouvert
RUN chown -R georchestra-ouvert:geosync /home/georchestra-ouvert
RUN chmod 600 /home/georchestra-ouvert/.pgpass
RUN adduser georchestra-ouvert crontab

# add geosync user georchestra-restreint
ADD georchestra-restreint /home/georchestra-restreint
RUN useradd -s /bin/bash \
            -p $(echo "print crypt("${GEO_USER_PASS:-password}", "salt")" | perl) \
            --uid 993 --gid 991 georchestra-restreint
RUN chown -R georchestra-restreint:geosync /home/georchestra-restreint
RUN chmod 600 /home/georchestra-restreint/.pgpass
RUN adduser georchestra-restreint crontab

# add geosync source code
COPY geosync /usr/local/geosync

# correction de bug debian/owncloudcmd
#RUN mkdir /etc/owncloud-client
#ADD sync-exclude.lst /etc/owncloud-client/sync-exclude.lst

# entrypoint
COPY entry.sh /

ENTRYPOINT ["/entry.sh"]

# Start cron daemon in the foreground
CMD ["/usr/sbin/cron","-f"]

