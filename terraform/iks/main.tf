provider "intersight" {
  apikey    = var.apikey
  secretkey = var.secretkey
  endpoint  = var.endpoint
}

module "terraform-intersight-iks" {
  source = "terraform-cisco-modules/iks/intersight"

  # Cluster information
  cluster_name   = var.cluster_name
  ssh_user       = var.ssh_user
  ssh_key        = var.ssh_key
  worker_size    = "small"
  worker_count   = 2
  master_count   = 1
  load_balancers = 2

  # If you apply directly with the next line uncommented, deployment will
  # likely fail. Once applied commented, then applied uncommented should work.
  # Destroying the cluster will need manual "Undeploy" in the GUI first!
  #cluster_action   = "Deploy"

  # Infra Config Policy Information
  vc_target_name   = var.vc_target
  vc_password      = var.vc_password
  vc_cluster       = var.vc_cluster
  vc_portgroup     = var.vc_portgroup
  vc_datastore     = var.vc_datastore
  vc_resource_pool = var.vc_resources

  wait_for_completion = true

  # IP Pool Information
  ip_starting_address = var.ip_start
  ip_pool_size        = var.ip_pool_size
  ip_netmask          = var.ip_netmask
  ip_gateway          = var.ip_gateway
  ntp_servers         = var.ntp_servers
  dns_servers         = var.dns_servers

  # Network Configuration Settings
  domain_name = "cisco.com"
  timezone    = "America/Los_Angeles"

  # Optional Proxy Configuration for Docker
  #proxy_http_protocol  = "http"
  #proxy_http_hostname  = "proxy.esl.cisco.com"
  #proxy_http_port      = 8080

  #proxy_https_protocol = "http"
  #proxy_https_hostname = "proxy.esl.cisco.com"
  #proxy_https_port     = 8080

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
