# Check OpenShift Operator Upgrades

## Overview
This skill checks for pending OpenShift operator upgrades and displays a markdown-formatted table showing current vs pending CSV versions.

## Usage
```opencode
Use the check-operator-upgrades skill to check for pending operator upgrades

# Check all namespaces
Check for pending operator upgrades

# Check specific namespace
Check for pending operator upgrades in namespace: openshift-cnv
```

## Description
This skill connects to the OpenShift cluster and:
1. Scans all namespaces (or specified namespace) for InstallPlan resources
2. Identifies unapproved InstallPlans (pending operator upgrades)
3. Retrieves current and pending CSV versions for each operator
4. Update the appropriate "OperatorPolicy" in the various yaml Policy files found in the "gitops/rhacm" subdirectories with the new versions.
5. Do not commit any changes to git.
6. Generates a formatted markdown table with comparison of old and new versions.


## Output Format
The skill returns a markdown table with the following columns:
- **Namespace**: The namespace where the operator is installed
- **Operator**: The name of the operator
- **Current CSV**: The currently installed CSV version
- **Pending CSV**: The CSV version that's waiting for approval
- **Status**: Status indicator (🔄 Pending or ⚠️ Unknown)

## Example Output
```markdown
## 📦 OpenShift Operator Upgrades

Found 4 pending operator upgrade(s):

| Namespace | Operator | Current CSV | Pending CSV | Status |
|-----------|----------|-------------|-------------|--------|
| openshift-cnv | kubevirt-hyperconverged | kubevirt-hyperconverged.v4.21.0 | kubevirt-hyperconverged-operator.v4.22.0 | 🔄 Pending |
| openshift-pipelines-operator | openshift-pipelines-operator | openshift-pipelines-operator-rh.v1.21.0 | openshift-pipelines-operator-rh.v1.22.4 | 🔄 Pending |
| openshift-nfd | nfd | nfd.4.21.0-202506220442 | nfd.4.22.0-202606220442 | 🔄 Pending |
| openshift-cluster-observability-operator | cluster-observability | cluster-observability.v1.4.0 | cluster-observability-operator.v1.5.1 | 🔄 Pending |
```

## Prerequisites
- Sufficient RBAC permissions to read InstallPlan, Subscription, and CSV resources
- Access to namespaces where operators are installed

## Notes
- If current CSV shows "Unknown", it may indicate a detection issue or missing permissions
- Only unapproved InstallPlans are shown (those with `spec.approved: false`)
- The skill is optimized for OpenShift clusters managed via RHACM/ArgoCD GitOps workflow