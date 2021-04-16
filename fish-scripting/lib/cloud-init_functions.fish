#!/usr/bin/env fish
#
# Copyright (C) 2020 Cisco Systems, Inc.
#
# @author  Lori Jakab <lojakab@cisco.com>

set ci_script_dir (realpath (dirname (status -f)))


function ci_get_local_ssh_pubkey
    if test -r $HOME/.ssh/id_rsa.pub
        set -g local_ssh_pubkey (awk '{ print $2; }' $HOME/.ssh/id_rsa.pub)
    end
end

function ci_create_user_data_sdwan
    set role $argv[1]
    set conf sdwan.$argv[1]
    set vbond (yq e ".sdwan.vbond.ctrl_static_ip" $cna_config_file)
    if test "$vbond" = "null"
        set vbond $argv[8]
    end
    if test "$argv[1]" = "vbond"
        set vbond "$vbond local"
    end

    string match -qie vedge $role
    if test $status -eq 0
        set role vedge
    end

    set sdwan_pubkey_entry "!"
    ci_get_local_ssh_pubkey
    if test -n "$local_ssh_pubkey"
        set sdwan_pubkey_entry "pubkey-chain automation key-string $local_ssh_pubkey"
    end

    set vm_name (yq e ".$conf.vm_name" $cna_config_file)
    set vm_name "$sdwan_naming_prefix-$vm_name"
    set site_id (yq e ".$conf.site_id" $cna_config_file)
    if test "$site_id" = "null"
        set site_id $sdwan_ctrl_site_id
    end

    env VM_NAME=$vm_name \
        SDWAN_SYSTEM_IP=(yq e ".$conf.system_ip" $cna_config_file) \
        SDWAN_SITE_ID=$site_id \
        SDWAN_ORG=$sdwan_org_name \
        SDWAN_VBOND_IP=$vbond \
        SDWAN_GEO_LAT=(yq e ".sdwan.geolocation.latitude" $cna_config_file) \
        SDWAN_GEO_LON=(yq e ".sdwan.geolocation.longitude" $cna_config_file) \
        SDWAN_PASSWORD=$sdwan_password \
        SDWAN_PUBKEY=$sdwan_pubkey_entry \
        NTP_SERVER=$argv[2] \
        envsubst < $ci_script_dir/cloud-init_templates/user-data-sdwan-common.tpl > $local_tempdir/user-data
    env VM_GATEWAY_MGMT=$argv[3] \
        VM_GATEWAY_CTRL=$argv[4] \
        VM_GATEWAY_PUB=$argv[5] \
        VM_GATEWAY_BIZ=$argv[6] \
        IP_PREFLEN_SERVICE=$argv[7] \
        envsubst < $ci_script_dir/cloud-init_templates/user-data-sdwan-$role.tpl >> $local_tempdir/user-data
end


function ci_create_user_data_linux_host
    cat $ci_script_dir/cloud-init_templates/user-data-linux-common > $local_tempdir/user-data
end

function ci_create_user_data_linux_router
    cat $ci_script_dir/cloud-init_templates/user-data-linux-common > $local_tempdir/user-data
    cat $ci_script_dir/cloud-init_templates/user-data-linux-extra-router >> $local_tempdir/user-data
end
