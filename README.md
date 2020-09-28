# openwrt-scripts

TorGuard related OpenWRT scripts
- [openwrt-scripts](#openwrt-scripts)
  - [speedperf](#speedperf)
  - [tginstall](#tginstall)
  - [tginit](#tginit)
    - [torguard's wireguard api v1](#torguards-wireguard-api-v1)
      - [Example for New York shared server:](#example-for-new-york-shared-server)

## speedperf

Speedperf is a script performing iperf3 test with defined servers.  [Current public script](usr/bin/speedperf) uses only default client.

## tginstall

helper script for tginit. You can pass only 2 variables:

- (1) openwrt interface name, default is wg and will be used if no vars are passed
- (2) interface number, default is 0. Currently, _please make sure that there is no interface of same name before usage_

all other values are retrieved from [/etc/torguard](etc/config/torguard).

## tginit

Torguard initialization script. Script generates new keypair and retrieves wireguard interface options from TorGuard server to which a user connects to with your torguard credentials, then it creates wireguard interface. After script finishes, please recheck your new interface if all values are there and if everything is ok, reboot your device. 

### torguard's wireguard api v1

You can use the API manually, retrieve required values with a browser.

  - Description:

    `https://[USER]:[PASS]@[SERVER]:[PORT]/api/v1/setup?public-key=[YOURPUBLICKEY]`

#### Example for New York shared server:

  - Open if your browser (Example):

    `https://User1:Pass1@173.244.200.119:1443/api/v1/setup?public-key=AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJLLL=`
