# Homelab Setup

This repo contains the setup and configuration for my current homelab, as well as OpenShift Local.

There is minimal manual configuration required - mostly to seed secret values as well as the initial OpenShift GitOps install.

## Cluster Init

Once a cluster is up, there are only three things to do to get the cluster fully configured:

1. Create the credentials secret for External Secrets to use.
2. Deploy OpenShift GitOps Operator.
3. Create the bootstrap Application.

### Doppler Creds Secret for External Secrets and Argo CD

Sensitive data is kept in an external secret manager.  In this case, [Doppler](https://www.doppler.com/).  I'm using the External Secrets Operator to automate the creation of Kubernetes Secrets from data stored in Doppler.  To do this, we need Doppler credentials in the cluster.

Of course you should never have a Kubernetes `Secret` in Git (for obvious reasons), so my Doppler creds secret is on my local machine.  I've created an `init` folder to distil this process down to one command in case I need to add other items to the seeding process.

This also includes deploying OpenShift GitOps.

```
oc apply -k bootstrap/init
```

## Cluster Config

Once OpenShift GitOps has finished deploying, create the Bootstrap app to do the rest of the configuration.

```
oc apply -k bootstrap/homelab
```

Go get a coffee and wait for the cluster configuration to complete :)

## Cluster Components and Configuration

Components and configuration for each lab environment.

### Homelab

* External Secrets Operator
* Image Registry Config
* Cert-Manager
* Wildcard cert for apps domain
* OpenShift GitOps configuration
* OpenShift OAuth (htpasswd)
* Groups and Membership

### OpenShift Local

* External Secrets Operator
* OpenShift GitOps configuration
* OpenShift OAuth (htpasswd)
* Groups and Membership