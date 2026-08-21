# Homelab Setup

This repo contains the setup and configuration for my current homelab.

There is minimal manual configuration required - mostly to seed secret values as well as the initial OpenShift GitOps install.

## Cluster Init

I use Ansible for the initial bootstrap and so should you!  Here's how I set up my venv:

```
# 1. Create the virtual environment
python3 -m venv .venv

# 2. Activate it
source .venv/bin/activate

# 3. Upgrade pip and install required Python packages
pip install --upgrade pip
pip install kubernetes jsonpatch PyYAML ansible-core

# 4. Install the Ansible collection inside the activated venv
ansible-galaxy collection install kubernetes.core
```

Don't forget to re-initialize your venv on subsequent terminal sessions:

```
source .venv/bin/activate
ansible-playbook bootstrap/bootstrap.yaml
```

## Operator Upgrades

Operators are deployed in "Manual" mode and managed by RHACM "OperatorPolicy" policies.  This allows for a simplified "GitOps" management of operators and opertor upgrades in "Manual" mode.

When there are upgrades available, you can find the requested upgrade CSVs by running the following command:

```bash
oc get installplan -A -o jsonpath='{range .items[?(@.spec.approved==false)]}{.metadata.namespace}{"\t"}{.spec.clusterServiceVersionNames[0]}{"\n"}{end}'
```

Then, update the appropriate RHACM OperatorPolicy with the new version, push to git, and wait for OpenShift GitOps and RHACM to update your operators.

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
* Connectivity Link
* NVidia Operator
* OpenTelemetry/Tempo
* Cluster Observability Operator / Prometheus
* Service Mesh 3
* Keycloak
* Dev Spaces
* Lightspeed
* Developer Hub
* OpenShift Pipelines
* OpenShift Virtualization
