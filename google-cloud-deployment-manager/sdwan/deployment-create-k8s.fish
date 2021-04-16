#!/usr/bin/env fish
#
# Copyright (C) 2021 Cisco Systems, Inc.
#
# @author  Lori Jakab <lojakab@cisco.com>


set script_dir (realpath (dirname (status -f)))

source $script_dir/variables.fish

gcloud container clusters create $gcp_cluster \
    --num-nodes 3 \
    --network pf-service-network \
    --subnetwork pf-service-network-100 \
    --labels $gcp_resource_labels \
    --zone $gcp_zone \
    --project $gcp_project

gcloud container clusters get-credentials $gcp_cluster \
    --zone $gcp_zone \
    --project $gcp_project

kubectl create clusterrolebinding $gcp_cluster \
    --clusterrole=cluster-admin \
    --user="(gcloud config get-value core/account)"
