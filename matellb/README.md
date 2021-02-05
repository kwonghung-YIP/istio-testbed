1. [Install MatelLB](https://metallb.universe.tf/installation/)

```bash
kubectl edit configmap -n kube-system kube-proxy
```

Update strictARP properties of kube-proxy to true  
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

2 Apply the Layer2 config to enable the matellb
