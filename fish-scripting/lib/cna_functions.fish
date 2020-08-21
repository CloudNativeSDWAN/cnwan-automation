#!/usr/bin/env fish
#
# Copyright (C) 2020 Cisco Systems, Inc.
#
# @author  Lori Jakab <lojakab@cisco.com>

set cna_script_dir (realpath (dirname (status -f)))

function cna_set_config_file
    # The default configuration file can be overridden on invocation
    if test -n "$argv"
        set -g cna_config_file $argv
    else
        set -g cna_config_file $cna_script_dir/../cnwan.yaml
    end

    echo "[ℹ] Using configuration file $cna_config_file"
end

function cna_set_credentials_file
    # The default credentials file can be overridden on invocation
    if test -n "$argv"
        set -g cna_credentials_file $argv
    else
        set -g cna_credentials_file $cna_script_dir/../credentials.yaml
    end

    echo "[ℹ] Using credentials file $cna_credentials_file"
end

function cna_exit_if_not_set
    if ! test -n "$argv[1]"
        echo "Property $argv[2] is not set ($argv[1]) in $cna_config_file, exiting..."
        exit 1
    end
end

function cna_get_required_config
    cna_set_config_file $argv[1]
    cna_set_credentials_file $argv[2]

    set -g local_tempdir (yq r $cna_config_file "local.tempdir")

    set -g gcp_project (yq r $cna_config_file "gcp.project"); and cna_exit_if_not_set $gcp_project gcp.project
    set -g gcp_zone (yq r $cna_config_file --defaultValue us-west2-c "gcp.zone")
    set -g gcp_region (string split -r -m1 '-' $gcp_zone)[1]
    set -g gcp_resource_labels (yq r $cna_config_file "gcp.resource_label")=
    set -g gcp_cisco_infosec_labels (yq r $cna_config_file "gcp.cisco_infosec_labels" --stripComments | sed -e ':a' -e 'N;$!ba' -e 's/\n/,/g' -e 's/: /=/g')
    if test -n "$gcp_cisco_infosec_labels"
        set -g gcp_resource_labels "$gcp_resource_labels,$gcp_cisco_infosec_labels"
    end
    echo "[ℹ] GCP labels: $gcp_resource_labels"
    set -g gcp_ntp (yq r $cna_config_file "gcp.ntp")
    set -g gcp_domain (yq r $cna_config_file "gcp.domain")
    set -g gcp_network_count (yq r $cna_config_file --length "gcp.networks")
end
