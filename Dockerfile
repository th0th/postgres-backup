FROM alpine:3.23.2

RUN apk update && \
    apk add bash curl pigz postgresql16-client postgresql17-client postgresql18-client rclone

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
