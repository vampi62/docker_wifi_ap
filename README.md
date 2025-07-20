# light-wifi-ap

## Description
this project is a docker container that allows you to create a WiFi HotSpot with hostapd and dnsmasq(optional).

## Installation
you can choose between 2 versions of the container, one with dhcp and one without.

create a folder in your system to store the configuration files
```sh
sudo mkdir -p /opt/light-wifi-ap
```

### with DHCP

create the config folder and copy the configuration files
```sh
sudo nano /opt/light-wifi-ap/hostapd.conf
# add the following lines in the file
```

```sh
# Configuration for hostapd
# This is the name of the WiFi interface we configured above
interface=wlan0

# Use the nl80211 driver with the brcmfmac driver
driver=nl80211
ssid=yourNetworkName
hw_mode=g #"g" (2.4 GHz) or "a" for (5 GHz)
country_code=US #yourCountryCode (US, DE, etc.)
channel=6 # check if the channel is not used by other networks in your area for better performance
ieee80211n=1 # 802.11n support
wmm_enabled=1 # QoS support
ieee80211d=1 # limit the frequencies to those allowed in your country
macaddr_acl=0 # allow any device to connect
auth_algs=1 # 1=wpa, 2=wep, 3=both
ignore_broadcast_ssid=0
wpa=2 # 1=wpa, 2=wpa2, 3=wpa + wpa2
wpa_key_mgmt=WPA-PSK # WPA-PSK (Pre Shared Key) or WPA-EAP (Extensible Authentication Protocol)
rsn_pairwise=CCMP # CCMP (Counter Mode with Cipher Block Chaining Message Authentication Code Protocol) or TKIP (Temporal Key Integrity Protocol)
wpa_passphrase=yourPassword
# add the following lines in the file
```
```sh
sudo nano /opt/light-wifi-ap/dnsmasq.conf
```

```sh
# Configuration for dnsmasq
#dhcp-autoritative
domain-needed
bogus-priv

interface=wlan0
  dhcp-option=3,192.168.5.1
  
  dhcp-range=192.168.5.10,192.168.5.40,255.255.255.0,24h
  listen-address=::1,127.0.0.1,192.168.5.1
```

in your crontab add the following lines to allow the traffic between the wifi network and the ethernet network
```sh
# step 1
# add rule to iptables and make a backup file
sudo iptables -A FORWARD -m iprange --src-range 192.168.5.0-192.168.5.255 -j ACCEPT
sudo iptables -A FORWARD -m iprange --dst-range 192.168.5.0-192.168.5.255 -j ACCEPT
sudo iptables-save > /etc/iptables/rules
# step 2
# add the iptables-restore command to the rc.local file
sudo nano /etc/rc.local
iptables-restore < /etc/iptables/rules
```
if you cannot use this method you can use the crontab for the same result
```sh
sudo crontab -e
# add the following lines in the file
@reboot sleep 60 && sudo iptables -A FORWARD -m iprange --src-range 192.168.5.0-192.168.5.255 -j ACCEPT
@reboot sleep 60 && sudo iptables -A FORWARD -m iprange --dst-range 192.168.5.0-192.168.5.255 -j ACCEPT
```

disable the dhcp client on the wlan interface used by the hotspot
```sh
sudo nano /etc/dhcpcd.conf
# add the following lines in the file
interface wlan0 # interface used by the hotspot
  nohook wpa_supplicant
```

reboot the system before running the container
```sh
sudo reboot
```

after reboot, you can run the container without DHCP support
```sh
sudo docker run -d \
	--name light-wifi-ap \
	--net host -it \
	--privileged \
	-v /opt/light-wifi-ap/hostapd.conf:/etc/hostapd/hostapd.conf:ro \
	-v /opt/light-wifi-ap/dnsmasq.conf:/etc/dnsmasq.conf:ro \
	--cap-add=NET_ADMIN \
	--restart=unless-stopped \
	ghcr.io/vampi62/light-wifi-ap/with-dhcp:latest
```

### without DHCP

create the config folder and copy the configuration files
```sh
sudo nano /opt/light-wifi-ap/hostapd.conf
# add the following lines in the file
```

```sh
# Configuration for hostapd
# This is the name of the WiFi interface we configured above
interface=wlan0
bridge=br0

# Use the nl80211 driver with the brcmfmac driver
driver=nl80211
ssid=yourNetworkName
hw_mode=g #"g" (2.4 GHz) or "a" for (5 GHz)
country_code=US #yourCountryCode (US, DE, etc.)
channel=6 # check if the channel is not used by other networks in your area for better performance
ieee80211n=1 # 802.11n support
wmm_enabled=1 # QoS support
ieee80211d=1 # limit the frequencies to those allowed in your country
macaddr_acl=0 # allow any device to connect
auth_algs=1 # 1=wpa, 2=wep, 3=both
ignore_broadcast_ssid=0
wpa=2 # 1=wpa, 2=wpa2, 3=wpa + wpa2
wpa_key_mgmt=WPA-PSK # WPA-PSK (Pre Shared Key) or WPA-EAP (Extensible Authentication Protocol)
rsn_pairwise=CCMP # CCMP (Counter Mode with Cipher Block Chaining Message Authentication Code Protocol) or TKIP (Temporal Key Integrity Protocol)
wpa_passphrase=yourPassword
# add the following lines in the file
```

configure the network interfaces to use the bridge br0

install the bridge-utils package and configure the network interfaces
```sh
sudo apt-get install bridge-utils
sudo brctl addbr br0
sudo brctl addif br0 eth0
```

make persistent the bridge configuration
```sh
sudo nano /etc/network/interfaces.d/light-wifi-ap
# add the following lines in the file
auto br0
iface br0 inet dhcp
    bridge_ports eth0
```

disable the dhcp client on the wlan interface used by the hotspot
```sh
sudo nano /etc/dhcpcd.conf
# add the following lines in the file
interface wlan0 # interface used by the hotspot
  nohook wpa_supplicant
```

reboot the system before running the container
```sh
sudo reboot
```

don't forget to edit the hostapd.conf file in the config folder to match your network configuration.
after reboot, run the container without DHCP support
```sh
sudo docker run -d \
	--name light-wifi-ap \
	--net host -it \
	--privileged \
	-v /opt/light-wifi-ap/hostapd.conf:/etc/hostapd/hostapd.conf:ro \
	--cap-add=NET_ADMIN \
	--restart=unless-stopped \
	ghcr.io/vampi62/light-wifi-ap/with-dhcp:latest
```
