# docker_wifi_ap

créer un conteneur docker hostapd-dnsmasq (WiFi HotSpot)

n'oubliez pas de changer les paramètres des fichiers dans le dossier ap. (interface,ssid,mdp,...)

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

ajouter les 2 commandes cron ci-dessous pour permettre aux peripherique du réseaux d'acceder à l'exterieur.
(n'oublier pas changer la plage d'adresse ip indiquer dans les commandes si vous les avez changer dans les config du dossier ap.)
```sh
sudo crontab -e
@reboot sleep 60 && sudo iptables -A FORWARD -m iprange --src-range 192.168.5.0-192.168.5.255 -j ACCEPT
@reboot sleep 60 && sudo iptables -A FORWARD -m iprange --dst-range 192.168.5.0-192.168.5.255 -j ACCEPT
```
