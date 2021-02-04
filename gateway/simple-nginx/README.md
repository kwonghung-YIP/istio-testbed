```bash
kubectl apply -f <(istioctl kube-inject -f nginx-service.yml)
```

```bash
curl http://nginx-service.default.svc.cluster.local:8080/echo.txt
```
