resource "helm_release" "etcd_service_registry" {
    chart = "etcd"
    name = var.helm_relese_name
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
