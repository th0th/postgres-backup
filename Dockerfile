FROM alpine:3

WORKDIR /root

RUN apk update && \
    apk add bash curl pigz postgresql14-client postgresql15-client postgresql16-client rclone

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
