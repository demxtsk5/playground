#!/bin/bash

kubectl get configmap argocd-rbac-cm -n argocd -o yaml > argocd-rbac-cm.yml
