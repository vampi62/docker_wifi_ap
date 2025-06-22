# docker_wifi_ap

## Description
this project is a docker container that allows you to create a WiFi HotSpot with hostapd and dnsmasq(optional).

## Installation
you can choose between 2 versions of the container, one with dhcp and one without.

start by cloning the repository and moving to the folder:
```sh
cd /opt
sudo git clone https://github.com/vampi62/docker_wifi_ap.git
cd docker_wifi_ap
```
then you can choose between the 2 versions of the container.

### with DHCP
```sh
cd docker_wifi_ap/withDHCP
sudo chmod 755 -R config
sudo chown root:root -R config
docker build -t docker_wifi_ap:latest .
sudo docker run -d \
	--name docker_wifi_ap \
	--net host -it \
	--privileged \
	-v /opt/docker_wifi_ap/withDHCP/config/hostapd.conf:/etc/hostapd/hostapd.conf:ro \
	-v /opt/docker_wifi_ap/withDHCP/config/dnsmasq.conf:/etc/dnsmasq.conf:ro \
	--cap-add=SYS_ADMIN \
	--restart=always \
	docker_wifi_ap:latest
```
don't forget to edit the hostapd.conf and dnsmasq.conf files in the config folder to match your network configuration.

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

# if you cannot this method you can use the crontab for the same result
sudo crontab -e
@reboot sleep 60 && sudo iptables -A FORWARD -m iprange --src-range 192.168.5.0-192.168.5.255 -j ACCEPT
@reboot sleep 60 && sudo iptables -A FORWARD -m iprange --dst-range 192.168.5.0-192.168.5.255 -j ACCEPT
```


### without DHCP
first you need to configure the network interfaces to use the bridge br0

install the bridge-utils package and configure the network interfaces
```sh
sudo apt-get install bridge-utils
sudo brctl addbr br0
sudo brctl addif br0 eth0
```

make persistent the bridge configuration
```sh
sudo nano /etc/network/interfaces.d/docker_wifi_ap
# add the following lines in the file
auto br0
iface br0 inet dhcp
    bridge_ports eth0
```

disable the dhcp client on the wlan interface used by the hotspot and reboot the system before running the container
```sh
sudo nano /etc/dhcpcd.conf
# add the following lines in the file
interface wlan0 # interface used by the hotspot
  nohook wpa_supplicant

sudo reboot
```

then you can build and run the container
```sh
cd /opt/docker_wifi_ap/withoutDHCP
sudo chmod 755 -R config
sudo chown root:root -R config
docker build -t docker_wifi_ap:latest .
sudo docker run -d \
	--name docker_wifi_ap \
	--net host -it \
	--privileged \
	-v /opt/docker_wifi_ap/withoutDHCP/config/hostapd.conf:/etc/hostapd/hostapd.conf:ro \
	--cap-add=NET_ADMIN \
	--restart=always \
	docker_wifi_ap:latest
```
