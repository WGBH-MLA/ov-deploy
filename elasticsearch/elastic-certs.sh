#!/bin/bash

help() {
    echo
    echo "Usage: $0 <update-elasticsearch|update-kibana>"
    echo
    echo This script gets the latest certificate from Traefik
    echo and updates the Elasticsearch or Kibana k8s secret
    echo
}

get-traefik() {
    # Get the name of the running Traefik pod
    TRAEFIK=$(kubectl -n traefik -o json get po | jq -r .items[0].metadata.name)

    if [ -z "$TRAEFIK" ]; then
        echo "Traefik pod not found"
        exit 1
    fi
    echo "$TRAEFIK"
}

get-cert() {
    # Get the certificate object from Traefik that matches the domain
    DOMAIN=$1
    CERT=$(kubectl exec -n traefik $TRAEFIK -- cat /ssl-certs/acme-production.json | jq --arg domain $DOMAIN -r '.production.Certificates[] | select( .domain.main==$domain ).certificate')

    if [ -z "$CERT" ]; then
        echo "Certificate not found for $DOMAIN"
        exit 1
    fi
    echo "$CERT"
}

update-elasticsearch() {
    # Update the Elasticsearch secret with the latest certificate
    TRAEFIK=$(get-traefik)
    CERT=$(get-cert "elastic.wgbh-mla.org")
    kubectl -n elastic patch secret elastic-certs -p "{\"data\":{\"tls.crt\":\"$CERT\"}}"
}

update-kibana() {
    # Update the Kibana secret with the latest certificate
    TRAEFIK=$(get-traefik)
    CERT=$(get-cert "search.wgbh-mla.org")
    kubectl -n elastic patch secret kibana-certs -p "{\"data\":{\"tls.crt\":\"$CERT\"}}"
}

if [ -z $1 ]; then help; fi

"$@" || (help && exit 1)
