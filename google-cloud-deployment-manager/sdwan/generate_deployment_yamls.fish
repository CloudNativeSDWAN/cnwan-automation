#!/usr/bin/env fish
#
# Copyright (C) 2021 Cisco Systems, Inc.
#
# @author  Lori Jakab <lojakab@cisco.com>

set script_dir (realpath (dirname (status -f)))

source $script_dir/variables.fish


env GCP_ZONE=$gcp_zone \
    GCP_REGION=$gcp_region \
    GCP_LABEL=$gcp_resource_label \
    SDWAN_NAMING_PREFIX=$sdwan_naming_prefix \
    SDWAN_MGMT_NET=$sdwan_mgmt_network \
    SDWAN_CTRL_NET=$sdwan_ctrl_network \
    SDWAN_CTRL_SITE_ID=$sdwan_ctrl_site_id \
    envsubst < $script_dir/sdwan-control-plane.yaml.tpl > $script_dir/dm/sdwan-control-plane.yaml

env GCP_ZONE=$gcp_zone \
    GCP_REGION=$gcp_region \
    GCP_LABEL=$gcp_resource_label \
    SDWAN_NAMING_PREFIX=$sdwan_naming_prefix \
    SERVICE_NETWORK=$service_network \
    SERVICE_NETWORK_IP=$service_network_ip \
    SDWAN_PUBI_NET=$sdwan_pubi_network \
    SDWAN_BIZI_NET=$sdwan_bizi_network \
    SDWAN_SITE_ID=$sdwan_site_id[1] \
    envsubst < $script_dir/sdwan-data-plane.yaml.tpl > $script_dir/dm/sdwan-data-plane.yaml
