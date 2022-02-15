#!/usr/bin/env fish
#
# Copyright (C) 2021 Cisco Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
# @author  Lori Jakab <lojakab@cisco.com>


set script_dir (realpath (dirname (status -f)))

source $script_dir/variables.fish

gcloud -q deployment-manager deployments delete $gcp_deployment-vedge \
    --project $gcp_project
