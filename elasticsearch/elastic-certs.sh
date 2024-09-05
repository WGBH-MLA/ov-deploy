#!/bin/bash

# This script will update the elastic-certs secret with the latest certificate from Traefik

DOMAIN=elastic.wgbh-mla.org

if [ -z "$DOMAIN" ]; then
    echo "Please provide a domain"
    echo "Usage: $0 <domain>"
    exit 1
fi

>&2 echo "DOMAIN: $DOMAIN"

# Get the name of the running Traefik pod
TRAEFIK=$(kubectl -n traefik -o json get po | jq -r .items[0].metadata.name)

if [ -z "$TRAEFIK" ]; then
    echo "Traefik pod not found"
    exit 1
fi

>&2 echo "TRAEFIK: $TRAEFIK"

# Get the certificate object from Traefik that matches the domain
CERT=$(kubectl exec -n traefik $TRAEFIK -- cat /ssl-certs/acme-production.json | jq --arg domain $DOMAIN -r '.production.Certificates[] | select( .domain.main==$domain ).certificate' )

if [ -z "$CERT" ]; then
    echo "Certificate not found"
    exit 1
fi

# echo "$CERT"

# Modify the k8s secret
# When modifying the kibana secret, be sure to modify the `kibana-certs` secret
kubectl -n elastic patch secret elastic-certs -p "{\"data\":{\"tls.crt\":\"$CERT\"}}"
