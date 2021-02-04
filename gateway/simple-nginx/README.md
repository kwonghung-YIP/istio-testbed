```bash
kubectl apply -f <(istioctl kube-inject -f nginx-service.yml)
```

Verify the virtual service within the mesh with the netshoot
```bash
curl http://nginx-service.default.svc.cluster.local:8080/echo.txt
```

Find out the IP address and http2 NodePort of the ingress-gateway for testing the link outside of the mesh 
```bash
curl -H "Host: nginx.istio-testbed.org.hk" http://192.168.28.135:32656/echo.txt
```
