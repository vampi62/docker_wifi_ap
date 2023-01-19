FROM alpine

RUN apk add --no-cache dnsmasq hostapd

CMD dnsmasq && \
	hostapd /etc/hostapd/hostapd.conf
