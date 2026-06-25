# Homelab - Agent Instructions

## Repo overview

This repo manages an OpenShift homelab via **GitOps (OpenShift GitOps/ArgoCD)** and **RHACM** (Red Hat Advanced Cluster Management). All manifests are YAML-only (Kustomize + RHACM OperatorPolicies). No test framework, no linter, no build step.

## Environments

| Environment | Purpose |
|---|---|
| `local` | Lightweight single-node OpenShift (minikube-like), no ingress controller, no cluster-autoscaler. Only cluster in `test` cluster pool. |
| `dev` | Full dev cluster. Only cluster in `test` cluster pool. |
| `prod` | Production cluster. Part of `standard` cluster pool. |
| `prime` | Production cluster. Part of `standard` cluster pool. |

Cluster pools are defined in `gitops/argocd/clusters/managedclusterset/pool.yaml`.

`dev` and `prod` share the `sno` variant: SNO topology (single-node OpenShift), no ingress controller, no `cluster-autoscaler`.

## Cluster bootstrap order

1. Set Doppler credentials secret locally, then run:
   ```
   oc apply -k bootstrap/init
   ```
2. Wait for OpenShift GitOps and RHACM operators to install.
3. Create the bootstrap RHACM Application:
   ```
   oc apply -k gitops/argocd/rhacm/bootstrap
   ```

Or use the all-in-one script `bootstrap/init/init.sh`, which runs all three steps sequentially (waits 120s between steps 1 and 3 for operators to provision the RHACM operator instance, then deploys the bootstrap application).

**Note:** Environment-specific bootstrapping is driven through `gitops/argocd/clusters/{env}/bootstrap/` (e.g. `gitops/argocd/clusters/dev/bootstrap/bootstrap-application.yaml`), which is then applied via `bootstrap/{env}/kustomization.yaml` overlays.

### Bootstrap flow

```
bootstrap/{env}/kustomization.yaml
  └── gitops/argocd/clusters/{env}/bootstrap/
        ├── bootstrap-project.yaml     # ArgoCD project for the env
        └── bootstrap-application.yaml # ArgoCD application pointing to gitops/argocd/clusters/sno
```

The `bootstrap-application.yaml` references `gitops/argocd/clusters/sno` as its sync source (`repoURL` → the homelab repo, `path` → `gitops/argocd/clusters/sno`).

## Operator upgrades

Operators are deployed in **Manual** approval mode, managed by RHACM `OperatorPolicy` resources in `gitops/rhacm/policies/`. To upgrade:

1. Find unapproved InstallPlans:
   ```bash
   oc get installplan -A -o jsonpath='{range .items[?(@.spec.approved==false)]}{.metadata.namespace}{"\t"}{.spec.clusterServiceVersionNames[0]}{"\n"}{end}'
   ```
2. Update the corresponding RHACM `OperatorPolicy` with the new CSV version.

## Key directories

| Directory | Purpose |
|---|---|
| `bootstrap/init/` | First-run seeding: External Secrets, GitOps operator, RHACM operator |
| `bootstrap/{dev,local,prod,prime}/` | Per-environment bootstrap overlays |
| `gitops/rhacm/` | RHACM policysets, policies, managedclustersets and bindings |
| `gitops/rhacm/policysets/{dev,global,prod,prime,appservices}/` | Multi-cluster policy groupings |
| `gitops/rhacm/policies/` | Individual OperatorPolicies and resource policies |
| `gitops/cluster-services/` | Cluster-scoped operator subscriptions and instances (e.g. Keycloak, RH SSO) |
| `gitops/cluster-config/` | Cluster-level config (cert-manager, GitOps config, etc.) |
| `gitops/argocd/` | ArgoCD Application and ApplicationSet definitions |
| `gitops/argocd/clusters/` | Per-environment cluster configs and ArgoCD bootstrap Application definitions |
| `haproxy/` | HAProxy load balancer config for OCP instances |
| `scripts/idle.sh` | Iterates all services labeled `idle` and runs `oc idle` |

## Secrets

Secrets must never be committed. Files listed in `.gitignore` (`creds.yaml`, `route53-creds-secret.yaml`, `**/*.env`, `**/*.secret`, doppler secrets, `scratch/`) are excluded. Doppler credentials and the external secrets bootstrap files exist only locally and are deployed via `oc apply -k`.

## Toolchain conventions

- **Kustomize** for overlay-based resource composition (`kustomization.yaml` everywhere).
- **RHACM OperatorPolicy** controls operator installation/upgrade across clusters.
- Cluster topology: `managedclustersets` → `managedclustersetbindings` → `policysets` → `policies`.
- All environment targeting flows through placement bindings in policysets.
- To deploy a single environment directly (bypass ArgoCD): `oc apply -k bootstrap/{env}`.
