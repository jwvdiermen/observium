Observium
====

Observium is an autodiscovering network monitoring platform supporting a wide range of hardware platforms and operating systems

---
###Originally forked from

Zuhkov <zuhkov@gmail.com>

---
Usage example
===
###Needed directories on host:
- data
- mysql

### with sameersbn/mysql as database

```
NAME="observium"
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
docker run -d -m 1g \
	-v $DIR/mysql:/var/lib/mysql \
	-e DB_USER=$NAME \
	-e DB_PASS=observiumpwd \
	-e DB_NAME=$NAME \
	--name $NAME-db \
	sameersbn/mysql:latest
```

```
NAME="observium"
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
docker run -d \
	-v $DIR/data:/data \
	-p 80:80 \
	-e TZ="Europe/Austria" \
	--link $NAME-db:mysql \
	-e POLLER=24 \
	--name $NAME \
	seti/observium
```

Browse to ```http://your-host-ip``` and login with user and password `observium`

---
Environment Vars
===
- **POLLER**: Set poller count. Defaults to `16`
- **TZ**: Set timezone. Defaults to `UTC`

---
Convert from older version with integrated DB to new container
===
- we use "ocontainer" as container name. replace it with your name.
```
mkdir mysql
docker exec -it ocontainer mysqldump observium > mysql/observiumdb.sql
mkdir data
mv config data/ && mv rrd data/ && mv logs data/
chown nobody:users data -R
```
- now run your db container, we use the example from above, then run this command (observium-db is the container name)
```
echo "#!/bin/bash" > mysql/import.sh
echo "mysql -u observium -pobserviumpwd observium < /var/lib/mysql/observiumdb.sql" >> mysql/import.sh
chmod 0755 mysql/import.sh
docker exec -it observium-db bash /var/lib/mysql/import.sh
rm -f mysql/import.sh mysql/observiumdb.sql
```
- now run your observium container, like the example from above

---
Credits
===

Observium Community is an open source project and is copyright Observium Limited

This docker image is built upon the baseimage made by phusion
