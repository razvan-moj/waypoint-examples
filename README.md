# waypoint-examples

You can use these example applications to quickly try out and learn how to use
[Waypoint](https://waypointproject.io/).

## Getting Started

```
helm upgrade --install -n waypoint waypoint hashicorp/waypoint --set 'ui.ingress.enabled'='true' \
 --set 'ui.ingress.hosts[0].host'='waypoint.apps.raz-test.cloud-platform.service.justice.gov.uk' \
 --set 'ui.ingress.annotations{"kubernetes.io/ingress.class"}'='nginx' --set 'ui.service.type'='ClusterIP'
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
