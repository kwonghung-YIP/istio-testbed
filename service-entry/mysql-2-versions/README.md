This scenario assume that you are working on the MySQL server upgrade:

* we have a MySQL client running in the mesh that connect to an external MySQL server running on a standalone docker host,
* the current MySQL server now is version 5, and we want to route 10% of traffic to MySQL 8,
* without changing the MySQL client setting, we use Virtual Service, Service Entry, and Workload Entry to hijack the connection and route the traffic to new DB.   

1. Run a MySQL 5 database on the standalone docker host, which is listening to the port 3306:

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

2. Run a MySQL 8 database on the same standalone docker host, which is listening to another port 3307:

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

3. Prepare a bash script for the MySQL client, which keeps making new connections to the external MySQL DB.

```bash
#!/bin/bash

while :
do
  mysql \
    -h docker-mysql-v5.intra.hksfc.org.hk -P 3306 -D test \
    -u john -p'passw0rd' -e 'source /root/mysql/traffic.sql'
  sleep 1
done
```

4. The simple SQL to query the user and database info.

```sql
select current_time(), user(), database();
show variables like "version";
show variables like "hostname";
```

5. Test the bash script and the sample SQL with docker. 

```bash
docker run \
  --name mysql-client -it --rm \
  -v $(pwd)/traffic.sh:/root/mysql/traffic.sh \
  -v $(pwd)/traffic.sql:/root/mysql/traffic.sql \
  mysql:8 bash /root/mysql/traffic.sh
```

6. Deploy the MySQL client into the mesh, without other configuration, 100% of traffic will go to the MySQL server 5 (3306 port).

```bash
kubectl apply -f <(istioctl kube-inject -f client-deployment.yml)
```

7. Apply the Virtual Service and Service Entry, and using the endpoints to route 10% traffic to MySQL 8. (unmanaged VM)

* the Virtual Service is for capture the traffic to the IP (Virtual Service.hosts => 192.168.28.134).
* the Destination of the Virtual Service refers to the Service Entry (Virtual Service.destination.host => Service Entry.hosts).
* the endpoints' address property determine the traffic either go to MySQL 5 or 8. (Service Entry.endpoints.address => 192.168.28.134:3306 (90%), 192.168.28.134:3307 (10%)

```bash
kubectl apply -f with-endpoints.yml
```

8. Clearup the setting in Step 7 

9. Apply the Virtual Service, Service Entry, and Workload, and using the endpoints to route 10% traffic to MySQL 8. (managed VM but missing the VM's sidecar)

* the Virtual Service is for capture the traffic to the IP (Virtual Service.hosts => 192.168.28.134).
* the Destination of the Virtual Service refers to the Service Entry (Virtual Service.destination.host => Service Entry.hosts).
* the Service Entry's workloadSelector property defines how to match with the Workload Entries using labels (Service Entry.workloadSelector.labels => Workload Entry.labels)
* the Workload Entries' address property determine the traffic either go to MySQL 5 or 8. (Workload Entry.address => 192.168.28.134:3306 (90%), 192.168.28.134:3307 (10%)

```bash
kubectl apply -f with-workloadSelector.yml
```
 
