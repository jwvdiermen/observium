# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.16
MAINTAINER Seti <seti@setadesign.net>

# Set correct environment variables.
ENV HOME=/root \
	DEBIAN_FRONTEND=noninteractive \
	LC_ALL=C.UTF-8 \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8

COPY init.sh /etc/my_init.d/init.sh
COPY apache2.sh /etc/service/apache2/run
COPY cron-observium /etc/cron.d/observium
#COPY initdb.sh /etc/my_init.d/initdb.sh

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

RUN \
	usermod -u 99 nobody && usermod -g 100 nobody && usermod -d /home nobody && \
	chown -R nobody:users /home && \
	rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh && \
	locale-gen de_DE.UTF-8 && locale-gen en_US.UTF-8 && \
	apt-get update -q && \
    apt-get install -y --no-install-recommends \
		libapache2-mod-php5 php5-cli php5-json wget unzip software-properties-common pwgen \
		php5-mysql php5-gd php5-mcrypt python-mysqldb rrdtool subversion whois mtr-tiny at \
		nmap ipmitool graphviz imagemagick php5-snmp php-pear snmp graphviz fping libvirt-bin && \
		apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
	mkdir -p /data/logs /data/rrd /data/config && \
    cd /opt && \
    wget http://www.observium.org/observium-community-latest.tar.gz && \
    tar zxvf observium-community-latest.tar.gz && \
    rm observium-community-latest.tar.gz && \
	php5enmod mcrypt && a2enmod rewrite && \
	rm /etc/apache2/sites-available/default-ssl.conf && \
	rm -Rf /var/www && chmod +x /etc/service/apache2/run && \
	chmod +x /etc/my_init.d/init.sh && \
    chown -R nobody:users /opt/observium && \
    chmod 755 -R /opt/observium && \
    chown -R nobody:users /data/config && \
    chmod 755 -R /data/config && echo www-data > /etc/container_environment/APACHE_RUN_USER && \
    echo www-data > /etc/container_environment/APACHE_RUN_GROUP && \
    echo /var/log/apache2 > /etc/container_environment/APACHE_LOG_DIR && \
    echo /var/lock/apache2 > /etc/container_environment/APACHE_LOCK_DIR && \
    echo /var/run/apache2.pid > /etc/container_environment/APACHE_PID_FILE && \
    echo /var/run/apache2 > /etc/container_environment/APACHE_RUN_DIR && \
    chown -R www-data:www-data /var/log/apache2 && \
    ln -s /opt/observium/html /var/www

COPY apache2.conf ports.conf /etc/apache2/
COPY apache-observium /etc/apache2/sites-available/000-default.conf

EXPOSE 80/tcp

#VOLUME ["/config","/opt/observium/logs","/opt/observium/rrd"]
VOLUME ["/data"]
