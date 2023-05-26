FROM alpine:3.16

CMD sh -c "cd /etc/ssl/traefik \
    && wget traefik.me/cert.pem -O cert.pem \
    && wget traefik.me/privkey.pem -O privkey.pem \
    && wget traefik.me/fullchain.pem -O fullchain.pem"
