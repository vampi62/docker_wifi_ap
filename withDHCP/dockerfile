FROM alpine

RUN apk add --no-cache dnsmasq hostapd supervisor

COPY supervisord.conf /etc/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]