imports:
- path: network-template.jinja
- path: vmanage.jinja
- path: vbond.jinja
- path: vsmart.jinja
- path: sdwan-control-plane.jinja

resources:
- name: $SDWAN_NAMING_PREFIX-sdwan-control-plane
  type: sdwan-control-plane.jinja
  properties:
    zone: $GCP_ZONE
    region: $GCP_REGION
    namingPrefix: $SDWAN_NAMING_PREFIX
    mgmtNetwork: $SDWAN_MGMT_NET
    ctrlNetwork: $SDWAN_CTRL_NET
    siteId: $SDWAN_CTRL_SITE_ID
    label: $GCP_LABEL

outputs:
- name: vManage UI
  value: https://$(ref.$SDWAN_NAMING_PREFIX-sdwan-vmanage.networkInterfaces[0].accessConfigs[0].natIP):8443/
