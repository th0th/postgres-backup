FROM alpine:latest

LABEL maintainer="gokhan@webgazer.io"

RUN apk update && \
    apk add bash python3 postgresql-client nodejs npm

RUN pip3 install s3cmd

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
