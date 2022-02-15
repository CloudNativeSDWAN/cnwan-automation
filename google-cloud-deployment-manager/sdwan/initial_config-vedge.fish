#!/usr/bin/env fish
#
# Copyright (C) 2021 Cisco Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
# @author  Lori Jakab <lojakab@cisco.com>

set script_dir (realpath (dirname (status -f)))
set progname (basename (status -f))


if ! test -n "$argv"
    echo "Usage: ./$progname <VEDGE_INDEX>"
    exit 1
end

source $script_dir/variables.fish

function sdwan_vedge_initial_config
    set site_id $sdwan_site_id[(math $argv + 1)]
    set gcp_mgmt_gateway (gcloud compute networks subnets list --project $gcp_project --filter="name:$sdwan_naming_prefix-sdwan-management-network AND region:$gcp_region" --format="value(gatewayAddress)")
    set gcp_pubi_gateway (gcloud compute networks subnets list --project $gcp_project --filter="name:$sdwan_naming_prefix-sdwan-public-internet-$site_id AND region:$gcp_region" --format="value(gatewayAddress)")
    set gcp_bizi_gateway (gcloud compute networks subnets list --project $gcp_project --filter="name:$sdwan_naming_prefix-sdwan-biz-internet-$site_id AND region:$gcp_region" --format="value(gatewayAddress)")
    sdwan_get_vbond_private_ip
    sdwan_vm_initial_config vedge[$argv] $gcp_mgmt_gateway unused $gcp_pubi_gateway $gcp_bizi_gateway $service_network_ip_mask $sdwan_vbond_private_ip
end

function sdwan_vedge_onboarding
    sdwan_configure_data_plane_vm vedge $argv
end

function wait_with_progress
    set minutes $argv
    echo -n "[ℹ] Waiting for $minutes minutes for the dust to settle..."
    for i in (seq (math $minutes - 1) 0)
        sleep 60
        echo -n "$i..."
    end
    echo ""
end


#
# MAIN CODE
#

sdwan_vedge_initial_config $argv
sdwan_vedge_onboarding $argv
