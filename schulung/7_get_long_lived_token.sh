#!/bin/bash 

DATADIR="./"
USER="ui-admin ui-viewer"

for U in ${USER}
do
        echo "${U}:"
        TOKEN=$(kubectl get secrets ${U}-token -n kubernetes-dashboard --kubeconfig=$(pwd)/kubeconfig -o json| jq -r '.data.token'|base64 -d)
        echo "${TOKEN}"
        echo "${TOKEN}" > ${DATADIR}/${U}_long_live.token
done