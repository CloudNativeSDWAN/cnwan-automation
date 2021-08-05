variable "kube_config" {
    type = string
    default = "~/.kube/config"
}

variable "namespace" {
    type = string
    default = "etcd-service-registry"
}

variable "helm_relese_name" {
    type = string
    default = "etcd-service-registry"
}

variable "etcd_root_password" {
    type = string
}
