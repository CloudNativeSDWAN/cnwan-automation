#cloud-boothook

system
 idle-timeout 0
 host-name $VM_NAME
 location SJC24
 gps-location latitude $SDWAN_GEO_LAT
 gps-location longitude $SDWAN_GEO_LON
 system-ip $SDWAN_SYSTEM_IP
 site-id $SDWAN_SITE_ID
 admin-tech-on-failure
 sp-organization-name "$SDWAN_ORG"
 organization-name "$SDWAN_ORG"
 clock timezone America/Los_Angeles
 vbond $SDWAN_VBOND_IP
 aaa
  user admin
   password $SDWAN_PASSWORD
   $SDWAN_PUBKEY
  !
 !
 ntp
  server $NTP_SERVER
   version 4
  exit
 !
!
