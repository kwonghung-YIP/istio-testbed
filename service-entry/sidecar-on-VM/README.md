Reference to [Virtual Machine Installation] in Istio 1.9.0 (https://istio.io/latest/docs/setup/install/virtual-machine/)

## 1. Install Istio and eastwest ingress gateway

```bash
VM_APP="ext-apache"
VM_NAMESPACE="default"
WORK_DIR="${HOME}/istio-vm"
SERVICE_ACCOUNT="vm-apache"
# Customize values for multi-cluster/multi-network as needed
CLUSTER_NETWORK="kube-network"
VM_NETWORK="vm-network"
CLUSTER="cluster1"
```

### 2. Install the Istio, the istio-profile.yaml combine the demo profile and multi-network profile, it also enabled the workload entry auto-registration and healthcheck feature 
```bash
istioctl install \
  -f istio-profile.yaml \
  --set values.pilot.env.PILOT_ENABLE_WORKLOAD_ENTRY_AUTOREGISTRATION=true \
  --set values.pilot.env.PILOT_ENABLE_WORKLOAD_ENTRY_HEALTHCHECKS=true


# Install other components

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/addons/kiali.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/addons/grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.9/samples/addons/jaeger.yaml
```

### 3. Install the eastwest ingress gateway to expose the istiod
```bash
#${HOME}/istio-1.9.0/samples/multicluster/gen-eastwest-gateway.sh \
#--mesh mesh1 --cluster "${CLUSTER}" --network "${CLUSTER_NETWORK}" > eastwest-ingreess-gateway.yaml

istioctl install -f eastwest-ingress-gateway.yaml
```

### 4. Expose the istiod and other services to the managed VM.
```bash
kubectl apply -f expose-istiod.yaml
kubectl apply -f expose-services.yaml
```

### 5. Create the serviceAccount 
```bash
#kubectl create serviceaccount "${SERVICE_ACCOUNT}" -n "${VM_NAMESPACE}"
kubectl create serviceaccount "vm-apache" -n "default"
```

### 6. Create the Workload Group and geneate the files to transfer to the Virtual Machine
```bash
rm -rf "${HOME}/istio-vm"
mkdir -p "${HOME}/istio-vm"
istioctl x workload entry configure -f workload-group.yaml -o "${HOME}/istio-vm" --clusterID "cluster1" --autoregister
echo "ISTIO_AGENT_FLAGS=\"--log_caller=all --log_output_level=all:debug --proxyLogLevel=debug\"" >> ${HOME}/istio-vm/cluster.env
```


```bash
#!/bin/bash

WORK_DIR="${HOME}/istio-vm-sidecar"

rm -rf ${WORK_DIR}
mkdir ${WORK_DIR}
scp hung@istio-control-plane-v19:~/istio-vm/* ${WORK_DIR}

sudo mkdir -p /etc/certs
sudo mkdir -p /var/run/secrets/tokens

sudo cp ${WORK_DIR}/root-cert.pem /etc/certs/root-cert.pem
sudo cp ${WORK_DIR}/istio-token /var/run/secrets/tokens/istio-token

curl -LO https://storage.googleapis.com/istio-release/releases/1.9.0/deb/istio-sidecar.deb
sudo dpkg -i istio-sidecar.deb

sudo cp ${WORK_DIR}/cluster.env /var/lib/istio/envoy/cluster.env
sudo cp ${WORK_DIR}/mesh.yaml /etc/istio/config/mesh

#sudo sh -c 'cat $(eval echo ${HOME})/istio-vm-sidecar/hosts >> /etc/hosts'

sudo mkdir -p /etc/istio/proxy
sudo chown -R istio-proxy /var/lib/istio /etc/certs /etc/istio/proxy /etc/istio/config /var/run/secrets /etc/certs/root-cert.pem

#sudo systemctl stop istio
sudo systemctl start istio
tail /var/log/istio/istio.err.log /var/log/istio/istio.log -Fq -n 100
curl -s localhost:15000/config_dump | istioctl proxy-config clusters --file -
```

```bash
openssl req -x509 -newkey rsa:4096 -sha256 -nodes -days 30 \
  -keyout apache/server.key -out apache/server.crt -config apache/selfsign-request.cfg

docker rm -f apache-httpd

docker run \
  --name apache-httpd -d --restart=always \
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

docker rm -f apache-httpd

docker run \
  --name apache-httpd -d --restart=always \
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

```bash
#kubectl apply -f <(istioctl kube-inject -f ${HOME}/istio-1.9.0/samples/helloworld/helloworld.yaml)
kubectl apply -f <(istioctl kube-inject -f curl-deployment.yaml)
```

### References
* [Envoy Request Flow](https://www.envoyproxy.io/docs/envoy/latest/intro/life_of_a_request#request-flow)
