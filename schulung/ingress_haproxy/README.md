## Ingress Regeln K8S

**In beiden Dateien gilt es, die eigene Domain und den eigenen IP-Adresse-Bereich einzutragen!**
  
### Was habe ich:
  
- genau eine IP Adresse, z.B. 192.168.65.200
- Verschiedene Sub-Domain, die auf die gleiche IP zeigen
    - argocd.mg.net
    - irgendwas.mg.net
- Den entsprechenden Eintrag in der /etc/hosts bzw. DNS
  
  
https://github.com/demxtsk5/playground/tree/d14ecc15db5bea528fa40032c89b4e42a1077a7b/schulung/ingress_haproxy
  
### Umsetzung (steht alles im Git):
  
- Ingress-nginx muss installiert sein (zum Beispiel über Kubespray)
- Metallb bekommt via Konfig einen weiteren ip address pool für den ingress-nginx namespace
- Erstellen eines Zertifikats und damit wird ein Secret erstellt via Skript
- Ingress mit Regeln versehen 
  
### Wichtige Befehle:
  
```
mg0050@u01:~$ k get ing -n argocd
NAME             CLASS   HOSTS           ADDRESS                       PORTS     AGE
argocd-ingress   nginx   argocd.mg.net   192.168.65.28,192.168.65.29   80, 443   9h

mg0050@u01:~$ k get secret -n argocd
NAME                          TYPE                DATA   AGE
argocd-notifications-secret   Opaque              0      14d
argocd-secret                 Opaque              5      14d
mg.net-tls                    kubernetes.io/tls   2      9h
repo-3847628628               Opaque              5      18h

mg0050@u01:~$ k get all,ing,secret -n argocd
< Ouput zu lang ;-) >
```
