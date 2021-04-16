#!/usr/bin/env fish
#
# Copyright (C) 2021 Cisco Systems, Inc.
#
# @author  Lori Jakab <lojakab@cisco.com>


set script_dir (realpath (dirname (status -f)))

source $script_dir/variables.fish

gcloud deployment-manager deployments create $gcp_deployment-vedge \
    --config $script_dir/dm/sdwan-data-plane.yaml \
    --labels $gcp_resource_labels \
    --project $gcp_project

if ! test $status -eq 0
    echo "Creating the SD-WAN control plane deployment FAILED, exiting..."
    echo ""
    gcloud -q deployment-manager deployments delete $gcp_deployment-vedge \
        --project $gcp_project
    exit 1
end
