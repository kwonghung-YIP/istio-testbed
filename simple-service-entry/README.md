```bash
kubectl apply -f <(istioctl kube-inject -f ping.yml)

kubectl run tmp-shell --rm -i --tty --image nicolaka/netshoot -- /bin/bash
```
