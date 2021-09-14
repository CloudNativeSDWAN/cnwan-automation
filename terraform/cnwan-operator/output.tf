output "cnwan_operator_metadata" {
    value = helm_release.cnwan_operator.metadata
    description = "CN-WAN Operator Helm release metadata"
}
