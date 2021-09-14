# Deploy the CN-WAN operator backed by an etcd service registry using Terraform

Variables can be adjusted in [variables.tf](./variables.tf) or can be overridden on the command line. The `etcd_root_password` doesn't have a default value, so you will need to specify it either at deploy time, or on the command line. A relatively secure way to store it in an environment variable to be reused on the command line, without being stored in the command history or shown on the display is to use `read`:

```sh
read -s ETCD_ROOT_PWD
```

After that:

```sh
terraform init
terraform apply -var etcd_root_password=$ETCD_ROOT_PWD
```

Alternatively, if storing plain text passwords on disk is acceptable, variables can be specified in a `terraform.tfvars` file which will be ignored by Git.
