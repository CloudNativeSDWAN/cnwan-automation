#!/usr/bin/env fish
#
# Copyright (C) 2020 Cisco Systems, Inc.
#
# @author  Lori Jakab <lojakab@cisco.com>

set sdwan_script_dir (realpath (dirname (status -f)))

source $sdwan_script_dir/cna_functions.fish
source $sdwan_script_dir/gcp_functions.fish
source $sdwan_script_dir/cloud-init_functions.fish


# Set SD-WAN related global variables
function sdwan_init
    set -g sdwan_password (yq r $cna_credentials_file "sdwan.password")
    set -g sdwan_version (yq r $cna_config_file "sdwan.version")
    set -g sdwan_version_dashes (string replace -a '.' '-' $sdwan_version)
    set -g sdwan_iosxe_version (yq r $cna_config_file "sdwan.iosxe_version")
    set -g sdwan_image_path $HOME/(yq r $cna_config_file "sdwan.image_path")
    set -g sdwan_image_ext (yq r $cna_config_file "sdwan.image_ext")
    set -g sdwan_cert_path $HOME/(yq r $cna_config_file "sdwan.cert_path")
    set -g sdwan_root_ca_file $sdwan_cert_path/root_ca.pem
    set -g sdwan_root_ca_key_file $sdwan_cert_path/ca_private_key.pem
    set -g sdwan_org_name (yq r $cna_config_file "sdwan.org_name")

    set -g sdwan_ctrl_vms vmanage vbond vsmart
    set -g sdwan_ctrl_ext_ips
    set -g sdwan_edge_vm_count (yq r $cna_config_file --length "sdwan.vedge")
    set -g sdwan_edge_ext_ips
end

function sdwan_create_cloud_images
    set sdwan_image_types vmanage vsmart vedge cedge
    for c in $sdwan_image_types
        set extension $sdwan_image_ext
        switch $c
            case vmanage
                set image_file_name viptela-vmanage-$sdwan_version-genericx86-64.$extension
                set cloud_image_name sdwan-$c-$sdwan_version_dashes
            case vsmart
                set image_file_name viptela-smart-$sdwan_version-genericx86-64.$extension
                set cloud_image_name sdwan-$c-$sdwan_version_dashes
            case vedge
                set image_file_name viptela-edge-$sdwan_version-genericx86-64.$extension
                set cloud_image_name sdwan-$c-$sdwan_version_dashes
            case cedge
                set extension qcow2
                set image_file_name csr1000v-universalk9.$sdwan_iosxe_version.$extension
                if test ! -r $sdwan_image_path/$image_file_name
                    set image_file_name csr1000v-ucmk9.$sdwan_iosxe_version.$extension
                end
                set cloud_image_name sdwan-$c-(string replace -a '.' '-' $sdwan_iosxe_version)
        end

        echo ""
        echo "[ℹ] Creating SD-WAN VM image '$cloud_image_name' on GCP..."
        gcp_create_compute_image $extension \
            $sdwan_image_path/$image_file_name \
            $cloud_image_name \
            sdwan-$c \
            sdwan
        echo "---"
    end
end

function sdwan_create_networks
    #set -g gcp_mgmt_prefix (gcloud compute networks subnets list --project $gcp_project --filter="network:default AND region:$gcp_region" --format="value(ipCidrRange)")
    #set -g gcp_mgmt_gateway (gcloud compute networks subnets list --project $gcp_project --filter="network:default AND region:$gcp_region" --format="value(gatewayAddress)")

    echo ""
    echo "[ℹ] Creating VPC networks..."
    echo ""
    for i in (seq 1 $gcp_network_count)
        set idx (math $i - 1)
        set network_name (yq r $cna_config_file "gcp.networks[$idx].name")
        set network_prefix (yq r $cna_config_file "gcp.networks[$idx].prefix")
        gcp_create_single_subnet_network $network_name $network_prefix
    end
end

function sdwan_scp
    set retries 3
    for i in (seq 1 $retries)
        echo "[ℹ] scp $argv[1] $argv[2]"
        scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
            -o LogLevel=ERROR $argv[1] $argv[2]
        if test $status -eq 0
            break
        end
        sleep $argv[3]
    end
end

function sdwan_scp_recursive
    set retries 3
    for i in (seq 1 $retries)
        echo "[ℹ] scp $argv[1] $argv[2]"
        scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
            -o LogLevel=ERROR -r $argv[1] $argv[2]
        if test $status -eq 0
            break
        end
        sleep $argv[3]
    end
end

function sdwan_api_login
    set retries 30
    for i in (seq 1 $retries)
        set http_status (curl --insecure --silent --location \
            --cookie-jar $sdwan_cert_path/cookies.txt --junk-session-cookies \
            --request POST "https://$sdwan_ctrl_ext_ips[1]:8443/j_security_check" \
            --header "Content-Type: application/x-www-form-urlencoded" \
            --data-urlencode "j_username=admin" \
            --data-urlencode "j_password=$sdwan_password" \
            --output /dev/null \
            --write-out "%{http_code}\n")
        if test "$http_status" = "200"
            break
        end
        echo ""
        echo "[ℹ] vManage REST API login failed."
        if test "$i" != "$retries"
            echo " Retrying..."
        else
            echo " Aborting."
        end
        sleep 2
    end
end

function sdwan_api_call
    set -l vmanage $sdwan_ctrl_ext_ips[1]
    set -l method $argv[1]
    set -l url $argv[2]
    set -l expected_status $argv[3]
    if test -n "$argv[4]"
        set header "-HContent-Type: application/json"
        set data "-d$argv[4]"
    end

    echo -n "[ℹ] vManage REST API $method $vmanage /dataservice/$url "
    if test "$method" = "POST" -o "$method" = "PUT"
        echo -n "$argv[4] "
    end
    echo ""

    sdwan_api_login

    set retries 5
    for i in (seq 1 $retries)
        echo -n "Output: "
        curl --insecure --silent --location \
            --cookie $sdwan_cert_path/cookies.txt \
            --request $method "https://$vmanage:8443/dataservice/$url" \
            $header \
            $data \
            --write-out "\nHTTP/%{http_version} %{http_code} (%{time_total}s)\n" | tee $local_tempdir/curl_output
        set http_code (tail -1 $local_tempdir/curl_output | awk '{ print $2; }')
        if test "$http_code" = "$expected_status"
            break
        end
        if test "$http_code" = "404" -o "$http_code" = "405"
            set delay 60
        else
            set delay 2
        end
        echo -n "[ℹ] vManage REST API call returned status $http_code instead of the expected $expected_status."
        if test "$i" != "$retries"
            echo " Retrying in $delay seconds..."
            sleep $delay
        else
            echo ""
            echo "*** ABORTED! ***"
        end
    end
    echo ""
end

function sdwan_create_certificate_authority
    if test -r $sdwan_root_ca_file
        echo "[ℹ] Using existing root certificate authority from $sdwan_root_ca_file"
        return
    end

    echo "[ℹ] Creating SD-WAN root certificate authority..."
    mkdir -p $sdwan_cert_path
    # Make folder readable only by the current user
    chmod 700 $sdwan_cert_path
    openssl req -new -x509 -extensions v3_ca -days 365 -newkey rsa:4096 \
        -keyout $sdwan_root_ca_key_file -out $sdwan_root_ca_file -nodes \
        -subj (yq r $cna_config_file "sdwan.root_ca_subject")
end

function sdwan_install_certificate
    set vm_name $argv[1]
    set external_ip $argv[2]

    echo "[ℹ] Generating certificate for $vm_name..."
    sdwan_scp $sdwan_root_ca_file "admin@$external_ip:/home/admin/root-ca-chain.crt" 60
    $sdwan_script_dir/sdwan_expect-scripts/sdwan_cert_create_csr.expect \
        $external_ip "$vm_name#" $sdwan_org_name; or exit 1
    echo ""
    sdwan_scp "admin@$external_ip:/home/admin/controller.csr" $sdwan_cert_path/$vm_name.csr 10
    openssl x509 -req -in $sdwan_cert_path/$vm_name.csr \
                -CA $sdwan_root_ca_file -CAkey $sdwan_root_ca_key_file \
                -CAcreateserial -out $sdwan_cert_path/$vm_name.crt -days 3650 -sha256
    sdwan_scp $sdwan_cert_path/$vm_name.crt "admin@$external_ip:/home/admin/controller.crt" 10
    $sdwan_script_dir/sdwan_expect-scripts/sdwan_cert_install_signed.expect \
        $external_ip "$vm_name#"; or exit 1
end

function sdwan_create_control_plane_vms
    for vm in $sdwan_ctrl_vms
        ci_create_user_data_sdwan $vm $gcp_ntp \
            (yq r $cna_config_file "gcp.networks.(name==cnwan-mgmt).gateway") \
            (yq r $cna_config_file "gcp.networks.(name==cnwan-ctrl).gateway")
        set vm_name (yq r $cna_config_file "sdwan.$vm.vm_name")
        set vm_description (yq r $cna_config_file "sdwan.$vm.vm_description")
        set vm_family sdwan-$vm
        set vm_prompt "$vm#"
        set mgmt_ip (yq r $cna_config_file "sdwan.$vm.mgmt_static_ip")
        set ctrl_ip (yq r $cna_config_file "sdwan.$vm.ctrl_static_ip")

        # GCP specific part
        echo "[ℹ] Creating VM $vm_name..."
        if test "$vm" = "vbond"
            set vm_family sdwan-vedge
            set vm_prompt "vedge#"
            gcp_create_vm_instance_2subnet $vm_name $vm_description \
                $vm_family $gcp_project \
                "user-data=$local_tempdir/user-data" \
                cnwan-mgmt "$mgmt_ip" \
                cnwan-ctrl "$ctrl_ip"
        else
            gcp_create_vm_instance_2subnet $vm_name $vm_description \
                $vm_family $gcp_project \
                "user-data=$local_tempdir/user-data" \
                cnwan-ctrl "$ctrl_ip" \
                cnwan-mgmt "$mgmt_ip,no-address"
        end
        gcp_vm_instance_enable_serial_port $gcp_zone $vm_name
        #gcp_vm_instance_add_ptr $vm_name $vm_name.$gcp_domain
        set nic0_network (gcloud compute instances describe $vm_name --project $gcp_project --zone $gcp_zone --format="value(networkInterfaces[0].network.scope())")
        set external_ip (gcloud compute instances describe $vm_name --project $gcp_project --zone $gcp_zone --format="value(networkInterfaces[0].accessConfigs.natIP)")
        # End GCP specific part

        echo "[ℹ] Uploading initial configuration for $vm_name..."
        $sdwan_script_dir/sdwan_expect-scripts/sdwan_initial_config.expect \
            $gcp_project $gcp_zone $vm_name $vm_prompt $local_tempdir/user-data; or exit 1
        echo ""

        sdwan_install_certificate $vm_name $external_ip
        echo ""; echo "---"; echo ""
    end
end

function sdwan_configure_control_plane_vms
    sdwan_api_call GET "system/device/sync/rootcertchain" 200

    sdwan_api_call PUT "settings/configuration/organization" 200 \
        "{\"domain-id\": \"1\", \"org\": \"$sdwan_org_name\"}"

    set vbond (yq r $cna_config_file "sdwan.vbond.ctrl_static_ip")
    set vsmart (yq r $cna_config_file "sdwan.vsmart.ctrl_static_ip")
    sdwan_api_call PUT "settings/configuration/device" 200 \
        "{\"domainIp\": \"$vbond\", \"port\": \"12346\"}"
    sdwan_api_call POST "system/device" 200 \
        "{\"deviceIP\": \"$vbond\", \"username\": \"admin\", \"password\": \"$sdwan_password\", \"personality\": \"vbond\", \"generateCSR\": false}"
    sdwan_api_call POST "system/device" 200 \
        "{\"deviceIP\": \"$vsmart\", \"username\": \"admin\", \"password\": \"$sdwan_password\", \"protocol\": \"DTLS\", \"personality\": \"vsmart\", \"generateCSR\": false}"
end

# TODO  generalize function like the control VM one
function sdwan_create_data_plane_vm
    set vm $argv[1]
    set vm_i "$vm""[$argv[2]]"
    set vm_name (yq r $cna_config_file "sdwan.$vm_i.vm_name")
    set vm_zone (yq r $cna_config_file "sdwan.$vm_i.zone")
    set vm_description (yq r $cna_config_file "sdwan.$vm_i.vm_description")
    set vm_family sdwan-$vm
    set vm_prompt "$vm#"
    set system_ip (yq r $cna_config_file "sdwan.$vm_i.system_ip")
    set host (string split -r -m1 . $system_ip)[2]
    set mgmt_ip (yq r $cna_config_file "sdwan.$vm_i.mgmt_static_ip")
    set ctrl_ip (yq r $cna_config_file "sdwan.$vm_i.ctrl_static_ip")
    set service_network (yq r $cna_config_file "sdwan.$vm_i.service_network")
    set service_ip (yq r $cna_config_file "sdwan.$vm_i.service_static_ip")
    # set vbond_vm_name (yq r $cna_config_file "sdwan.vbond.vm_name")
    # set vbond_ip (gcloud compute instances describe $vbond_vm_name --project $gcp_project --zone $gcp_zone --format="value(networkInterfaces[1].accessConfigs.natIP)" ^ /dev/null)

    ci_create_user_data_sdwan $vm_i $gcp_ntp \
        (yq r $cna_config_file "gcp.networks.(name==cnwan-mgmt).gateway") \
        (yq r $cna_config_file "gcp.networks.(name==cnwan-ctrl).gateway") \
        (yq r $cna_config_file "gcp.networks.(name==cnwan-public-internet).gateway") \
        (yq r $cna_config_file "gcp.networks.(name==cnwan-biz-internet).gateway") \
        $service_ip/24

    gcp_create_vm_instance_vedge $vm_name $vm_description \
        $vm_family $gcp_project $vm_zone \
        "user-data=$local_tempdir/user-data" \
        cnwan-mgmt "$mgmt_ip" \
        cnwan-public-internet "10.3.1.$host" \
        cnwan-biz-internet "10.4.1.$host,no-address" \
        $service_network "$service_ip,no-address"

    gcp_vm_instance_enable_serial_port $gcp_zone $vm_name
    set external_ip (gcloud compute instances describe $vm_name --project $gcp_project --zone $gcp_zone --format="value(networkInterfaces[0].accessConfigs.natIP)")

    echo "[ℹ] Uploading initial configuration for $vm_name..."
    $sdwan_script_dir/sdwan_expect-scripts/sdwan_initial_config.expect \
        $gcp_project $gcp_zone $vm_name $vm_prompt $local_tempdir/user-data; or exit 1
    echo ""; echo "---"; echo ""
end

function sdwan_configure_data_plane_vm
    set vm $argv[1]
    set vm_i "$vm""[$argv[2]]"
    set vm_name (yq r $cna_config_file "sdwan.$vm_i.vm_name")
    set vm_zone (yq r $cna_config_file "sdwan.$vm_i.zone")
    set external_ip (gcloud compute instances describe $vm_name --project $gcp_project --zone $vm_zone --format="value(networkInterfaces[0].accessConfigs.natIP)" ^ /dev/null)

    sdwan_install_certificate $vm_name $external_ip

    set vedge_info ($sdwan_script_dir/sdwan_expect-scripts/sdwan_retrieve_vedge_info.expect $external_ip "$vm_name#")
    set chassis (string split " " $vedge_info)[1]
    set serial (string split " " $vedge_info)[2]

    for vm in $sdwan_ctrl_vms
        set vm_name (yq r $cna_config_file "sdwan.$vm.vm_name")
        set external_ip (gcloud compute instances describe $vm_name --project $gcp_project --zone $gcp_zone --format="value(networkInterfaces[0].accessConfigs.natIP)" ^ /dev/null)
        $sdwan_script_dir/sdwan_expect-scripts/sdwan_register_vedge.expect \
            $external_ip "$vm_name#" $chassis $serial $sdwan_org_name
    end
end

function sdwan_create_data_plane_vms
    for i in (seq 1 $sdwan_edge_vm_count)
        sdwan_create_data_plane_vm vedge (math $i - 1)
    end
end

function sdwan_configure_data_plane_vms
    for i in (seq 1 $sdwan_edge_vm_count)
        sdwan_configure_data_plane_vm vedge (math $i - 1)
    end
end

function sdwan_get_external_ips
    for vm in $sdwan_ctrl_vms
        set vm_name (yq r $cna_config_file "sdwan.$vm.vm_name")
        set external_ip (gcloud compute instances describe $vm_name --project $gcp_project --zone $gcp_zone --format="value(networkInterfaces[0].accessConfigs.natIP)" ^ /dev/null)
        set sdwan_ctrl_ext_ips $sdwan_ctrl_ext_ips $external_ip
    end

    for i in (seq 1 $sdwan_edge_vm_count)
        set idx (math $i - 1)
        set vm_name (yq r $cna_config_file "sdwan.vedge[$idx].vm_name")
        set zone (yq r $cna_config_file "sdwan.vedge[$idx].zone")
        set external_ip (gcloud compute instances describe $vm_name --project $gcp_project --zone $zone --format="value(networkInterfaces[0].accessConfigs.natIP)" ^ /dev/null)
        set sdwan_edge_ext_ips $sdwan_edge_ext_ips $external_ip
    end
end

function sdwan_show_info
    echo "[ℹ] vManage external IP: $sdwan_ctrl_ext_ips[1]"
    echo "[ℹ] vBond   external IP: $sdwan_ctrl_ext_ips[2]"
    echo "[ℹ] vSmart  external IP: $sdwan_ctrl_ext_ips[3]"
    for i in (seq 1 $sdwan_edge_vm_count)
        echo "[ℹ] vEdge $i external IP: $sdwan_edge_ext_ips[$i]"
    end
end
