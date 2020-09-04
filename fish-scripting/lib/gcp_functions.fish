#!/usr/bin/env fish
#
# Copyright (C) 2020 Cisco Systems, Inc.
#
# @author  Lori Jakab <lojakab@cisco.com>

function gcp_assert_image_type
    set image_type (qemu-img info $argv[2] | grep "file format" | awk '{ print $3; }')
    if test "$image_type" != "$argv[1]"
        echo "$argv[2] is not a $argv[1] image, aborting..."
        exit 1
    end
end

function gcp_create_compute_image
    set storage_bucket cna-images-(string lower (uuidgen | cut -d '-' -f 1))
    set image_disk $argv[2]
    set image_basename (string split -r -m1 . (basename $argv[2]))[1]
    if test $argv[1] = "ova"
        set image_disk $local_tempdir/(gtar -xvf $argv[2] -C $local_tempdir | grep "\.vmdk")
        gcp_assert_image_type vmdk $image_disk
    else
        gcp_assert_image_type $argv[1] $image_disk
    end
    qemu-img convert -O raw $image_disk $local_tempdir/disk.raw
    if test $argv[1] = "ova"
        rm $image_disk
    end
    gtar --format=oldgnu -Sczf $local_tempdir/$image_basename.tar.gz -C $local_tempdir disk.raw
    rm $local_tempdir/disk.raw
    gsutil mb -p $gcp_project -l $gcp_region gs://$storage_bucket; or exit 2
    # Avoid using parallel upload, since it has issues. Biggest image is around 1.6GB
    gsutil -o GSUtil:parallel_composite_upload_threshold=2G \
        cp $local_tempdir/$image_basename.tar.gz gs://$storage_bucket; or gcp_create_compute_image_error $storage_bucket
    rm -f $local_tempdir/$image_basename.tar.gz
    gcp_delete_compute_image $argv[3]
    gcloud compute images create $argv[3] \
        --source-uri gs://$storage_bucket/$image_basename.tar.gz \
        --family $argv[4] \
        --guest-os-features MULTI_IP_SUBNET \
        --labels $argv[5]= \
        --project $gcp_project
    gcp_delete_storage $storage_bucket
end

function gcp_create_compute_image_error
    gcp_delete_storage $argv
    exit 2
end

function gcp_delete_compute_image
    gcloud -q compute images delete $argv --project $gcp_project ^ /dev/null
end

function gcp_delete_storage
    gsutil rm -r gs://$argv
end

# Every VPC network has two implied firewall rules. One implied rule allows
# most egress traffic, and the other denies all ingress traffic. You cannot
# delete the implied rules, but you can override them with your own. Google
# Cloud always blocks some traffic, regardless of firewall rules.
function gcp_create_firewall_rule_allow_all_ingress
    gcloud compute firewall-rules create $argv-allow-all \
        --network $argv \
        --direction INGRESS \
        --priority 65534 \
        --allow all \
        --source-ranges 0.0.0.0/0 \
        --project $gcp_project
end

function gcp_delete_firewall_rule_allow_all_ingress
    gcloud -q compute firewall-rules delete $argv-allow-all \
        --project $gcp_project
end

function gcp_create_network
    gcloud compute networks create $argv \
        --bgp-routing-mode regional \
        --subnet-mode custom \
        --project $gcp_project
end

# This only works if all resources referencing the network are deleted already
function gcp_delete_network
    gcloud -q compute networks delete $argv \
        --project $gcp_project
end

function gcp_create_subnet
    gcloud compute networks subnets create $argv[2] \
        --network $argv[1] \
        --range $argv[3] \
        --project $gcp_project \
        --region $gcp_region
end

function gcp_delete_subnet
    gcloud -q compute networks subnets delete $argv \
        --project $gcp_project \
        --region $gcp_region
end

function gcp_create_single_subnet_network
    gcp_create_network $argv[1]
    gcp_create_firewall_rule_allow_all_ingress $argv[1]
    gcp_create_subnet $argv[1] $argv[1]-default $argv[2]
end

function gcp_delete_single_subnet_network
    gcp_delete_subnet $argv[1]-default
    gcp_delete_firewall_rule_allow_all_ingress $argv[1]
    gcp_delete_network $argv[1]
end

function gcp_get_nic_gateway
    set zone $argv[1]
    set vm_name $argv[2]
    set nic_idx $argv[3]

    set nic_subnet_scope (string split / (gcloud compute instances describe $vm_name --zone $zone --format="value(networkInterfaces[$nic_idx].subnetwork.scope())"))
    set region $nic_subnet_scope[1]
    set subnet $nic_subnet_scope[3]
    set subnet_gw (gcloud compute networks subnets describe $subnet --region $region --format="value(gatewayAddress)")
    echo "$subnet_gw"
end

function gcp_get_nic_masklen
    set zone $argv[1]
    set vm_name $argv[2]
    set nic_idx $argv[3]

    set nic_subnet_scope (string split / (gcloud compute instances describe $vm_name --zone $zone --format="value(networkInterfaces[$nic_idx].subnetwork.scope())"))
    set region $nic_subnet_scope[1]
    set subnet $nic_subnet_scope[3]
    set subnet_cidr (gcloud compute networks subnets describe $subnet --region $region --format="value(ipCidrRange)")
    set subnet_mask (string split / $subnet_cidr)[2]
    echo "$subnet_mask"
end

function gcp_create_vm_instance_2subnet
    # vManage VMs require a second separate disk for the database
    string match -qie vmanage $argv[1]
    if test $status -eq 0
        set create_disk "--create-disk=size=20GB"
    end
    gcloud compute instances create $argv[1] \
        --description $argv[2] \
        --labels $gcp_resource_labels \
        --machine-type n1-standard-2 \
        --image-family $argv[3] \
        --image-project $argv[4] \
        --metadata-from-file $argv[5] \
        $create_disk \
        # PREMIUM is the default, but leaving it here to be explicit
        --network-tier PREMIUM \
        --network-interface subnet=$argv[6]-default,private-network-ip=$argv[7] \
        --network-interface subnet=$argv[8]-default,private-network-ip=$argv[9] \
        --project $gcp_project \
        --zone $gcp_zone; or exit 1
end

function gcp_create_vm_instance_3subnet
    gcloud compute instances create $argv[1] \
        --description $argv[2] \
        --labels $gcp_resource_labels \
        # n1-standard-1 or n1-standard-2 only allow 2 network interfaces
        --machine-type n1-standard-4 \
        --image-family $argv[3] \
        --image-project $argv[4] \
        --metadata-from-file $argv[5] \
        # PREMIUM is the default, but leaving it here to be explicit
        --network-tier PREMIUM \
        --can-ip-forward \
        --network-interface subnet=$argv[6]-default,private-network-ip=$argv[7] \
        --network-interface subnet=$argv[8]-default,private-network-ip=$argv[9] \
        --network-interface subnet=$argv[10]-default,private-network-ip=$argv[11] \
        --project $gcp_project \
        --zone $gcp_zone; or exit 1
end

function gcp_create_vm_instance_vedge
    gcloud compute instances create $argv[1] \
        --description $argv[2] \
        --labels $gcp_resource_labels \
        --custom-cpu 4 \
        --custom-memory 4 \
        --image-family $argv[3] \
        --image-project $argv[4] \
        --metadata-from-file $argv[6] \
        # PREMIUM is the default, but leaving it here to be explicit
        --network-tier PREMIUM \
        --can-ip-forward \
        --network-interface subnet=$argv[7]-default,private-network-ip=$argv[8] \
        --network-interface subnet=$argv[9]-default,private-network-ip=$argv[10] \
        --network-interface subnet=$argv[11]-default,private-network-ip=$argv[12] \
        --network-interface subnet=$argv[13]-default,private-network-ip=$argv[14] \
        --project $gcp_project \
        --zone $argv[5]; or exit 1
end

function gcp_vm_instance_enable_serial_port
    gcloud compute instances add-metadata $argv[2] \
        --metadata serial-port-enable=TRUE \
        --project $gcp_project \
        --zone $argv[1]
end

function gcp_vm_instance_add_ptr
    gcloud compute instances update-access-config $argv[1] \
        --public-ptr \
        --public-ptr-domain $argv[2] \
        --project $gcp_project \
        --zone $argv[1]
end

function gcp_delete_vm_instance
    gcloud -q compute instances delete $argv \
        --project $gcp_project \
        --zone $gcp_zone
end
