imports:
- path: network-template.jinja
- path: vedge.jinja
- path: sdwan-data-plane.jinja

resources:
- name: $SDWAN_NAMING_PREFIX-sdwan-data-plane
  type: sdwan-data-plane.jinja
  properties:
    zone: $GCP_ZONE
    region: $GCP_REGION
    namingPrefix: $SDWAN_NAMING_PREFIX
    svcNetwork: $SERVICE_NETWORK
    svcNetworkIP: $SERVICE_NETWORK_IP
    pubiNetwork: $SDWAN_PUBI_NET
    biziNetwork: $SDWAN_BIZI_NET
    siteId: $SDWAN_SITE_ID
    label: $GCP_LABEL

outputs:
- name: GCP vEdge 1 External IP
  value: $(ref.$SDWAN_NAMING_PREFIX-sdwan-vedge-1.networkInterfaces[0].accessConfigs[0].natIP)
