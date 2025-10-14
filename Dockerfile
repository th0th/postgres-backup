FROM alpine:3.22.2

RUN apk update && \
    apk add bash curl pigz postgresql15-client postgresql16-client postgresql17-client postgresql18-client rclone

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
