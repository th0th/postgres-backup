FROM postgres:18.0-alpine3.22 as postgres18

FROM alpine:3.22.2

RUN apk update && \
    apk add bash curl pigz postgresql15-client postgresql16-client postgresql17-client rclone

RUN mkdir -p /usr/libexec/postgresql18
COPY --from=postgres18 /usr/local/bin/pg_dump /usr/libexec/postgresql18/

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
