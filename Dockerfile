FROM alpine:3.22.1

WORKDIR /root

RUN apk update && \
    apk add bash curl pigz postgresql15-client postgresql16-client postgresql17-client rclone

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
