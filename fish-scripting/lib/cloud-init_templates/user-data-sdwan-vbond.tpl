
vpn 0
 interface ge0/0
  description "Control Plane Network"
  ip dhcp-client
  ipv6 dhcp-client
  no shutdown
  no tunnel-interface
  !
 !
 ip route 0.0.0.0/0 $VM_GATEWAY_CTRL
!

vpn 512
 interface eth0
  description "Management Network"
  ip dhcp-client
  ipv6 dhcp-client
  no shutdown
 !
 ip route 0.0.0.0/0 $VM_GATEWAY_MGMT
!
