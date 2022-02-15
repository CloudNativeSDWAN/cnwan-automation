/* The helm provider has a kubernetes block for cluster connection */
provider "helm" {
    kubernetes {
        config_path = pathexpand(var.kube_config)
    }
}

/* The kubernetes provider is needed to manage the namespace */
provider "kubernetes" {
    config_path = pathexpand(var.kube_config)
}
