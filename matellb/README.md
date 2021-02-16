## 1. Install MatelLB ([the official guide](https://metallb.universe.tf/installation/))

```bash
kubectl edit configmap -n kube-system kube-proxy
```

Set kube-proxy strictARP property to true before install the matellb  
```yml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
```

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
```

## 2. Apply the Layer2 config to enable the matellb ([The Official reference](https://metallb.universe.tf/configuration/))

```bash
kubectl apply -f layer2-config.yml
```

## 3. Deploy the sample nginx service, which type is LoadBalancer
```bash
kubectl apply -f nginx-service.yml
```

## 4. Check the external IP address assigned to the nginx server
```bash
kubectl get service
```

## 5. Test the nginx service with the external IP
```bash
curl 192.168.28.220:8080/echo.txt
```
