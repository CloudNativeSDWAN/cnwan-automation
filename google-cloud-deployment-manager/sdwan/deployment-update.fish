#!/usr/bin/env fish
#
# Copyright (C) 2021 Cisco Systems, Inc.
#
# @author  Lori Jakab <lojakab@cisco.com>


set script_dir (realpath (dirname (status -f)))

source $script_dir/variables.fish

gcloud deployment-manager deployments update $gcp_deployment \
    --config $script_dir/dm/sdwan-control-plane.yaml \
    --project $gcp_project
