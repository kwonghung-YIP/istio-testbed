```bash
kubectl apply -f <(istioctl kube-inject -f nginx-service.yml)
```

```bash
curl http://nginx-service.default.svc.cluster.local:8080/echo.txt
```

```bash
curl -H "Host: nginx.istio-testbed.org.hk" http://192.168.28.135:32656/echo.txt
```
