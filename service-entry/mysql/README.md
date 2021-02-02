1. Create a new MySQL server with docker which is outside of the mesh as a external resource
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

2. Prepare the MySQL script to geneate the traffic from Pod to external MySQL server (traffic.sql)
```sql
drop procedure if exists dummy;

delimiter $$

create procedure dummy()
begin
  declare cnt int default 1;

  while cnt <= 10000 do
  --loop
    select current_time(), user(), database() from dual;
    show variables like "version";
    show variables like "hostname";
    do sleep(1);
    set cnt = cnt + 1;
  end while;
  -- end loop
end $$

delimiter ;

call dummy();
```

3. Verify and run the above script traffic.sql with MySQL client to make sure the user account "john" can connect remotely.
   ~ change the IP address for your MySQL server
```bash
docker run \
 --name mysql-client -it --rm \
 -v $(pwd)/traffic.sql:/root/traffic.sql \
 mysql:8 \
 mysql \
   -h 192.168.28.130 -P 3306 -D test \
   -u john -p'passw0rd' -e 'source /root/traffic.sql'
```

4. Create the MySQL client deployment in mesh with the Istio injection, 
the pod should able to query the server even without defining any Service Entry or Workload Entry.
```bash
kubectl apply -f <(istioctl kube-inject -f client-deployment.yml)
```

5. (Unmanaged VM) Create the Virtual Service and Service Entry which capture the traffic to the original MySQL IP address.
```bash
kubectl apply -f server-service-entry-only.yml
```

6. (Managed VM) Create the Virtual Service, Service Entry, and Workload Entry.
```bash
kubectl apply -f server-workload-entry.yml
```
