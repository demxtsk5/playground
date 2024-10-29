#!/bin/bash
 
DOM="mg.net"
 
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out ${DOM}.crt -keyout ${DOM}.key \
    -subj "/CN=${DOM}" \
    -reqexts SAN \
    -extensions SAN \
    -config <(cat /etc/ssl/openssl.cnf \
<(printf "[SAN]\nsubjectAltName=DNS:${DOM}.com,DNS:*.${DOM}"))