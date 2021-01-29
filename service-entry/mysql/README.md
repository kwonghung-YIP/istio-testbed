1. Create a new MySQL server with docker which is outside of the mesh
```bash
docker run \
  --name mysql -d --rm \
  -p 3306:3306 \
  -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
  -e MYSQL_DATABASE=test \
  -e MYSQL_USER=john \
  -e MYSQL_PASSWORD=passw0rd \
  mysql:8
```

2. MySQL script to generate the traffic (traffic.sql)
```sql
drop procedure if exists dummy;

delimiter $$

create procedure dummy()
begin
  declare cnt int default 1;

  while cnt <= 10 do
    select current_time() from dual;
    do sleep(1);
    set cnt = cnt + 1;
  end while;
end $$

delimiter ;

call dummy();
```

3. Test the traffic.sql with a MySQL CLI, change the IP address for your MySQL server
```bash
docker run \
 --name mysql-client -it --rm \
 -v $(pwd)/test.sql:/root/traffic.sql \
 mysql:8 \
 mysql \
   -h 192.168.28.130 -P 3306 -D test \
   -u john -p'passw0rd' -e 'source /root/traffic.sql'
```

4. Deploy the MySQL client workload in mesh with the Istio injection
```bash
kubectl apply -f <(istioctl kube-inject -f mysql-client-deployment.yml)
```
