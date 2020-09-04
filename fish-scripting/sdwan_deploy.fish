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
sdwan_create_cloud_images
sdwan_create_networks

sdwan_create_certificate_authority
sdwan_create_control_plane_vms
# Control plane VMs need to settle a bit before we can configure them, so we
# create vEdges **before** that
sdwan_create_data_plane_vms
# After initial config upload vEdges reboot, so we let them do that, and we go
# configuring the control plane first
sdwan_get_external_ips
sdwan_configure_control_plane_vms
sdwan_configure_data_plane_vms
sdwan_show_info
