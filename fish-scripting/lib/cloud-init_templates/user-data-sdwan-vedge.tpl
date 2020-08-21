
vpn 0
 interface ge0/0
  description "Public Internet"
  ip dhcp-client
  ipv6 dhcp-client
  no shutdown
  tunnel-interface
   encapsulation ipsec
   color public-internet
   allow-service sshd
  !
 interface ge0/1
  description "Business Internet"
  ip dhcp-client
  ipv6 dhcp-client
  no shutdown
  tunnel-interface
   encapsulation ipsec
   color biz-internet restrict
   allow-service sshd
  !
 !
 ip route 0.0.0.0/0 $VM_GATEWAY_PUB
 ip route 0.0.0.0/0 $VM_GATEWAY_BIZ
!

vpn 1
 interface ge0/2
  description "Service Network"
  ip address $IP_PREFLEN_SERVICE
  no shutdown
 !
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
