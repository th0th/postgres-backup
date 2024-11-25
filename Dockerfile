FROM alpine:edge

WORKDIR /root

RUN apk update && \
    apk add bash curl pigz postgresql15-client postgresql16-client postgresql17-client rclone

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
