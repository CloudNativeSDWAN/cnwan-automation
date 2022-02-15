#!/usr/bin/env fish
#
# Copyright (C) 2020 Cisco Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
# @author  Lori Jakab <lojakab@cisco.com>

set cnwan_script_dir (realpath (dirname (status -f)))

source $cnwan_script_dir/cna_functions.fish
source $cnwan_script_dir/gcp_functions.fish


# Create a Windows based client VM with VLC preinstalled
function cnwan_create_client_vm
    gcp_create_vm_instance_2subnet cnwan-streaming-client \
        "Streaming Video client VM with VLC" \
        windows-2019 windows-cloud \
        "windows-startup-script-ps1=$cnwan_script_dir/powershell_scripts/cnwan-client.ps1" \
        cnwan-mgmt "10.1.1.10" \
        cnwan-streaming-client "10.5.1.10,no-address"
end
