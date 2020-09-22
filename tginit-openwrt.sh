#!/bin/sh
# Copyright (c) 2020 TorGuard forum user 19807409
# Example single usage: 	tginit.sh "VPNUsername" "VPNPass" "tgwg" "0" "0" "41820" "1420" "AA" "25" "0" "1" "1" "us-la.secureconnect.me:1443" 
# Example serverlist usage:	tginit.sh "VPNUsername" "VPNPass" "tgwg" "0" "1" "41820" "1420" "AA" "25" "0" "0" "1" "us-la.secureconnect.me:1443 us-atl.secureconnect.me:1443" 
# 	In example about with serverlist:	route allowed ip's is disabled for each entry ass wekk as  enable manually
#						Do not create host routes to peers enabled, please uncheck before use.
#
# Download with curl:
# 	curl -o /usr/bin/tginit.sh https://raw.githubusercontent.com/TorGuard/openwrt-scripts/master/tginit-openwrt.sh && chmod +x /usr/bin/tginit.sh
# 	curl -o /usr/bin/tginstall.sh https://raw.githubusercontent.com/TorGuard/openwrt-scripts/master/tginstall-openwrt.sh && chmod +x /usr/bin/tginstall.sh
#
# Download with wget
# 	curl -o /usr/bin/tginit.sh https://raw.githubusercontent.com/TorGuard/openwrt-scripts/master/tginit-openwrt.sh && chmod +x /usr/bin/tginit.sh
# 	curl -o /usr/bin/tginstall.sh https://raw.githubusercontent.com/TorGuard/openwrt-scripts/master/tginstall-openwrt.sh && chmod +x /usr/bin/tginstall.sh
#
# Change your credentials and server:
#	TGSERVERLIST="123.123.123.123:1443 124.125.124.125:1443"
#	sed -i "s/YourVPNUsername/${TGUSER}/" /usr/bin/tginstall.sh
#	sed -i "s/YourVPNPassword/${TGPASS}/" /usr/bin/tginstall.sh
#	sed -i "s/TorguardServer1:1443 TorguardServer2:1443 TorguardServer3:1443/${TGSERVERLIST}/" /usr/bin/tginstall.sh
#
# Wireguarrd key generation
genwgkey () {
	PRIVATE=$(wg genkey)
	PUBLIC=$(echo "${PRIVATE}" | wg pubkey)
}

# Get TorGuard server connection info with wget
wgetinfo () {
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

# Get TorGuard server connection info with curl
curlinfo () {
	#$1 - VPN Username $2 - VPN Password $3 - Wireguard Endpoint $4 - Wireguard Port $5 - My wireguard public key
	URL="https://${1}:${2}@${3}:${4}/api/v1/setup?public-key=${5}"
	echo "API: https://$1:$2@$3:$4/api/v1/setup?public-key=${5}"
	TGINFO=$(curl -k ${URL})
}

# get connection information from torguard server and set variables
gettginfo () {
	if [ -f /usr/bin/curl ]; then
		echo "curl: OK - found: /usr/bin/curl"
		curlinfo "${1}" "${2}" "${3}" "${4}" "${5}"
	elif [ -f /usr/bin/wget ]; then
		echo "wget: OK - found: /usr/bin/wget"
		wgetinfo "${1}" "${2}" "${3}" "${4}" "${5}"
	else
		echo "ERROR: script requires curl or wget with ssl support
		Install curl with:

			opkg update
			opkg install curl

		or wget-ssl with:

			opkg update
			opkg install wget-ssl"
		exit
	fi
}

# Add wireguard interface
addwginterface () {
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

# initialize vars (**TODO** delete them after cleanup)
PRIVATE=""
PUBLIC=""
ENDPOINT=""
ENDPOINTPORT=""
TGINFO=""
DESCRIPTION=""

TMPPORT=$(( $LISTENPORT - 1 ))
TMPFWMARK=$(printf "%x\n" $(( $(printf "%d\n" 0x${FWMARK}) - 1 )))
TMPWGIFNR=$(( $WGIFNR - 1 ))

for i in ${TGSERVERLIST}; do
	# set vars
	TMPPORT=$(( $TMPPORT + 1 ))
	TMPFWMARK=$(printf "%x\n" $(( $(printf "%d\n" 0x${TMPFWMARK}) + 1 )))
	TMPWGIFNR=$(( $TMPWGIFNR + 1 ))
	DESCRIPTION="${WGINTERFACE}${WGIFNR} (TorGuard)"
	ZONEINTERFACES=$(uci get firewall.@zone[${FIREWALLZONE}].network)
	ENDPOINT=$(echo $i | awk -F'[:]' '{print $1}')
	ENDPOINTPORT=$(echo $i | awk -F'[:]' '{print $2}')

	# create new private and public keys
	genwgkey

	# show private and public keys in console during the runtime
	echo "Private: ${PRIVATE}"
	echo "Public:  ${PUBLIC}"


	gettginfo "${VPNUSERNAME}" "${VPNPASS}" "${ENDPOINT}" "${ENDPOINTPORT}" "${PUBLIC}"
	WGPUBLIC=$(echo ${TGINFO} | awk -F'[,]' '{print $1}' | awk -F'[:]' '{print $2}' | sed 's/"//g') && echo "Public key: ${WGPUBLIC}"
	SERVERIP=$(echo ${TGINFO} | awk -F'[,]' '{print $2}' | awk -F'[:]' '{print $2}' | sed 's/"//g') && echo "Peer server: ${SERVERIP}"
	CLIENTIP=$(echo ${TGINFO} | awk -F'[,]' '{print $3}' | awk -F'[:]' '{print $2}' | sed 's/"//g') && echo "IP Addresses: ${CLIENTIP}"
	ALLOWEDIPS=$(echo ${TGINFO} | awk -F'[,]' '{print $4}' | awk -F'[:]' '{print $2}' | sed 's/"//g') && echo "Allowd IPs: ${ALLOWEDIPS}"
	WGDNS1=$(echo ${TGINFO} | awk -F'[,]' '{print $5}' | awk -F'[:]' '{print $2}' | sed 's/"//g' | sed 's/\[//g') && echo "DNS1: ${WGDNS1}"
	WGDNS2=$(echo ${TGINFO} | awk -F'[,]' '{print $6}' | awk -F'[:]' '{print $1}' | sed 's/"//g' | sed 's/\]//g') && echo "DNS2: ${WGDNS2}"
	WGSERVER=$(echo ${TGINFO} | awk -F'[,]' '{print $7}' | awk -F'[:]' '{print $2}' | sed 's/"//g') && echo "Endpoint host: ${WGSERVER}"
	WGPORT=$(echo ${TGINFO} | awk -F'[,]' '{print $8}' | awk -F'[:]' '{print $2}' | sed 's/"//g' | sed 's/}//g') && echo "Endpoint Port: ${WGPORT}"
	
	# create new wireguard interface with torguards server
	addwginterface "${WGINTERFACE}${WGIFNR}" "${PRIVATE}" "${TMPPORT}" "${CLIENTIP}" "${MTU}" "${TMPFWMARK}" "${USEBUILTINIPV6}" "${NOHOSTROUTE}" "${DESCRIPTION}" "${WGPUBLIC}" "${ALLOWEDIPS}" "${WGSERVER}" "${WGPORT}" "${KEEPALIVE}" "${ROUTEALLOWEDIPS}" "${FIREWALLZONE}" "${ZONEINTERFACES}"
done

/etc/init.d/firewall restart
/etc/init.d/network restart

echo "Torguard wireguard initialization finished, please reboot to complete"