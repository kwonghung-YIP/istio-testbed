
```bash
docker run \
  --name mysql-8 -d --rm \
  --hostname mysql-8-container \
  -p 3306:3306 \
  -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
  -e MYSQL_DATABASE=test \
  -e MYSQL_USER=john \
  -e MYSQL_PASSWORD=passw0rd \
  mysql:8
```

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
 --name mysql-client -it --rm \
 -v $(pwd)/traffic.sh:/root/traffic.sh \
 -v $(pwd)/traffic.sql:/root/traffic.sql \
 mysql:8 bash /root/traffic.sh
 ```
 
