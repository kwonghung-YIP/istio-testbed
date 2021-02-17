```bash
docker run \
  --name tomcat7 -d --rm \
  --hostname tomcat7-host1 \
  -p 8080:8080 \
  tomcat:7-jdk8
```

```bash
docker run \
  --name apache-httpd -d --rm \
  --hostname apache-node01 \
  -p 8080:80 \
  -v $(pwd)/apache/echo-node01.html:/usr/local/apache2/htdocs/echo.html \
  httpd:2.4
```

```bash
docker run \
  --name apache-httpd -d --rm \
  --hostname apache-node02 \
  -p 8080:80 \
  -v $(pwd)/apache/echo-node02.html:/usr/local/apache2/htdocs/echo.html \
  httpd:2.4
```

istioctl install \
  -f istio-profile.yaml \
  --set values.pilot.env.PILOT_ENABLE_WORKLOAD_ENTRY_AUTOREGISTRATION=true \
  --set values.pilot.env.PILOT_ENABLE_WORKLOAD_ENTRY_HEALTHCHECKS=true

VM_APP="tomcat"
VM_NAMESPACE="default"
WORK_DIR="<a certificate working directory>"
SERVICE_ACCOUNT="<name of the Kubernetes service account you want to use for your VM>"
# Customize values for multi-cluster/multi-network as needed
CLUSTER_NETWORK="kube-network"
VM_NETWORK="vm-network"
CLUSTER="cluster1"

${HOME}/istio-1.9.0/samples/multicluster/gen-eastwest-gateway.sh \
--mesh mesh1 --cluster "${CLUSTER}" --network "${CLUSTER_NETWORK}"

istioctl install -f eastwest-ingress-gateway.yaml
kubectl apply -f expose-istiod.yaml
kubectl apply -f expose-services.yaml

kubectl create serviceaccount "vm-tomcat" -n "default"


mkdir -p "${HOME}/istio-vm"
istioctl x workload entry configure -f workload-group.yaml -o "${HOME}/istio-vm" --clusterID "cluster1" --autoregister

istioctl kube-inject -f ${HOME}/istio-1.9.0/samples/helloworld/helloworld.yaml
