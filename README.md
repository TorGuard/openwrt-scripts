# TorGuard related OpenWRT scripts
![OpenWRT Logo](https://raw.githubusercontent.com/openwrt/openwrt/master/logo.svg)

- [TorGuard related OpenWRT scripts](#torguard-related-openwrt-scripts)
  - [TorGuard Wireguard Installation](#torguard-wireguard-installation)
    - [download and install with wget](#download-and-install-with-wget)
    - [download and install with curl](#download-and-install-with-curl)
  - [Script descriptions](#script-descriptions)
    - [tginstall](#tginstall)
    - [tginit](#tginit)
    - [torguard's wireguard api v1](#torguards-wireguard-api-v1)
      - [API Expiration](#api-expiration)
      - [Validation loop script](#validation-loop-script)
      - [tgapi service](#tgapi-service)
      - [Example for New York shared server](#example-for-new-york-shared-server)
        - [Convert your public key to API format](#convert-your-public-key-to-api-format)
        - [Example API URL](#example-api-url)
  - [speedperf](#speedperf)
    - [Install speed perf](#install-speed-perf)
  - [FAQ (Freqently Asked Question)](#faq-freqently-asked-question)

## TorGuard Wireguard Installation

Installation can be performed by running [tginstall](usr/bin/tginstall):

### download and install with wget

```shell
wget -O /usr/bin/tginstall https://raw.githubusercontent.com/TorGuard/openwrt-scripts/master/usr/bin/tginstall
chmod +x /usr/bin/tginstall && tginstall
```

### download and install with curl

```shell
curl -o /usr/bin/tginstall https://raw.githubusercontent.com/TorGuard/openwrt-scripts/master/usr/bin/tginstall
chmod +x /usr/bin/tginstall && tginstall
```

## Script descriptions

### tginstall

- default path: `/usr/bin/tginstall`

helper script for tginit. You can pass only 2 variables:

- (1) openwrt interface name, default is wg and will be used if no vars are passed
- (2) interface number, default is 0. Currently, _please make sure that there is no interface of same name before usage_

all other values are retrieved from [/etc/config/torguard](etc/config/torguard).

### tginit

- default path: `/usr/bin/tginit`

Torguard initialization script. Script generates new keypair and retrieves wireguard interface options from TorGuard server to which a user connects to with your torguard credentials, then it creates wireguard interface. After script finishes, please recheck your new interface if all values are there and if everything is ok, reboot your device.

### torguard's wireguard api v1

Currently only whitelisted/whitelabeled keys work and to get one can be performed in several ways

- dumping the keys/config with TorGuard client on any pc
  
    ```shell
    # show full config of TorGuard client
    wg showconf torguard-wg
    ```

- check your TorGuard clients debug log
- using TorGuard's wireguard configuration tool

You can use the API manually, retrieve required values with a browser.

Public key for API usage has to be converted first into appropriate format by replacing suffix `=` with `%3D`

- Usage:

    `https://[USER]:[PASS]@[SERVER]:[PORT]/api/v1/setup?public-key=[YOURPUBLICKEY]`

#### API Expiration

Currently every connection will work for 15 minutes, no disconnect will happen, but after 15 minutes your client will lose ability to connect to the internet. To prevent this, one could either run a cronjob or start a service tgapi which runs by default every 5 minutes ensuring that the config is extended for 15 minutes from the timestamp API call is executed.

- _This does not restrict a user, to run same job/endless loop/... on any other PC as a backup to ensure that config used will never expire._
  _Good example is use with mobile phone where one would be very restricted in keeping connection valid without to lose it. If you use this service on a router and you have ability to run tgapi on some other device, this would ensure that your config never expires._
- Currently used method by this script is to run the API call which does extend validity period in Torguard's system/backend 
- **If your device already has no internet, running api call would immediately let it work without reconnect or network restart**

#### Validation loop script

- default path:  `/usr/bin/tgapitest`

This script extends/validates connection to keep your wg active. Current restriction set by TorGuard is 15 minutes, please check always directly on torguard homepage/forum for any changes on this.
Script can run on every linux system.
If it uses wget or curl depends only on tginstall/tginit process finding/using either curl or wget.

#### tgapi service

- default path: `/etc/init.d/tgapi`


I wrote a demo scratch service file which can be used instead of cronjob, it is very simple, please extend it according to your needs

- to enable on boot and start it, simply run

  ```shell
  /etc/init.d/tgapi enable
  /etc/init.d/tgapi start
  ```

- how to check if script is running

  ```shell
  ps w | grep tgapitest
  ```

  results show you if script is /usr/bin/tgapitest is running, in example below with pid 3283
  
  ```log
  3283 root      1256 S    /bin/sh /usr/bin/tgapitest
  3535 root      1248 S    grep tgapitest
  ```

#### Example for New York shared server

first you need to convert your WG public key into API used formatting

##### Convert your public key to API format

replacing suffix `=` with `%3D`

- Example:
  `AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJLLL=`
  to
  `AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJLLL%3D`

##### Example API URL

- Example: Open in your browser:

    `https://User1:Pass1@173.244.200.119:1443/api/v1/setup?public-key=AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJLLL%3D`

## speedperf

Speedperf is a script performing iperf3 test with defined servers.  [Current public script](usr/bin/speedperf) uses only default client.

### Install speed perf

```shell
# Get speedperf bin
wget -O /etc/config/speedperf https://github.com/TorGuard/openwrt-scripts/raw/master/etc/config/speedperf

# Get speedperf config
wget -O /usr/bin/speedperf https://github.com/TorGuard/openwrt-scripts/raw/master/usr/bin/speedperf

# set speedperf bin as executable
chmod +x /usr/bin/speedperf
```

## FAQ (Freqently Asked Question)

Frequently Asked Questions on Wiki: https://github.com/TorGuard/openwrt-scripts/wiki#faq-frequently-asked-questions

[![Frequently Asked Questions](https://camo.githubusercontent.com/f27ce1937372cdd4dd6d360f508667885a066603/68747470733a2f2f692e6962622e636f2f637257707a6d4d2f6661712e706e67)](https://github.com/TorGuard/openwrt-scripts/wiki#faq-frequently-asked-questions)
