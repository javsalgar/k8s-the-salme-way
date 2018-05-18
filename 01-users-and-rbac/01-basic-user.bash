#!/bin/bash

#!/bin/bash

source ./common.bash

#
# Execute this in your local machine
#

## Create cert dirs
mkdir -p ~/.certs/kubernetes/sandbox/

## Private key
openssl genrsa -out ~/.certs/kubernetes/sandbox/jsalmeron.key 2048

## Certificate sign request
openssl req -new -key ~/.certs/kubernetes/sandbox/jsalmeron.key -out /tmp/jsalmeron.csr -subj "/CN=jsalmeron/O=devs/O=tech-lead"

## Copy the request to the server (NOT THE PROPER WAY)
scp /tmp/jsalmeron.csr bitnami@$SANDBOX_IP:/tmp/

#
# This part is done on the server side
#

## Certificate
openssl x509 -req -in /tmp/jsalmeron.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out /tmp/jsalmeron.crt  -days 500 

#
# This part is done again on the client side
#

# Download the generated certificate (NOT THE PROPER WAY)
scp bitnami@$SANDBOX_IP:/tmp/jsalmeron.crt ~/.certs/kubernetes/sandbox/jsalmeron.crt
scp bitnami@$SANDBOX_IP:/etc/kubernetes/pki/ca.crt  ~/.certs/kubernetes/sandbox/ca.crt

# Check the content of the certificate
openssl x509 -in $HOME/.certs/kubernetes/sandbox/jsalmeron.crt -text -noout 

# Add new kubectl context

kubectl config set-cluster sandbox --certificate-authority=$HOME/.certs/kubernetes/sandbox/ca.crt --embed-certs=true --server=https://${SANDBOX_IP}:6443

kubectl config set-credentials jsalmeron --client-certificate=$HOME/.certs/kubernetes/sandbox/jsalmeron.crt --client-key=$HOME/.certs/kubernetes/sandbox/jsalmeron.key --embed-certs=true

kubectl config set-context jsalmeron-sandbox --cluster=sandbox --user=jsalmeron

# Set new context
kubectl config use-context jsalmeron-sandbox

# Try 
kubectl get pods