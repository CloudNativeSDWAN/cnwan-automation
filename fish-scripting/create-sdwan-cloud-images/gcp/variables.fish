#!/usr/bin/env fish

set variables_script_dir (realpath (dirname (status -f)))

#
# LOCAL
#
set -g cna_config_file $variables_script_dir/variables.yaml
set -g local_tempdir (yq e ".local.tempdir" $cna_config_file)

#
# GCP
#
set -g gcp_project (yq e ".gcp.project" $cna_config_file)
set -g gcp_zone (yq e '.gcp.zone // "us-west1-b"' $cna_config_file)
set -g gcp_region (string split -r -m1 '-' $gcp_zone)[1]
set -g gcp_image_label (yq e ".gcp.image_label" $cna_config_file)
set -g gcp_resource_labels $gcp_image_label=
