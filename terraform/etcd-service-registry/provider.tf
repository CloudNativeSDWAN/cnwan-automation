/* This provider file assumes that the ../iks folder was used to create the
   Kubernetes cluster with Terraform. Rename and use the `provider.tf.simple`
   file instead, if you have a specific kube_config file you want to use
 */
data "terraform_remote_state" "iks" {
    backend = "local"

    config = {
        path = "../iks/terraform.tfstate"
    }
}

resource "local_file" "kube_config" {
  content         = data.terraform_remote_state.iks.outputs.kube_config
  filename        = "/tmp/kube_config"
  file_permission = "0600"
}

/* The helm provider has a kubernetes block for cluster connection */
provider "helm" {
    kubernetes {
        host                   = yamldecode(data.terraform_remote_state.iks.outputs.kube_config).clusters[0].cluster.server
        cluster_ca_certificate = base64decode(yamldecode(data.terraform_remote_state.iks.outputs.kube_config).clusters[0].cluster.certificate-authority-data)
        client_certificate     = base64decode(yamldecode(data.terraform_remote_state.iks.outputs.kube_config).users[0].user.client-certificate-data)
        client_key             = base64decode(yamldecode(data.terraform_remote_state.iks.outputs.kube_config).users[0].user.client-key-data)
    }
}

/* The kubernetes provider is needed to manage the namespace */
provider "kubernetes" {
    host                   = yamldecode(data.terraform_remote_state.iks.outputs.kube_config).clusters[0].cluster.server
    cluster_ca_certificate = base64decode(yamldecode(data.terraform_remote_state.iks.outputs.kube_config).clusters[0].cluster.certificate-authority-data)
    client_certificate     = base64decode(yamldecode(data.terraform_remote_state.iks.outputs.kube_config).users[0].user.client-certificate-data)
    client_key             = base64decode(yamldecode(data.terraform_remote_state.iks.outputs.kube_config).users[0].user.client-key-data)
}
