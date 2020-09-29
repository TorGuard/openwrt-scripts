# openwrt-scripts

TorGuard related OpenWRT scripts
- [openwrt-scripts](#openwrt-scripts)
  - [TorGuard Wireguard Installation](#torguard-wireguard-installation)
    - [download and install with wget](#download-and-install-with-wget)
    - [download install with curl](#download-install-with-curl)
  - [Script descriptions](#script-descriptions)
    - [tginstall](#tginstall)
    - [tginit](#tginit)
    - [torguard's wireguard api v1](#torguards-wireguard-api-v1)
      - [Example for New York shared server](#example-for-new-york-shared-server)
  - [speedperf](#speedperf)
    - [Install speed perf](#install-speed-perf)

## TorGuard Wireguard Installation

Installation can be performed by running [tginstall](usr/bin/tginstall):

### download and install with wget

```shell
wget -O /usr/bin/tginstall https://github.com/TorGuard/openwrt-scripts/raw/master/usr/bin/tginstall
chmod +x /usr/bin/tginstall && tginstall
```

### download install with curl

```shell
curl -o /usr/bin/tginstall https://github.com/TorGuard/openwrt-scripts/raw/master/usr/bin/tginstall
chmod +x /usr/bin/tginstall && tginstall
```

## Script descriptions

### tginstall

helper script for tginit. You can pass only 2 variables:

- (1) openwrt interface name, default is wg and will be used if no vars are passed
- (2) interface number, default is 0. Currently, _please make sure that there is no interface of same name before usage_

all other values are retrieved from [/etc/torguard](etc/config/torguard).

### tginit

Torguard initialization script. Script generates new keypair and retrieves wireguard interface options from TorGuard server to which a user connects to with your torguard credentials, then it creates wireguard interface. After script finishes, please recheck your new interface if all values are there and if everything is ok, reboot your device.

### torguard's wireguard api v1

You can use the API manually, retrieve required values with a browser.

- Usage:

    `https://[USER]:[PASS]@[SERVER]:[PORT]/api/v1/setup?public-key=[YOURPUBLICKEY]`

#### Example for New York shared server

- Example: Open if your browser:

    `https://User1:Pass1@173.244.200.119:1443/api/v1/setup?public-key=AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJLLL=`

## speedperf

Speedperf is a script performing iperf3 test with defined servers.  [Current public script](usr/bin/speedperf) uses only default client.

### Install speed perf

```shell
# Get speedperf bin
wget -O /etc/config/speedperf https://github.com/TorGuard/openwrt-scripts/raw/master/etc/config/speedperf

# Get speedperf config
wget -O /usr/bin/speedperf https://github.com/TorGuard/openwrt-scripts/raw/master/usr/bin/speedperf

# set speeperf bin as executable
chmod +x /usr/bin/speedperf
```
