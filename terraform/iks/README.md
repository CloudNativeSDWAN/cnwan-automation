# Terraform Intersight Kubernetes Cluster Module

This module builds a complete cluster along with all of the required components.

## Assumptions

* You want to create an IKS cluster on your on-premises infrastructure using Intersight.
* These resources will be provided using Intersight and VMware vCenter 6.7.
* You've claimed vCenter using the Intersight Assist Appliance.

## Details

This module creates all of the resources required for IKS.  Some customization is being enabled but currently there are some caveats:

1. Re-using IP Pools is not available in this module yet.
2. Currently 3 "t-shirt" sizes are built
   * small - 4vcpu, 16GB Memory, 40GB Disk
   * medium - 8vcpu, 24GB Memory, 60GB Disk
   * large - 12vcpu, 32GB Memory, 80GB Disk
3. 2 DNS and 2 NTP servers are required.  If you do not have 2, list the single DNS and NTP server twice.

## Requirements

| Name | Version |
|------|---------|
| terraform | >=0.14.5 |
| intersight | =1.0.11 |
