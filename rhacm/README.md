# Bootstrap with Red Hat Advanced Cluster Management for Kubernetes

The bootstrap with RHACM requires a few more manual steps on the hub cluster, but provides a fully automated management experience for the spoke clusters (dev/prod).

This also simplifies Operator management (through the new Operator Policies) and seeding secret and config info (through hub templating).

## Install RHACM on the Hub

First, install RHACM on your Hub cluster.  I call mine "Prime" (Transformers reference...):

```
oc apply -k bootstrap/init
```

This will install the RHACM operator and seed the token required for External Secrets.

Once the operator has finished installing, run the following command to install an instance of RHACM:

```
oc apply -k bootstrap/init/rhacm/instance
```

This will take a few minutes to install.  Once it's complete, login to RHACM and import your clusters. For simplicy, I call mine:

* prime: My hub/management cluster.
* dev: My development cluster.
* prod: My production cluster.

The rest of the manifests in this repo will use those names.

The last command will create the "prime" cluster set and the first Policy/PolicySet/Placmenet, which will install and configure OpenShift GitOps and a policy "App of Apps" that will seed the rest of the policies.

```
oc apply -k bootstrap/init/rhacm/init-policies
``