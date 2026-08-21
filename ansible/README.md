# Ansible Playbooks

## Basis Installation Kubernetes

#### Voraussetzungen und Aufruf
<details>

- UTM
- 3 VMs ( 1 Master, 2 Worker)
- 4-6 GB RAM
- 40GB HDD
- Im Inventory die Version festlegen (group_vars/kube.yml)

```
k8s_version: v1.28
pod_network_cidr: 10.244.0.0/16
```

- Playbook: kubernetes.yml (Limit wird im Playbook gesetzt)

```
ansible-playbook playbooks/kubernetes.yml --user mg0050 -k
```
</details>

## Upgrade Kubernetes

#### Voraussetzungen und Aufruf
<details>

- Im Inventory (group_vars/kube.yml) die Version festlegen (Upgrade Reihenfolge beachten, pkg und cluster ergeben sich nach dem ersten Playbooklauf mit dem tag preparation)
````
upgrade_target_version: v1.30
upgrade_target_package_version: 1.30.14-1.1
upgrade_target_cluster_version: v1.30.14
````

- Playbook starten upgrade-kubernetes.yml starten
````
ansible-playbook playbooks/upgrade-kubernetes.yml --limit kube_master --user mg0050 -k --tags preparation
````
- Variablen anpassen (siehe Punkt 1)

>[!WICHTIG]
>Erst die Controlplane und dann jeden Worker einzeln

- Control Plane upgraden
```
ansible-playbook playbooks/upgrade-kubernetes.yml --limit kube_master --user mg0050 --tags upgrade_control_plane -k
```
- Danach Worker für Worker einzeln upgraden
```
ansible-playbook playbooks/upgrade-kubernetes.yml --limit k8s-n1 --user mg0050 --tags upgrade_workers -k

ansible-playbook playbooks/upgrade-kubernetes.yml --limit k8s-n2 --user mg0050 --tags upgrade_workers -k
```
</details>
