#!/bin/bash

kubectl get configmap argocd-cm -n argocd -o yaml > argocd-cm.yml
