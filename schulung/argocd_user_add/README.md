# Add a user to argocd

add two lines into argocd-cm.yml

```bash
data:
  accounts.mg0050: apiKey, login
```

Apply the file

```bash
kubectl apply -f argocd-cm.yml -n argocd
```

***Note: Please note that,by default Argo CD has admin and read-only roles.***
 
add lines into argocd-rbac-cm.yml
 
```bash
data:
  policy.csv: g, mg0050, role:admin
```

Login to argocd

```bash
argocd login argocd.mg.net
WARNING: server certificate had error: tls: failed to verify certificate: x509: certificate signed by unknown authority. Proceed insecurely (y/n)? y
WARN[0024] Failed to invoke grpc call. Use flag --grpc-web in grpc calls. To avoid this warning message, use flag --grpc-web.
Username: admin
Password:
'admin:login' logged in successfully
Context 'argocd.mg.net' updated
```

Set password

```bash
argocd account update-password --account mg0050
```
