#!/usr/bin/env fish
#
# Copyright (C) 2020 Cisco Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
# @author  Lori Jakab <lojakab@cisco.com>

set script_dir (realpath (dirname (status -f)))

source $script_dir/lib/cna_functions.fish
source $script_dir/lib/sdwan_functions.fish


cna_get_required_config $argv[1]

gcloud -q compute instances delete cnwan-streaming-client --project $gcp_project

$script_dir/sdwan_cleanup.fish $argv[1]
