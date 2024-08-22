# Homelab Setup

# Install Argo CD

# Ingress

```
oc --namespace openshift-ingress-operator \
  patch --type=merge ingresscontrollers/default \
  --patch '{"spec":{"defaultCertificate":{"name":"apps-wildcard-cert"}}}'
```

# Image registry

```
oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"managementState":"Managed"}}'

oc edit configs.imageregistry.operator.openshift.io

storage:
  pvc:
    claim:
```