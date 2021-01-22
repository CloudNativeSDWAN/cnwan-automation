# Fish Scripts for Cloud Networking Automation

This is a library written using the [Fish Shell](https://fishshell.com/) to
automate deploying cloud native SD-WAN setups in private and public clouds.
Configuration is based on environment variables (which take precedence) and a
YAML file.

## Using the code

The best way to use this project is to include it as a Git module in your
project, and take advantage of the functions exposed in the [lib/](./lib)
directory. The [sdwan_deploy.fish](./sdwan_deploy.fish) script is provided as
an example, it takes advantage of those functions to deploy a Cisco SD-WAN,
based on configuration in the [cnwan.yaml.example](./cnwan.yaml.example) file.
It is still a work in progress, some manual steps are still required, but it
automates a big part of deployment.

**Please note that deploying a Cisco SD-WAN requires access to the SD-WAN VM
disk images (vManage, vSmart and vEdge, which is also used for vBond) in QCOW2
or OVA format. The folder containing the images is configurable.**

To use the example script, first install dependencies (listed below) and
customize the configuration file. At a minimum replace the `<GCP_PROJECT>`,
`<GCP_ZONE>` and `<GCP_ZONE_SERVICE>` placeholders with the values appropriate
for your setup, and point to the directory with the SD-WAN images. Then run
the script, with the path to your configuration file as the first argument:

    ./sdwan_deploy.fish your-cnwan-config.yaml

*The code is developed and tested on macOS with Homebrew. The intent is to use
tools available on both macOS and Linux, so if something doesn't work on
Linux, please let us know.*

### Dependencies

- The Fish Shell, version 2.3.0 or higher.
- The [`yq` command-line YAML processor](https://mikefarah.gitbook.io/yq/)
  is used to parse configuration, version 4+
- `base64` to encode files into *cloud-init* configurations (on macOS use the
  built-in version not the Homebrew *base64* package, as default behavior for
  line wrap and CLI options differ)
- `mkisofs` from the *cdrtools* package is used to generate the CD-ROM images
  attached to VMs for *cloud-init* on private clouds
- `envsubst` from the *gettext* package is used to fill values into template
  files
- `expect` for interaction over SSH sessions
- `openssl` for generating SD-WAN certificates
- `gcloud` and `gsutil` for Google Cloud Platform automation from their [cloud
  SDK](https://cloud.google.com/sdk/install)
- `gtar` from the *gnu-tar* package (on macOS) for creating Google Cloud disk
  images
- `govc` for VMware ESXi automation

On macOS with Homebrew install all in one go (except for `gcloud`/`gsutil`
which needs manual installation):

    brew install fish yq cdrtools gettext expect openssl gnu-tar govc

## Selective useful resources used to develop the scripts

- [Scripting `gcloud` CLI commands](https://cloud.google.com/sdk/docs/scripting-gcloud)
