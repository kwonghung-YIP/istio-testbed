
```bash
docker run \
  --name mysql-5 -d --rm \
  --hostname mysql-5-container \
  -p 3306:3306 \
  -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
  -e MYSQL_DATABASE=test \
  -e MYSQL_USER=john \
  -e MYSQL_PASSWORD=passw0rd \
  mysql:5
```

```bash
docker run \
  --name mysql-8 -d --rm \
  --hostname mysql-8-container \
  -p 3307:3306 \
  -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
  -e MYSQL_DATABASE=test \
  -e MYSQL_USER=john \
  -e MYSQL_PASSWORD=passw0rd \
  mysql:8
```

```bash
#!/bin/bash

while :
do
  mysql \
    -h 192.168.28.134 -P 3306 -D test \
    -u john -p'passw0rd' -e 'source /root/mysql/traffic.sql'
  sleep 1
done
```

```sql
select current_time(), user(), database();
show variables like "version";
show variables like "hostname";
```

```bash
docker run \
  --name mysql-client -it --rm \
  -v $(pwd)/traffic.sh:/root/mysql/traffic.sh \
  -v $(pwd)/traffic.sql:/root/mysql/traffic.sql \
  mysql:8 bash /root/mysql/traffic.sh
```

```bash
kubectl apply -f <(istioctl kube-inject -f client-deployment.yml)
```

```bash
```
 
