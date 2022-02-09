#!/bin/bash

# !!! This must be done on the image in Instruqt !!!

# adding host alias for the primary to the cd4pe and query deployment configurtions
DOMAIN=$(get_fqdn)
PRIMARY_IP=$(ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@puppet '(ifconfig -a)' | grep -oP "(?<=inet )\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | awk '!/127.0.0.1/')
GITLAB_IP=$(ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no root@gitlab '(ifconfig -a)' | grep -oP "(?<=inet )\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | awk '!/127.0.0.1/')

read -r PATCH <<EOF
{"spec":{"template":{"spec":{"hostAliases":[{"ip":"${PRIMARY_IP}","hostnames":["puppet.${DOMAIN}"]},{"ip":"${GITLAB_IP}","hostnames":["gitlab.${DOMAIN}"]}]}}}}
EOF

kubectl patch deployment cd4pe -n ${NAMESPACE} --patch "${PATCH}"
kubectl patch deployment query -n ${NAMESPACE} --patch "${PATCH}"
