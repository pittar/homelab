#!/bin/bash

echo "Logged in as: $(oc whoami) on server $(oc whoami --show-server)"
echo ""

read -p "Press Enter to continue..."
echo ""

echo "Starting bootstrap process".

oc apply -k ./bootstrap/init

echo "Waiting 60 seconds for OpenShift GitOps and RHACM operators to install."

sleep 60

echo "Deploying a basic RHACM instance."

oc apply -k ./bootstrap/init/rhacm-operator/instance

echo "Waiting 30 seconds for RHACM to deploy."

echo "Deploying bootstrap application... go get a coffee and come back to a configued cluster!"

oc apply -k gitops/argocd/rhacm/bootstrap
