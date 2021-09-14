variable "kube_config" {
    type = string
    default = "~/.kube/config"
}

variable "etcd_namespace" {
    type = string
    default = "etcd-service-registry"
}

variable "etcd_helm_release_name" {
    type = string
    default = "etcd-service-registry"
}

variable "etcd_root_password" {
    type = string
}

variable "namespace" {
    type = string
    default = "cnwan-operator-system"
}

variable "helm_release_name" {
    type = string
    default = "cnwan-operator"
}
