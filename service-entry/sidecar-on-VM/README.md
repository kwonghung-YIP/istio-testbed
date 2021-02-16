```bash
docker run \
  --name tomcat7 -d --rm \
  --hostname tomcat7-host1 \
  -p 8080:8080 \
  tomcat:7-jdk8
```
