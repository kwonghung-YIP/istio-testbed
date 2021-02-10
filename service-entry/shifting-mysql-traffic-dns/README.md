### This example illustrates how to shift tcp connections to a newer version of MySQL database that is running outside of the mesh with Workload Entry and Destination Rule for simulating the scenario of upgrading database

The following is this example setup: 

![example setup](/service-entry/shifting-mysql-traffic-dns/shifting-mysql-traffic-dns.jpg)


* a MySQL client POD running within the mesh keeps making connections to an external MySQL database which version is 5,
* a MySQL 5 database running on a docker host **docker-mysql-v5.hung.org.hk**, which is the existing version using by the client,
* a MySQL 8 database running on a docker host **docker-mysql-v8.hung.org.hk**, which is the new version to be upgraded,
* a Service Entry and 2 Workload Entries to capture the outbound traffic to 2 MySQL databases,
* a Virtual Service and Destination Rule to control 80% and 20% traffic to MySQL 5 and MySQL 8 DB, 

the routing takes place in the sidecar and without any changes in the MySQL client, and following are steps to set up this example.

### 0. First, we install istio with a customized IstioOperator, also enable Kiali, Grafana, Prometheus and Jaeger for demo

```bash
istioctl install -f istio-profile-demo.yaml

# enable other components 
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/kiali.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/jaeger.yaml
```

### 1. Spin up a MySQL 5 database on the external docker host docker-mysql-v5.hung.org.hk (192.168.28.110):

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

### 2. Spin up a MySQL 8 database on another external docker host docker-mysql-v8.hung.org.hk (192.168.28.111):

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

### 3. Prepare the traffic.sh for the MySQL client, it makes a new database connection to MySQL 5 for every second:

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

### 4. The traffic.sql query the database version and other info from the connected MySQL DB:

```sql
select current_time(), user(), database();
show variables like "version";
show variables like "hostname";
```

### 5. Before the POD, test the traffic.sh and traffic.sql with docker: 

```bash
docker run \
  --name mysql-client -it --rm \
  -v $(pwd)/traffic.sh:/root/mysql/traffic.sh \
  -v $(pwd)/traffic.sql:/root/mysql/traffic.sql \
  mysql:8 bash /root/mysql/traffic.sh
```

### 6. Deploy the MySQL client POD into the mesh, without any Istio rule or component, the POD still can get connect to the MySQL 5 DB and ALL the traffic are straight to docker-mysql-v5.hung.org.hk:

```bash
kubectl apply -f <(istioctl kube-inject -f mysql-client-deployment.yaml)
```

### 7. Apply the Service Entry and Workload Entry to capture the outbound traffic to MySQL 5 and MySQL 8 DB, without the further control, traffic are evenly route to both DB.

How's the Service Entry and Workload Entry interrupt the outbound tcp connection to MySQL servers:

* the MySQL client makes tcp connection to the host **docker-mysql-v5.hung.org.hk:3306**, the sidecar looks for a Service Entry which **hosts** and **ports** properties are matched,
* once the **mysql-svc-entry** Service Entry is located, the sidecar uses the labels (database: mysql) defined in **workloadSelector** property to look for the Workload Entry which label are matched, the **location** propery must be **MESH_INTERNAL** for using the workloadSelector,
* 2 Workload Entries **mysql-v5-workload-entry** and **mysql-v8-workload-entry** are matched with the workloadSelector property in Service Entry,
* the **address** property in the Workload Entry decides the destination host and port of the traffic, which are **docker-mysql-v5.hung.org.hk** or **docker-mysl-v8.hung.org.hk**
* the **resolustion** property in Service Entry should be **DNS** in order to resolve from DNS server


```bash
kubectl apply -f service-and-workload-entries.yaml
```

### 8. Apply the Virtual Service, Destination Rule and Subsets to divide 80% and 20% of the traffic to MySQL 5 and MySQL 8 DB, further trafficPolicy can be applied for further control the outbound connection.

How's the Destination and Subsets are applied: 

* the MySQL client makes connection to the host **docker-mysql-v5.hung.org.hk**, the sidecar looks for a Virtual Service which **hosts** property is matached,
* the **destination.host** property of the routing rule in Virtual Service looks for a Service Entry which **hosts** property is matched,
* with the **destination.host** and **subset** properties defined in the routing rules in Virtual Service, corresponding Destination rule and subsets are applied,
* the **labels** property defined in the Destination rule's subset matches with the **labels** property defined in the Workload Entry

```bash
kubectl apply -f destination-rules.yaml
```
