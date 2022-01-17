output "cluster_moid" {
  value = module.terraform-intersight-iks.k8s_cluster_moid
}

output "kube_config" {
  value = base64decode(data.intersight_kubernetes_cluster.iks-cluster.results[0].kube_config)
}
