#!/usr/bin/env fish
#
# Copyright (C) 2021 Cisco Systems, Inc.
#
# @author  Lori Jakab <lojakab@cisco.com>

set script_dir (realpath (dirname (status -f)))

source $script_dir/variables.fish


function sdwan_control_vms_initial_config
    set gcp_mgmt_gateway (gcloud compute networks subnets list --project $gcp_project --filter="name:$sdwan_naming_prefix-sdwan-management-network AND region:$gcp_region" --format="value(gatewayAddress)")
    set gcp_ctrl_gateway (gcloud compute networks subnets list --project $gcp_project --filter="name:$sdwan_naming_prefix-sdwan-control-network-$sdwan_ctrl_site_id AND region:$gcp_region" --format="value(gatewayAddress)")
    sdwan_get_vbond_private_ip
    for vm in $sdwan_ctrl_vms
        sdwan_vm_initial_config $vm $gcp_mgmt_gateway $gcp_ctrl_gateway unused unused unused $sdwan_vbond_private_ip
    end
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

sdwan_create_certificate_authority
sdwan_control_vms_initial_config
wait_with_progress 7
sdwan_get_ctrl_external_ips
sdwan_configure_control_plane_vms
sdwan_show_info