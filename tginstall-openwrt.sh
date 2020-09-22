#!/bin/sh
# Copyright (c) 2020 TorGuard forum user 19807409

# TorGuard credentials
VPNUSERNAME="YourVPNUsername"	# Your torguard vpn username (same as in torguard client)
VPNPASS="YourVPNPassword"	# Your torguard vpn passsword (same as in torguard client)

# Torguard server list, add separated by space [host]:[port]
TGSERVERLIST="TorguardServer1:1443 TorguardServer2:1443 TorguardServer3:1443"

WGINTERFACE="wg"		# Wireguard interface name, default: tgwg
WGIFNR="0"			# Wireguard interface number, default 0
NOHOSTROUTE="0"			# Optional. Do not create host routes to peers, default 0
LISTENPORT="51820"		# Optional. UDP port used for outgoing and incoming packets.
MTU="1420"			# Optional. Maximum Transmission Unit of tunnel interface.
FWMARK="AA"			# Optional. 32-bit mark for outgoing encrypted packets. Enter value in hex, starting with 0x.
KEEPALIVE="25"			# Optional. Seconds between keep alive messages. Default is 0 (disabled). Recommended value if this device is behind a NAT is 25.
USEBUILTINIPV6="0"		# Use builtin IPv6-management	0 to disable, 1 to enable
ROUTEALLOWEDIPS="1"		# Route allowed IPs, 0 to disable, 1 to enable
FIREWALLZONE="1"		# Assign firewall-zone, 1 is wan, 0 is lan, default: 1

# INSTALL TORGUARD, PLEASE CHECK INTERFACES AFTER SCRIPT FINISHES AND REBOOT
tginit.sh "${VPNUSERNAME}" "${VPNPASS}" "${WGINTERFACE}" "${WGIFNR}" "${NOHOSTROUTE}" "${LISTENPORT}" "${MTU}" "${FWMARK}" "${KEEPALIVE}" "${USEBUILTINIPV6}" "${ROUTEALLOWEDIPS}" "${FIREWALLZONE}" "${TGSERVERLIST}"
