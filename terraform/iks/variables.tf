variable "apikey" {
  type        = string
  description = "API Key"
}
variable "secretkey" {
  type        = string
  description = "Secret Key or file location"
}
variable "endpoint" {
  type        = string
  description = "API Endpoint URL"
  default     = "https://www.intersight.com"
}
variable "cluster_name" {
  type        = string
  description = "Name for the Kubernetes cluster in IKS"
  default     = "iks-terraform"
}
variable "ssh_user" {
  type        = string
  description = "SSH Username for node login."
}
variable "ssh_key" {
  type        = string
  description = "SSH Public Key to be used to node login."
}
variable "k8s_version_policy_name" {
  type        = string
  description = "Name for the Kubernetes version policy"
  default     = "iks-terraform-version"
}
variable "k8s_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.19.5"
}
variable "instance_type" {
  type        = string
  description = "Name for the instance type used"
  default     = "iks-terraform-instance-type"
}
variable "vc_name" {
  type        = string
  description = "vCenter policy name"
  default     = "iks-terraform-vm-config"
}
variable "vc_target" {
  type        = string
  description = "vCenter host"
}
variable "vc_password" {
  sensitive   = true
  type        = string
  description = "Password of the account to be used with vCenter.  This should be the password for the account used to register vCenter with Intersight."
}
variable "vc_cluster" {
  type        = string
  description = "vSphere cluster to deploy into"
}
variable "vc_portgroup" {
  type        = list(string)
  description = "The vSphare network where the cluster should be connected"
  default     = ["VM Network"]
}
variable "vc_datastore" {
  type        = string
  description = "Name of the vSphare datastore for the VMs"
  default     = "datastore1"
}
variable "vc_resources" {
  type        = string
  description = "vSphare resource pool"
  default     = ""
}
variable "ip_pool_name" {
  type        = string
  description = "A name for the IP pool"
  default     = "iks-terraform-pool"
}
variable "ip_start" {
  type        = string
  description = "The start IP address for the IP pool"
}
variable "ip_pool_size" {
  type        = number
  description = "Size of the IP pool"
}
variable "ip_netmask" {
  type        = string
  description = "Netmask of the IP pool subnet"
}
variable "ip_gateway" {
  type        = string
  description = "Gateway IP of the IP pool subnet"
}
variable "ntp_servers" {
  type        = list(string)
  description = "List of NTP servers"
}
variable "dns_servers" {
  type        = list(string)
  description = "List of DNS servers"
}
variable "sysconfig_name" {
  type        = string
  description = "A name for the system/network configuration"
  default     = "iks-terraform-sys-config-policy"
}
variable "runtime_policy_name" {
  type        = string
  description = "A name for the container runtime policy configuration"
  default     = "iks-terraform-container-runtime-policy"
}
variable "k8s_netconfig_name" {
  type        = string
  description = "A name for the k8s internal network configuration"
  default     = "iks-terraform-network-policy"
}
variable "trusted_registry_name" {
  type        = string
  description = "A name for the trusted registry configuration"
  default     = "iks-terraform-trusted-registries"
}
variable "tags" {
  type    = list(map(string))
  default = []
}
variable "organization" {
  type        = string
  description = "Organization Name"
  default     = "default"
}
