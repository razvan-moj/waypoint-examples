# waypoint-examples

You can use these example applications to quickly try out and learn how to use
[Waypoint](https://waypointproject.io/).

## Getting Started

```
helm upgrade --install -n waypoint waypoint hashicorp/waypoint --set 'ui.ingress.enabled'='true' \
 --set 'ui.ingress.hosts[0].host'='waypoint.apps.raz-test.cloud-platform.service.justice.gov.uk' \
 --set 'ui.ingress.annotations{"kubernetes.io/ingress.class"}'='nginx' --set 'ui.service.type'='ClusterIP' \
```

just for tests

```
kubectl delete clusterrolebinding waypoint-runner-odr-rolebinding-custom
```
and

```
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    meta.helm.sh/release-name: waypoint
    meta.helm.sh/release-namespace: waypoint
  labels:
    app.kubernetes.io/instance: waypoint
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: waypoint-runner
  name: waypoint-runner-odr-rolebinding-custom
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: waypoint-runner-odr
  namespace: waypoint
- kind: ServiceAccount
  name: waypoint-runner
  namespace: waypoint
- kind: ServiceAccount
  name: waypoint
  namespace: waypoint
```

The CLI cannot reach the server from outside the cluster, to fix the UI ingress need to be edited to have `pathType: ImplementationSpecific` instead of `Prefix` and a new ingress defined for the same hostname but GRPC:

```
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/backend-protocol: GRPCS
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/grpc-backend: "true"
  labels:
    app.kubernetes.io/instance: waypoint
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: waypoint
    helm.sh/chart: waypoint-0.1.11
  name: waypoint-grpc
  namespace: waypoint
spec:
  rules:
    - host: waypoint.apps.raz-test.cloud-platform.service.justice.gov.uk
      http:
        paths:
          - backend:
              service:
                name: waypoint-server
                port:
                  name: grpc
            path: /hashicorp.waypoint.Waypoint/
            pathType: ImplementationSpecific
          - backend:
              service:
                name: waypoint-server
                port:
                  name: grpc
            path: /grpc.reflection.v1alpha.ServerReflection/ServerReflectionInfo
            pathType: ImplementationSpecific
```

With this you can now

```
$ waypoint login -from-kubernetes -from-kubernetes-namespace=waypoint -server-tls-skip-verify -server-addr=waypoint.apps.raz-test.cloud-platform.service.justice.gov.uk:443
Authentication complete! You're now logged in.
```

To set OIDC auth via CLI (haven't found a Helm way yet),

```
 waypoint auth-method set oidc -client-id='aaaa' \
  -client-secret='aaaa' \
  -issuer='https://justice-cloud-platform.eu.auth0.com/' \
  -allowed-redirect-uri='https://waypoint.apps.raz-test.cloud-platform.service.justice.gov.uk/auth/oidc-callback' \
  auth0

#  -list-claim-mapping='groups="https://k8s.integration.dsd.io/groups"' \
#  -access-selector="mycompany in list.groups" \
# ^ this doesn't work, error "mapping value must be valid"
```
