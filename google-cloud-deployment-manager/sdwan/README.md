# Quickstart

The collection of scripts in this directory will help set up an SD-WAN control plane and a single vEdge onboarded. With some modifications to the vEdge onboarding part, a second one can be onboarded in a way desired by the user. The latest tested SD-WAN version is 20.3.3.

Steps:

- Make sure [dependencies](../../fish-scripting/README.md#dependencies) are installed
- Customize [sdwan-variables.yaml.example](./sdwan-variables.yaml.example) to your needs and remove the `.example` extension from the file name
- Generate base images: `./create-sdwan-base-images.fish`
- Generate the Deployment Manager files based on your variables using the templates: `./generate_deployment_yamls.fish`

## Control plane

- Create the GCP deployment: `./deployment-create.fish`
- Configure the SD-WAN control plane VMs: `./initial_config.fish`

If these two steps complete successfully, it should be possible to log into vManage with user `admin` and the password set in `sdwan-variables.yaml`. The dashboard should show one of each control plane components is detected and up.

## Data plane

This only creates one vEdge, a second one should be created manually (for now).

- Create the GCP deployment: `./deployment-create-vedge.fish`
- Configure the the first SD-WAN data plane VM (vEdge): `./initial_config-vedge.fish 0`

If these two steps complete successfully, the vManage dashboard should show an active WAN Edge device, one "Control Up" connection (green), and one site with "No WAN Connectivity" (red). Logging into the vEdge and executing `show control connections` should show connections to each control plane element being up.
