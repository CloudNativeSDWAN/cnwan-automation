#!/usr/bin/env fish
#
# Copyright (C) 2021 Cisco Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
# @author  Lori Jakab <lojakab@cisco.com>


set script_dir (realpath (dirname (status -f)))

source $script_dir/variables.fish

gcloud -q container clusters delete $gcp_cluster \
    --zone $gcp_zone \
    --project $gcp_project 2> /dev/null
