```bash
kubectl apply -f <(istioctl kube-inject -f simple-1.yml)

kubectl run tmp-shell --rm -i --tty --image nicolaka/netshoot -- /bin/bash
```
