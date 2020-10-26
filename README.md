# openwrt-scripts

TorGuard related OpenWRT scripts
- [openwrt-scripts](#openwrt-scripts)
  - [TorGuard Wireguard Installation](#torguard-wireguard-installation)
    - [download and install with wget](#download-and-install-with-wget)
    - [download and install with curl](#download-and-install-with-curl)
  - [Script descriptions](#script-descriptions)
    - [tginstall](#tginstall)
    - [tginit](#tginit)
    - [torguard's wireguard api v1](#torguards-wireguard-api-v1)
      - [API Expiration](#api-expiration)
      - [tgapi service](#tgapi-service)
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

### download and install with curl

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

Currently only whitelisted/whitelabeled keys work and to get one can be performed in several ways

- dumping the keys/config with TorGuard client on any pc
  
    ```shell
    # echo show full config of TorGuard client
    wg showconf torguard-wg
    ```

- check your TorGuard clients debug log
- using TorGuard's wireguard configuration tool

You can use the API manually, retrieve required values with a browser.

Public key for API usage has to be converted first into appropriate format by replacing suffix `=` with `%3D` 

- Usage:

    `https://[USER]:[PASS]@[SERVER]:[PORT]/api/v1/setup?public-key=[YOURPUBLICKEY]`


#### API Expiration

Currently every connection will work for 15 minutes, no disconnect will happen, but after 15 minutes you client will lose ability to connect to internet. To prevent this, one can run either own cronjob or start simply a service which runs by default every 5 minutes ensuring that config is extended for next 5 minutes.

- _This does not restrict a user, to run same job/endless loop/... on any other PC as a backup to ensure that config used will never expire. Good example is use with mobile phone where one would be very restricted in keeping connection valid without to lose it._
- To extend, currently used method by this script is to run simply API call which does extend in Torguard's system the use
- **If your device already has no internet, running api call would immediately let it work without reconnect or network restart**

#### tgapi service

I wrote a demo scratch service file which can be used instead of cronjob, it is very simple, please extend it according to your needs

- to enable on boot and start it, simply run

  ```shell
  /etc/init.d/tgapi enable
  /etc/init.d/start
  ```

#### Example for New York shared server

- Example: Open if your browser:

    `https://User1:Pass1@173.244.200.119:1443/api/v1/setup?public-key=AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJLLL%3D`

- Old Example (old, not working anymore): Open if your browser:

    `https://User1:Pass1@173.244.200.119:1443/api/v1/setup?public-key=AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJLLL=`

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
