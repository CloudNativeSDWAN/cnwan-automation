#!/usr/bin/env fish
#
# Copyright (C) 2020 Cisco Systems, Inc.
#
# @author  Lori Jakab <lojakab@cisco.com>

set script_dir (realpath (dirname (status -f)))

source $script_dir/lib/cna_functions.fish
source $script_dir/lib/sdwan_functions.fish

cna_get_required_config $argv[1]
sdwan_init

for i in (seq 1 $sdwan_edge_vm_count)
    set idx (math $i - 1)
    set vm_name (yq e ".sdwan.vedge[$idx].vm_name" $cna_config_file)
    gcloud -q compute instances delete $vm_name --project $gcp_project
end

gcloud -q compute instances delete cnwan-vsmart --project $gcp_project
gcloud -q compute instances delete cnwan-vbond --project $gcp_project
gcloud -q compute instances delete cnwan-vmanage --project $gcp_project

for i in (seq 1 $gcp_network_count)
    set idx (math $i - 1)
    set network_name (yq e ".gcp.networks[$idx].name" $cna_config_file)
    gcp_delete_single_subnet_network $network_name
end

gcp_delete_compute_image sdwan-cedge-(string replace -a '.' '-' $sdwan_iosxe_version)
gcp_delete_compute_image sdwan-vedge-$sdwan_version_dashes
gcp_delete_compute_image sdwan-vsmart-$sdwan_version_dashes
gcp_delete_compute_image sdwan-vmanage-$sdwan_version_dashes
