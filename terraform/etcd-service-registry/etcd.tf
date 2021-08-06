resource "helm_release" "etcd_service_registry" {
    depends_on = [kubernetes_namespace.this]
    chart = "etcd"
    name = var.helm_release_name
    namespace = var.namespace
    repository = "https://charts.bitnami.com/bitnami"

    values = [<<EOF
auth:
    rbac:
        enabled: true
        rootPassword: ${var.etcd_root_password}
    service:
        type: LoadBalancer
EOF
    ]
}

resource "kubernetes_pod" "etcd_client" {
    metadata {
        name = "etcd-client"
        namespace = var.namespace
    }

    spec {
        container {
            image = "docker.io/bitnami/etcd"
            name = "etcd-client"
            command = ["sleep", "infinity"]

            env {
                name = "ROOT_PASSWORD"
                value = var.etcd_root_password
            }

            env {
                name = "ETCDCTL_ENDPOINTS"
                value = "${var.namespace}.${var.helm_release_name}.svc.cluster.local:2379"
            }
        }

        restart_policy = "Never"
    }
}
