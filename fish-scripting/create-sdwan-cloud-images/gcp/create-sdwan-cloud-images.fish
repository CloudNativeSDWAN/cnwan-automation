#!/usr/bin/env fish
#
# Copyright (C) 2020, 2022 Cisco Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
# @author  Lori Jakab <lojakab@cisco.com>

set script_dir (realpath (dirname (status -f)))

source $script_dir/variables.fish
source $script_dir/../../lib/sdwan_functions.fish

sdwan_init

# Sometimes vManage images have an extra .1 in the version, test for that first
set sdwan_vmanage_version $sdwan_version.1
set sdwan_vmanage_version_dashes $sdwan_version_dashes-1


# gcp_create_compute_image:
#
# Create a bootable cloud image from a Cisco SD-WAN disk image file
# Parameters:
#   <image_format>  either qcow2 or ova (for cEdge it can only be qcow2)
#   <file>          full patch to disk image file
#   <image_name>    name for the the image on GCP
#   <image_family>  image family for the image on GCP
#   <label>         free-form label for the image


# If we don't find a an extra .1 version for vManage, use the same version
if ! test -r $sdwan_image_path/viptela-vmanage-$sdwan_vmanage_version-genericx86-64.qcow2
    set sdwan_vmanage_version $sdwan_version
    set sdwan_vmanage_version_dashes $sdwan_version_dashes
end

# vManage
gcp_create_compute_image qcow2 \
    $sdwan_image_path/viptela-vmanage-$sdwan_vmanage_version-genericx86-64.qcow2 \
    sdwan-vmanage-$sdwan_vmanage_version_dashes sdwan-vmanage $gcp_image_label

# vBond/vEdge
gcp_create_compute_image qcow2 \
    $sdwan_image_path/viptela-edge-$sdwan_version-genericx86-64.qcow2 \
    sdwan-edge-$sdwan_version_dashes sdwan-edge $gcp_image_label

# vSmart
gcp_create_compute_image qcow2 \
    $sdwan_image_path/viptela-smart-$sdwan_version-genericx86-64.qcow2 \
    sdwan-vsmart-$sdwan_version_dashes sdwan-vsmart $gcp_image_label
