#!/usr/bin/env fish

set variables_script_dir (realpath (dirname (status -f)))

function set_config_file
    if test -n "$argv"
        set -g config_file $argv
    else
        set -g config_file $variables_script_dir/sdwan-variables.yaml
    end
end

# Use the Fish library functions to read default variables from the configuration
set_config_file
source $variables_script_dir/../../fish-scripting/lib/sdwan_functions.fish
cna_get_required_config $config_file $config_file
sdwan_init

# Extra variables
set -g gcp_deployment $gcp_resource_label
set -g gcp_cluster $gcp_resource_label
set -g service_network 10.100.111.0/24
set -g service_network_ip 10.100.111.11
set -g service_network_ip_mask 10.100.111.11/24
set -g sdwan_pubi_network (yq e '.sdwan.vedge[0].pubi_network' $cna_config_file)
set -g sdwan_bizi_network (yq e '.sdwan.vedge[0].bizi_network' $cna_config_file)
# TODO  make this dynamic, based on the number of vEdges in the config file
set -g sdwan_site_id (yq e '.sdwan.vedge[0].site_id' $cna_config_file)
set -g sdwan_site_id $sdwan_site_id (yq e '.sdwan.vedge[1].site_id' $cna_config_file)
