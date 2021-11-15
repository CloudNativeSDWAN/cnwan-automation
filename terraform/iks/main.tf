provider "intersight" {
  apikey    = var.apikey
  secretkey = var.secretkey
  endpoint  = var.endpoint
}

module "terraform-intersight-iks" {
  source = "terraform-cisco-modules/iks/intersight"

  # Cluster information
  cluster = {
    name                = var.cluster_name
    # You can try using `action = "Deploy"` below, but as things are right
    # now, deployment will likely fail. If you apply as-is first, then apply
    # again with `Deploy`, creating a cluster should work without using the
    # Intersight UI. Alternatively, apply as-is, than `Deploy` from the UI
    # manually. Destroying the cluster will need manual "Undeploy" in the UI
    # first either way!
    action              = "Unassign"
    wait_for_completion = true
    ssh_user            = var.ssh_user
    ssh_public_key      = var.ssh_key
    worker_nodes        = 2
    worker_max          = 3
    control_nodes       = 1
    load_balancers      = 2
  }

  # Kubernetes version policy, only 1.19.5 is available now
  version_policy = {
    use_existing = false
    name         = var.k8s_version_policy_name
    version      = var.k8s_version
  }

  # VMware instance configuration
  instance_type = {
    use_existing = false
    name         = var.instance_type
    cpu          = 4
    memory       = 16386
    disk_size    = 40
  }

  # Infra Config Policy Information
  infraConfigPolicy = {
    use_existing       = false
    platformType       = "esxi"
    policyName         = var.vc_name
    description        = "vCenter Policy"
    targetName         = var.vc_target
    interfaces         = var.vc_portgroup
    vcClusterName      = var.vc_cluster
    vcDatastoreName    = var.vc_datastore
    vcPassword         = var.vc_password
    vcResourcePoolName = var.vc_resources
  }

  # IP Pool Information
  ip_pool = {
    use_existing        = false
    name                = var.ip_pool_name
    ip_starting_address = var.ip_start
    ip_pool_size        = var.ip_pool_size
    ip_netmask          = var.ip_netmask
    ip_gateway          = var.ip_gateway
    dns_servers         = var.dns_servers
  }

  # Network Configuration Settings
  sysconfig = {
    use_existing = false
    name         = var.sysconfig_name
    domain_name  = "cisco.com"
    timezone     = "America/Los_Angeles"
    ntp_servers  = var.ntp_servers
    dns_servers  = var.dns_servers
  }

  # Optional Proxy Configuration for Docker
  # runtime_policy = {
  #   use_existing         = false
  #   create_new           = true
  #   name                 = var.runtime_policy_name
  #   http_proxy_protocol  = "http"
  #   http_proxy_hostname  = "proxy.esl.cisco.com"
  #   http_proxy_port      = 8080

  #   https_proxy_protocol = "http"
  #   https_proxy_hostname = "proxy.esl.cisco.com"
  #   https_proxy_port     = 8080
  # }

  # Kubernetes internal network configuration
  k8s_network = {
    use_existing = false
    name         = var.k8s_netconfig_name
    pod_cidr     = "100.65.0.0/16"
    service_cidr = "100.64.0.0/16"
    cni          = "Calico"
  }

  tr_policy = {
    use_existing = false
    create_new   = false
    name         = var.trusted_registry_name
  }

  # IKS add-ons. Only two are available, both are recommended
  addons_list = [{
      addon_policy_name = "dashboard"
      addon             = "kubernetes-dashboard"
      description       = "K8s Dashboard Policy"
      upgrade_strategy  = "AlwaysReinstall"
      install_strategy  = "InstallOnly"
    },
    {
      addon_policy_name = "monitor"
      addon             = "ccp-monitor"
      description       = "Grafana Policy"
      upgrade_strategy  = "AlwaysReinstall"
      install_strategy  = "InstallOnly"
    }
  ]

  # Organization and Tag
  organization = var.organization
  tags         = var.tags
}
