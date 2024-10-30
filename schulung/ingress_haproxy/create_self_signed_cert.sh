#!/bin/bash
 
DOM="mg.net"
 
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out ${DOM}.crt -keyout ${DOM}.key \
    -subj "/CN=${DOM}" \
    -reqexts SAN \
    -extensions SAN \
    -config <(cat /etc/ssl/openssl.cnf \
<(printf "[SAN]\nsubjectAltName=DNS:${DOM}.com,DNS:*.${DOM}"))

kubectl delete secret ${DOM}-tls --ignore-not-found -n argocd
 
kubectl create secret tls ${DOM}-tls --key ${DOM}.key --cert ${DOM}.crt -n argocd
 
kubectl delete -f argocd-ingress.yml --ignore-not-found
kubectl apply -f argocd-ingress.yml