
---

<a href="https://github.com/TorGuard/openwrt-scripts/wiki#faq-frequently-asked-questions"><img src="https://raw.githubusercontent.com/wiki/TorGuard/openwrt-scripts/assets/images/faq.png" width="50"></a>
<a href="https://torguard.net/"><img src="https://raw.githubusercontent.com/wiki/TorGuard/openwrt-scripts/assets/images/torguard-logo.png" width="200"></a>
<a href="https://github.com/openwrt/openwrt"><img src="https://raw.githubusercontent.com/openwrt/openwrt/master/logo.svg" width="200"></a>

---

# TorGuard related OpenWRT scripts

- [TorGuard related OpenWRT scripts](#torguard-related-openwrt-scripts)
  - [TorGuard Wireguard Installation](#torguard-wireguard-installation)
    - [download and install with wget](#download-and-install-with-wget)
    - [download and install with curl](#download-and-install-with-curl)
  - [Script descriptions](#script-descriptions)
    - [tginstall](#tginstall)
    - [tginit](#tginit)
    - [tgfunctions](#tgfunctions)
    - [torguard's wireguard api v1](#torguards-wireguard-api-v1)
      - [API Expiration](#api-expiration)
      - [Validation loop script](#validation-loop-script)
      - [tgapi service](#tgapi-service)
      - [Example for New York shared server](#example-for-new-york-shared-server)
        - [Convert your public key to API format](#convert-your-public-key-to-api-format)
        - [Example API URL](#example-api-url)
  - [speedperf](#speedperf)
    - [speedperf - show all settings](#speedperf---show-all-settings)
    - [speedperf default settings](#speedperf-default-settings)
    - [Install speed perf manually](#install-speed-perf-manually)
    - [How to start speedperf script](#how-to-start-speedperf-script)
  - [FAQ (Freqently Asked Question)](#faq-freqently-asked-question)

## TorGuard Wireguard Installation

Installation can be performed by running [/usr/bin/tginstall](usr/bin/tginstall):

### download and install with wget

```shell
# first download functions script
wget -O /usr/bin/tgsetup https://raw.githubusercontent.com/TorGuard/openwrt-scripts/master/usr/bin/tgsetup && chmod +x /usr/bin/tgsetup && /usr/bin/tgsetup
```

### download and install with curl

```shell
curl -o /usr/bin/tgsetup https://raw.githubusercontent.com/TorGuard/openwrt-scripts/master/usr/bin/tgsetup && chmod +x /usr/bin/tgsetup && /usr/bin/tgsetup
```

## Script descriptions

### tginstall

- [default path](usr/bin/tginstall): `/usr/bin/tginstall`

helper script for tginit. You can pass only 2 variables:

- (1) openwrt interface name, default is wg and will be used if no vars are passed
- (2) interface number, default is 0. Currently, _please make sure that there is no interface of same name before usage_

all other values are retrieved from [/etc/config/torguard](etc/config/torguard).

### tginit

- [default path](usr/bin/tginit): `/usr/bin/tginit`
- logfile:      `/var/log/torguard/tginit/tginit.log`

Torguard initialization script. Script generates new keypair and retrieves wireguard interface options from TorGuard server to which a user connects to with your torguard credentials, then it creates wireguard interface. After script finishes, please recheck your new interface if all values are there and if everything is ok, reboot your device.

### tgfunctions

All function of all scripts are currently in file /use/bin/tgfunctions.

- [default path](usr/bin/tgfunctions): `/usr/bin/tgfunctions`

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

  ```log
  https://[USER]:[PASS]@[SERVER]:[PORT]/api/v1/setup?public-key=[YOURPUBLICKEY]`
  ```

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

Demo service file which can be used instead of cronjob is created by tginit, it is very simple, please extend it according to your needs

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

    ```log
    https://User1:Pass1@173.244.200.119:1443/api/v1/setup?public-key=AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJLLL%3D
    ```

## speedperf

- [Speedperf](usr/bin/speedperf) is a script performing iperf3 test with defined servers. [/usr/bin/speedperf](usr/bin/speedperf) uses only default client.
- Check [/etc/config/speedperf](etc/config/speedperf) for more info about default config.
- Default config with iperf3 will compress all logs into folder: `/var/log/speedperf/iperf3`

### speedperf - show all settings

to show full list of available servers and their settings and set closest/fastest to your location

```shell
uci show speedperf
```

### speedperf default settings

- Default settings
  - [x] Default Server: `EU central - Germany`
    - Server URL: `speedtest.wtnet.de`
  - [x] Compress single logs: `1` (yes)
  - [x] Compress folder: `1` (yes)
    - [x] tar.gz archive: `/var/log/speedperf/iperf3/speedperf_default_client_[DATE]-[EPOCH]_[IPERF3SERVERURL]`
  - [x] Logdir: `/var/log/speedperf`
  - [x] Logfile: `speedperf_default_client`
  - [x] Pidfile: `/var/run/speedperf_default_client.pid`
  - [x] Storage: `/var/log/speedperf/iperf3`
  - [x] Tests
    - [x] Repetitions: `10`
    - [x] normal
    - [x] reverse
    - [x] tcp test
      - [x] Parallel connections tcp: `10`
    - [x] udp test
      - [x] Parallel connections udp: `10`

### Install speed perf manually

```shell
# Get speedperf bin
wget -O /etc/config/speedperf https://github.com/TorGuard/openwrt-scripts/raw/master/etc/config/speedperf

# Get speedperf config
wget -O /usr/bin/speedperf https://github.com/TorGuard/openwrt-scripts/raw/master/usr/bin/speedperf

# set speedperf bin as executable
chmod +x /usr/bin/speedperf
```

### How to start speedperf script

1. Run with [default settings](etc/config/speedperf)

   ```shell
   speedperf
   ```

## FAQ (Freqently Asked Question)

<a href="https://github.com/TorGuard/openwrt-scripts/wiki#faq-frequently-asked-questions"><img src="https://raw.githubusercontent.com/wiki/TorGuard/openwrt-scripts/assets/images/faq.png" width="14"> Frequently Asked Questions on Wiki</a>
