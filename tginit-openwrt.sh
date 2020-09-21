#!/bin/sh
# Example single usage: tginit.sh "VPNUsername" "VPNPass" "tgwg" "0" "0" "41820" "1420" "AA" "25" "0" "1" "1" "us-la.secureconnect.me:1443 us-la.secureconnect.me:1443 us-atl.secureconnect.me:1443" 
# Example multi usage: tginit.sh "VPNUsername" "VPNPass" "tgwg" "0" "1" "41820" "1420" "AA" "25" "0" "0" "1" "us-la.secureconnect.me:1443" 
# 	Info on multi usage example above: route allowed ip's is disabled for each entry, enable manually

genwgkey () {
	PRIVATE=$(wg genkey)
	PUBLIC=$(echo "${PRIVATE}" | wg pubkey)
}

wgettginfo () {
	#$1 - VPN Username
	#$2 - VPN Password
	#$3 - Wireguard Endpoint
	#$4 - Wireguard Port
	#$5 - My wireguard public key
	#wget -O $6 --no-check-certificate https://$1:$2@$3:$4/api/v1/setup?public-key=$5
	URL="https://${1}:${2}@${3}:${4}/api/v1/setup?public-key=${5}"
	echo "API: ${URL}"
	TGINFO=$(wget --no-check-certificate -qO- ${URL})
}

cgettginfo () {
	#$1 - VPN Username
	#$2 - VPN Password
	#$3 - Wireguard Endpoint
	#$4 - Wireguard Port
	#$5 - My wireguard public key
	#wget -O $6 --no-check-certificate https://$1:$2@$3:$4/api/v1/setup?public-key=$5
	URL="https://${1}:${2}@${3}:${4}/api/v1/setup?public-key=${5}"
	echo "API: https://$1:$2@$3:$4/api/v1/setup?public-key=$5"
	TGINFO=$(curl -k ${URL})
}

addwginterface () {
	# $1 - network internaface, Example: wg0
	# $2 - private_key
	# $3 - listen_port
	# $4 - addresses

	# $5 - mtu
	# $6 - fwmark
	# add wireguard interface
	uci delete network.${1}
	uci commit network

	
	uci add network interface
	uci rename network.@interface[-1]=${1}
	uci set network.@interface[-1].proto='wireguard'
	uci set network.@interface[-1].private_key="${2}"
	uci set network.@interface[-1].listen_port="${3}"
	uci add_list network.@interface[-1].addresses="${4}"
	uci set network.@interface[-1].mtu="${5}"
	uci set network.@interface[-1].fwmark="0x${6}"
	# disable use of builtin IPv6-management
	uci set network.@interface[-1].delegate="${7}"
	# disabled by default, 0
	uci set network.@interface[-1].nohostroute="${8}"

	# add peers
	uci add network wireguard_${1}
	uci set network.@wireguard_${1}[-1].description="${9}"
	uci set network.@wireguard_${1}[-1].public_key="${10}"
	uci add_list network.@wireguard_${1}[-1].allowed_ips="${11}"
	uci set network.@wireguard_${1}[-1].endpoint_host="${12}"
	uci set network.@wireguard_${1}[-1].endpoint_port="${13}"
	uci set network.@wireguard_${1}[-1].persistent_keepalive="${14}"
	uci set network.@wireguard_${1}[-1].route_allowed_ips="${15}"
	uci commit network

	# Add created wireguard interface to lan zone (this will overwrite any other firewall.@zone[0].network setting, please recheck if using non default settings)
	uci set firewall.@zone[${16}].network="${17} ${1}"
	uci commit firewall
}

# Each server in a string must be provided by server and port "server:port" and separated by space "srv1:1234 srv2:5678"
TGSERVERLIST="${13}" # TorGuard Server List separated by space, "srv1:1234 srv2:5678"
# TorGuard credentials
VPNUSERNAME="${1}"		# TorGuard VPN username
VPNPASS="${2}"			# TorGuard VPN password
WGINTERFACE="${3}"		# Wireguard interface name, default: tgwg
WGIFNR="${4}"			# Wireguard interface number, default 0
NOHOSTROUTE="${5}"		# Optional. Do not create host routes to peers, default 0
LISTENPORT="${6}"		# Optional. UDP port used for outgoing and incoming packets.
MTU="${7}"			# Optional. Maximum Transmission Unit of tunnel interface.
FWMARK="${8}"			# Optional. 32-bit mark for outgoing encrypted packets. Enter value in hex, starting with 0x.
KEEPALIVE="${9}"		# Optional. Seconds between keep alive messages. Default is 0 (disabled). Recommended value if this device is behind a NAT is 25.
USEBUILTINIPV6="${10}"		# Use builtin IPv6-management	0 to disable, 1 to enable
ROUTEALLOWEDIPS="${11}"	# Route allowed IPs, 0 to disable, 1 to enable
FIREWALLZONE="${12}"		# Assign firewall-zone, 1 is wan, 0 is lan, default: 1

echo "
TorGuard VPN username:			${1}
TorGuard VPN password:			${2}
Wireguard interface name:		${3}
Wireguard interface number:		${4}
do not create host routes to peers:	${5}
UDP port for out-/incoming packets:	${6}
Maximum Transmission Unit of tunnel:	${7}
32-bit mark for outgoing packets:	${8}
Seconds between keep alive messages:	${9}
Use builtin IPv6-management:		${10}
Route allowed IPs:			${11}
TorGuard Server List:			${12}
"

# initialize vars
PRIVATE=""
PUBLIC=""
ENDPOINT=""
ENDPOINTPORT=""
TGINFO=""
DESCRIPTION=""

TMPPORT=$(( $LISTENPORT - 1 ))
TMPFWMARK=$(printf "%x\n" $(( $(printf "%d\n" 0x${FWMARK}) - 1 )))
for i in ${TGSERVERLIST}; do
	TMPPORT=$(( $TMPPORT + 1 ))
	TMPFWMARK=$(printf "%x\n" $(( $(printf "%d\n" 0x${TMPFWMARK}) + 1 )))
	DESCRIPTION="${WGINTERFACE}${WGIFNR} (TorGuard)"
	ZONEINTERFACES=$(uci get firewall.@zone[${FIREWALLZONE}].network)

	ENDPOINT=$(echo $i | awk -F'[:]' '{print $1}')
	ENDPOINTPORT=$(echo $i | awk -F'[:]' '{print $2}')
	genwgkey
	wgettginfo "${VPNUSERNAME}" "${VPNPASS}" "${ENDPOINT}" "${ENDPOINTPORT}" "${PUBLIC}"

	echo "Private: ${PRIVATE}"
	echo "Public:  ${PUBLIC}"
	WGPUBLIC=$(echo ${TGINFO} | awk -F'[,]' '{print $1}' | awk -F'[:]' '{print $2}' | sed 's/"//g') && echo "Public key: ${WGPUBLIC}"
	SERVERIP=$(echo ${TGINFO} | awk -F'[,]' '{print $2}' | awk -F'[:]' '{print $2}' | sed 's/"//g') && echo "Peer server: ${SERVERIP}"
	CLIENTIP=$(echo ${TGINFO} | awk -F'[,]' '{print $3}' | awk -F'[:]' '{print $2}' | sed 's/"//g') && echo "IP Addresses: ${CLIENTIP}"
	ALLOWEDIPS=$(echo ${TGINFO} | awk -F'[,]' '{print $4}' | awk -F'[:]' '{print $2}' | sed 's/"//g') && echo "Allowd IPs: ${ALLOWEDIPS}"
	WGDNS1=$(echo ${TGINFO} | awk -F'[,]' '{print $5}' | awk -F'[:]' '{print $2}' | sed 's/"//g' | sed 's/\[//g') && echo "DNS1: ${WGDNS1}"
	WGDNS2=$(echo ${TGINFO} | awk -F'[,]' '{print $6}' | awk -F'[:]' '{print $1}' | sed 's/"//g' | sed 's/\]//g') && echo "DNS2: ${WGDNS2}"
	WGSERVER=$(echo ${TGINFO} | awk -F'[,]' '{print $7}' | awk -F'[:]' '{print $2}' | sed 's/"//g') && echo "Endpoint host: ${WGSERVER}"
	WGPORT=$(echo ${TGINFO} | awk -F'[,]' '{print $8}' | awk -F'[:]' '{print $2}' | sed 's/"//g' | sed 's/}//g') && echo "Endpoint Port: ${WGPORT}"

	addwginterface "${WGINTERFACE}${WGIFNR}" "${PRIVATE}" "${TMPPORT}" "${CLIENTIP}" "${MTU}" "${TMPFWMARK}" "${USEBUILTINIPV6}" "${NOHOSTROUTE}" "${DESCRIPTION}" "${WGPUBLIC}" "${ALLOWEDIPS}" "${WGSERVER}" "${WGPORT}" "${KEEPALIVE}" "${ROUTEALLOWEDIPS}" "${FIREWALLZONE}" "${ZONEINTERFACES}"
	WGIFNR=$(( $WGIFNR + 1 ))
done

/etc/init.d/firewall restart
/etc/init.d/network restart

echo "Torguard wireguard initialization finished, please reboot to complete"
