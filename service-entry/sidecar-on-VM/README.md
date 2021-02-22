```bash
docker run \
  --name tomcat7 -d --rm \
  --hostname tomcat7-host1 \
  -p 8080:8080 \
  tomcat:7-jdk8
```

```bash
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -days 30 \
  -keyout apache/server.key -out apache/server.crt -config apache/selfsign-request.cfg

docker stop apache-httpd

docker run \
  --name apache-httpd -d --rm \
  --hostname apache-node01 \
  -p 8080:80 -p 8443:443 \
  -v $(pwd)/apache/echo-node01.html:/usr/local/apache2/htdocs/echo.html \
  -v $(pwd)/apache/httpd.conf:/usr/local/apache2/conf/httpd.conf \
  -v $(pwd)/apache/server.key:/usr/local/apache2/conf/server.key \
  -v $(pwd)/apache/server.crt:/usr/local/apache2/conf/server.crt \
  httpd:2.4
```

```bash
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -days 30 \
  -keyout apache/server.key -out apache/server.crt -config apache/selfsign-request.cfg

docker stop apache-httpd

docker run \
  --name apache-httpd -d --rm \
  --hostname apache-node02 \
  -p 8080:80 -p 8443:443 \
  -v $(pwd)/apache/echo-node02.html:/usr/local/apache2/htdocs/echo.html \
  -v $(pwd)/apache/httpd.conf:/usr/local/apache2/conf/httpd.conf \
  -v $(pwd)/apache/server.key:/usr/local/apache2/conf/server.key \
  -v $(pwd)/apache/server.crt:/usr/local/apache2/conf/server.crt \
  httpd:2.4
```

```bash
docker run \
  --name nginx -d --rm \
  --hostname nginx-node02 \
  -p 8080:80 -p 8443:443 \
  -v $(pwd)/apache/echo-node02.html:/usr/share/nginx/html/echo.html \
  -v $(pwd)/nginx/default-ssl.conf:/etc/nginx/conf.d/default-ssl.conf \
  -v $(pwd)/apache/server.key:/etc/nginx/certs/server.key \
  -v $(pwd)/apache/server.crt:/etc/nginx/certs/server.crt \
  nginx:1.19.7
```
istioctl install \
  -f istio-profile.yaml \
  --set values.pilot.env.PILOT_ENABLE_WORKLOAD_ENTRY_AUTOREGISTRATION=true \
  --set values.pilot.env.PILOT_ENABLE_WORKLOAD_ENTRY_HEALTHCHECKS=true

```bash
VM_APP="ext-apache"
VM_NAMESPACE="default"
WORK_DIR="<a certificate working directory>"
SERVICE_ACCOUNT="<name of the Kubernetes service account you want to use for your VM>"
# Customize values for multi-cluster/multi-network as needed
CLUSTER_NETWORK="kube-network"
VM_NETWORK="vm-network"
CLUSTER="cluster1"
```

${HOME}/istio-1.9.0/samples/multicluster/gen-eastwest-gateway.sh \
--mesh mesh1 --cluster "${CLUSTER}" --network "${CLUSTER_NETWORK}"

istioctl install -f eastwest-ingress-gateway.yaml
kubectl apply -f expose-istiod.yaml
kubectl apply -f expose-services.yaml

kubectl create serviceaccount "vm-apache" -n "default"

```bash
rm -rf "${HOME}/istio-vm"
mkdir -p "${HOME}/istio-vm"
istioctl x workload entry configure -f workload-group.yaml -o "${HOME}/istio-vm" --clusterID "cluster1" --autoregister
```

istioctl kube-inject -f ${HOME}/istio-1.9.0/samples/helloworld/helloworld.yaml

```bash
kubectl apply -f <(istioctl kube-inject -f curl-deployment.yaml)
```

[Envoy Request Flow](https://www.envoyproxy.io/docs/envoy/latest/intro/life_of_a_request#request-flow)
