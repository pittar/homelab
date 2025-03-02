#!/bin/bash

SVCS=$(oc get svc -l idle -o name | cut -d '/' -f 2)

for SVC in $SVCS
do
  echo "Idle service: $SVC"
  oc idle $SVC
done;
