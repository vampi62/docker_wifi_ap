# docker_wifi_ap

créer un conteneur docker hostapd-dnsmasq

```sh
cd /opt
sudo git clone https://github.com/vampi62/docker_wifi_ap.git
cd /docker_wifi_ap
docker build -t docker_wifi_ap:latest .
sudo docker run -d \
	--name docker_wifi_ap \
	--net host -it \
	--privileged \
	-v /opt/ap/hostapd.conf:/etc/hostapd/hostapd.conf:ro \
	-v /opt/ap/dnsmasq.conf:/etc/dnsmasq.conf:ro \
	--cap-add=SYS_ADMIN \
	--restart=always \
	docker_wifi_ap:latest
```

ajouter les 2 commandes cron ci-dessous pour permettre d'acceder au peripherique du réseaux depuis l'exterieur.
n'oublier pas changer la plage d'adresse ip

```sh
@reboot sleep 60 && sudo iptables -A FORWARD -m iprange --src-range 192.168.5.0-192.168.5.255 -j ACCEPT
@reboot sleep 60 && sudo iptables -A FORWARD -m iprange --dst-range 192.168.5.0-192.168.5.255 -j ACCEPT
```
