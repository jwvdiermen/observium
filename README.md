Observium
====

Dockerfile for Observium with embedded MariaDB (MySQL) Database

Observium is an autodiscovering network monitoring platform supporting a wide range of hardware platforms and operating systems

---
###Forked from

Zuhkov <zuhkov@gmail.com>

---
Usage example
===
###Needed directories on host:
- config
- logs
- rrd

```
docker run -d \
	-v /hostDir/config:/config \
	-v /hostDir/logs:/opt/observium/logs \
	-v /hostDir/rrd:/opt/observium/rrd \
	-p 80:80 \
	-e POLLER=24 \
	--name observium \
	seti/observium
```
###with custom timezone
```
docker run -d \
	-v /hostDir/config:/config \
	-v /hostDir/logs:/opt/observium/logs \
	-v /hostDir/rrd:/opt/observium/rrd \
	-p 80:80 \
	-e TZ="America/Chicago" \
	-e POLLER=24 \
	--name observium \
	seti/observium
```

Browse to ```http://your-host-ip``` and login with user and password `observium`

---
Environment Vars
===
- **POLLER**: Set poller count. Defaults to `16`
- **TZ**: Set timezone. Defaults to `UTC`

---
Credits
===

Observium Community is an open source project and is copyright Observium Limited

This docker image is built upon the baseimage made by phusion
