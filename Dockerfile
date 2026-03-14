FROM alpine:3.23.3

RUN apk update && \
    apk add bash curl pigz postgresql16-client postgresql17-client postgresql18-client rclone

COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
