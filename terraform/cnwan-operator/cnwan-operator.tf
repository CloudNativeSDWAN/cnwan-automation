module "etcd_service_registry" {
    source = "../etcd-service-registry"
    kube_config = var.kube_config
    namespace = var.etcd_namespace
    helm_release_name = var.etcd_helm_release_name
    etcd_root_password = var.etcd_root_password
}
resource "helm_release" "cnwan_operator" {
    depends_on = [kubernetes_namespace.this, module.etcd_service_registry.etcd_metadata]
    chart = "cnwan-operator"
    name = var.helm_release_name
    namespace = var.namespace
    repository = "https://CloudNativeSDWAN.github.io/cnwan-helm-charts"

    values = [<<EOF
operator:
    namespaceListPolicy: allowlist
    serviceAnnotations:
        - traffic-profile
    serviceRegistry: etcd
    etcd:
        install: false
        username: root
        password: "${var.etcd_root_password}"
        endpoints:
            - "${var.etcd_namespace}.${var.etcd_helm_release_name}.svc.cluster.local:2379"
EOF
    ]
}
