#!/bin/sh
# Copyright (c) 2020 TorGuard forum user 19807409
# requirement: opkg install iperf3 (apt install iperf3)
# iperf.wifx.net 5200 bis 5209, additional ports 1080, 8080, 3128, 1197, 1198, more info on https://speedtest.wtnet.de/
# iperf servers:    https://iperf.cc/
#                   https://iperf.fr/iperf-servers.php

iperftcpdefault () {
    for url in $1; do
        for port in $2; do
            echo "SERVER: ${url}"
            IPERFLOG=/tmp/log/speedtest/iperf3.${url}-tcp-${port}
            iperf3 -c ${url} -p ${port} ${3} -R | tee ${IPERFLOG}-reverse.txt && cat ${IPERFLOG}-reverse.txt
            iperf3 -c ${url} -p ${port} ${3}    | tee ${IPERFLOG}.txt && cat ${IPERFLOG}.txt
        done
    done
}

IPERFSERVERLOCAL="192.168.0.37"
IPERFSERVERS5200="iperf.wifx.net speedtest.wtnet.de ping-ams1.online.net bouygues.testdebit.info ping.online.net speedtest.hostkey.ru" # iperf.worldstream.nl
IPERFSERVERS5201="iperf.wifx.net speedtest.wtnet.de ping-ams1.online.net bouygues.testdebit.info ping.online.net iperf.volia.net speedtest.hostkey.ru iperf.scottlinux.com speedtest.iveloz.net.br iperf.biznetnetworks.com" # iperf.worldstream.nl
IPERFSERVERS5002="speedtest.serverius.net"
IPERFTCPDEFAULT="-P 10 -4 -b 1000M $1"
IPERFWWWDIR=iperf3
VERSION=$(date +%Y%m%d)-$(date +%s)

rm -fR /tmp/log/speedtest
mkdir -p /tmp/log/speedtest
mkdir -p /www/$IPERFWWWDIR
chmod 644 -R /www/$IPERFWWWDIR/*

iperftcpdefault "$IPERFSERVERLOCAL" "5201" "$IPERFTCPDEFAULT"
iperftcpdefault "$IPERFSERVERS5200" "5200" "$IPERFTCPDEFAULT"
iperftcpdefault "$IPERFSERVERS5201" "5201" "$IPERFTCPDEFAULT"
iperftcpdefault "$IPERFSERVERS5202" "5202" "$IPERFTCPDEFAULT"

echo "FINISHED ALL SERVERS"
echo "Log files:"
cd /tmp/log/speedtest
find . -maxdepth 1 -type f -size -1k -exec rm -rf {} \;
tar -cvz -f iperf3-${VERSION}.tar.gz iperf3.*
rm -f ./iperf3.*.txt
mv iperf3-*.tar.gz /www/$IPERFWWWDIR/

cd /www/$IPERFWWWDIR
sha256sum * > /www/$IPERFWWWDIR/sha256sum

DOWNLOADHTTP="http://$(uci get network.lan.ipaddr)/$IPERFWWWDIR/iperf3-${VERSION}.tar.gz"
DOWNLOADHTTPS="https://$(uci get network.lan.ipaddr)/$IPERFWWWDIR/iperf3-${VERSION}.tar.gz"
echo "Download result over HTTP"
echo "  url: $DOWNLOADHTTP"
echo "  curl -o ~/Downloads/iperf3-${VERSION}.tar.gz $DOWNLOADHTTP"
echo "  wget -O ~/Downloads/iperf3-${VERSION}.tar.gz $DOWNLOADHTTP"
echo " "
echo "Download result over HTTP: $DOWNLOADHTTPS"
echo "  url: $DOWNLOADHTTPS"
echo "  curl -o ~/Downloads/iperf3-${VERSION}.tar.gz $DOWNLOADHTTPS"
echo "  wget -O ~/Downloads/iperf3-${VERSION}.tar.gz $DOWNLOADHTTPS"
