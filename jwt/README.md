In this example, if the "deny-anonymous-access" AuthorizationPolicy apply to default namespace will 
not work as expected, the following json shows the dynamic metadata received by the istio-proxy in 
the nginx pod, the "request.auth.principal" property is presented which is not anonymous request from
the point of nginx istio-proxy.

```
│ 2021-03-16T03:58:20.308918Z    debug    envoy filter    Saved Dynamic Metadata:                                                                           │
│ fields {                                                                                                                                                  │
│   key: "request.auth.principal"                                                                                                                           │
│   value {                                                                                                                                                 │
│     string_value: "cluster.local/ns/istio-system/sa/istio-ingressgateway-service-account"                                                                 │
│   }                                                                                                                                                       │
│ }                                                                                                                                                         │
│ fields {                                                                                                                                                  │
│   key: "source.namespace"                                                                                                                                 │
│   value {                                                                                                                                                 │
│     string_value: "istio-system"                                                                                                                          │
│   }                                                                                                                                                       │
│ }                                                                                                                                                         │
│ fields {                                                                                                                                                  │
│   key: "source.principal"                                                                                                                                 │
│   value {                                                                                                                                                 │
│     string_value: "cluster.local/ns/istio-system/sa/istio-ingressgateway-service-account"                                                                 │
│   }                                                                                                                                                       │
│ }                                                                                                                                                         │
│ fields {                                                                                                                                                  │
│   key: "source.user"                                                                                                                                      │
│   value {                                                                                                                                                 │
│     string_value: "cluster.local/ns/istio-system/sa/istio-ingressgateway-service-account"                                                                 │
│   }                                                                                                                                                       │
│ }    
```

watch -n 1 curl -s --request GET \
  --url http://nginx-test.hung.org.hk/echo.txt \
  --header 'authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkVDNGMtdzF1UHNaMmVTc2twUDJzQSJ9.eyJpc3MiOiJodHRwczovL2Rldi1qa2Q2dHRsdC51cy5hdXRoMC5jb20vIiwic3ViIjoiQ09iSEE3OFNYclBWRzRyRDZiQVUySEY4NE9ReHNmTkVAY2xpZW50cyIsImF1ZCI6Imh0dHA6Ly9hdXRoMC10ZXN0Lmh1bmcub3JnLmhrIiwiaWF0IjoxNjE1ODAyNjM3LCJleHAiOjE2MTU4ODkwMzcsImF6cCI6IkNPYkhBNzhTWHJQVkc0ckQ2YkFVMkhGODRPUXhzZk5FIiwiZ3R5IjoiY2xpZW50LWNyZWRlbnRpYWxzIn0.myU4nHTYoBRLNF07_k9T47kriJoXRgvsI8yan_vNNX4KRLiZWhN3FZ5FpFNFXEx3zU_3rd2NTGcYeP6wZlC-5vlRpFK_ZqY1blhkRqM1-d1WMmthUaEcVNfLjgOxClXUhd4v2nEV4wOFxn3J6HJDlMs0Hte0JYutzgGa5RsZC3aJ9ukZvi0SZ1acHI0R9bd0_v2JJCgZXmAGNNNYHn9zGhxfssHgyf8xNaaWDJ-R3ya3YX_sozhW_FAVBYKdlJnkuBe1V0mXQldWPJz9L1p8afHCsstjGtth36zkT-jnwu9OXlRYzELJ5hXib7vR-qtnlOLHUV27SiMf0nFwm3A_aQ'

watch -n 1 \
  curl -s -o /dev/null -w "%{http_code}\n" \
  --request GET \
  --url http://nginx-test.hung.org.hk/headers \
  --header "Authorization: Bearer abcd1234"

  curl -s \
  --request GET \
  --url http://nginx-test.hung.org.hk/headers \
  --header "Authorization: Bearer abcd1234"

curl --header "Authorization: Bearer deadbeef" "http://nginx-test.hung.org.hk/headers" -s -o /dev/null -w "%{http_code}\n"


TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.9/security/tools/jwt/samples/demo.jwt -s)

watch -n 1 \
  curl -s -o /dev/null -w "%{http_code}\n" \
  --request GET \
  --url http://nginx-test.hung.org.hk/headers \
  --header "Authorization: Bearer $TOKEN"

  curl -s \
  --request GET \
  --url http://nginx-test.hung.org.hk/headers \
  --header "Authorization: Bearer $TOKEN"

watch -n 1 \
  curl -s -o /dev/null -w "%{http_code}\n" \
  --request GET \
  --url http://nginx-test.hung.org.hk/headers \
  --header "x-jwt-assertion: Bearer $TOKEN"

  curl -s \
  --request GET \
  --url http://nginx-test.hung.org.hk/headers \
  --header "x-jwt-assertion: Bearer $TOKEN"

watch -n 1 \
  curl -s -o /dev/null -w "%{http_code}\n" \
  --request GET \
  --url http://nginx-test.hung.org.hk/headers \
  --header "x-jwt-assertion: $TOKEN"
