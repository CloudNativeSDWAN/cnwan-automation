#!/usr/bin/env fish
#
# Copyright (C) 2021 Cisco Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
# @author  Lori Jakab <lojakab@cisco.com>

set script_dir (realpath (dirname (status -f)))

source $script_dir/variables.fish


# gcp_create_compute_image:
#
# Create a bootable cloud image from a Cisco SD-WAN disk image file
# Parameters:
#   <image_format>  either qcow2 or ova (for cEdge it can only be qcow2)
#   <file>          full patch to disk image file
#   <image_name>    name for the the image on GCP
#   <image_family>  image family for the image on GCP
#   <label>         free-form label for the image


# Sometimes vManage images have an extra .1 in the version
set vmanage_image $sdwan_image_path/viptela-vmanage-$sdwan_version-genericx86-64.qcow2
if ! test -r $vmanage_image
    set vmanage_image  $sdwan_image_path/viptela-vmanage-$sdwan_version.1-genericx86-64.qcow2
end

# vManage
gcp_create_compute_image qcow2 \
    $vmanage_image \
    sdwan-vmanage-$sdwan_version_dashes sdwan-vmanage $gcp_resource_label

# vBond / vEdge
gcp_create_compute_image qcow2 \
    $sdwan_image_path/viptela-edge-$sdwan_version-genericx86-64.qcow2 \
    sdwan-vedge-$sdwan_version_dashes sdwan-vedge $gcp_resource_label

# vSmart
gcp_create_compute_image qcow2 \
    $sdwan_image_path/viptela-smart-$sdwan_version-genericx86-64.qcow2 \
    sdwan-vsmart-$sdwan_version_dashes sdwan-vsmart $gcp_resource_label
