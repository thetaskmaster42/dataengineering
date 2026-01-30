#!/bin/bash

# Master setup

master_node_ip=""

curl -sfL https://get.k3s.io | \
K3S_KUBECONFIG_MODE="644" \
INSTALL_K3S_EXEC="server \
--disable=traefik \
--flannel-backend=host-gw \
--tls-san=$master_node_ip \
--bind-address=$master_node_ip \
--advertise-address=$master_node_ip \
--node-ip=$master_node_ip \
--cluster-init" sh -s -

node_token=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# workers setup 

ssh rudra@pi1 "sudo curl -sfL https://get.k3s.io | \
K3S_TOKEN=$node_token \
K3S_URL='https://$master_node_ip:6443' \
K3S_NODE_NAME='pi1' sh - "


ssh rudra@pi2 "sudo curl -sfL https://get.k3s.io | \
K3S_TOKEN=$node_token \
K3S_URL='https://$master_node_ip:6443' \
K3S_NODE_NAME='pi2' sh - "

ssh rudra@pi3 "sudo curl -sfL https://get.k3s.io | \
K3S_TOKEN=$node_token \
K3S_URL='https://$master_node_ip:6443' \
K3S_NODE_NAME='pi3' sh - "

ssh rudra@pi4 "sudo curl -sfL https://get.k3s.io | \
K3S_TOKEN=$node_token \
K3S_URL='https://$master_node_ip:6443' \
K3S_NODE_NAME='pi4' sh - "