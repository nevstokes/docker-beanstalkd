FROM alpine:3.6 AS build

COPY alpine.patch /

ARG BEANSTALKD_VERSION=1.10

RUN set -euxo pipefail \
    \
    && apk --update add \
        gcc \
        libressl \
        make \
        musl-dev \
    \
    && mkdir -p /usr/src/beanstalk \
    && wget -qO- https://github.com/kr/beanstalkd/archive/v$BEANSTALKD_VERSION.tar.gz | tar xz -C /usr/src/beanstalk --strip-components=1 \
    \
    && cd /usr/src/beanstalk \
    && patch -p0 < /alpine.patch \
    && make CFLAGS=-Os \
    \
    && strip --strip-all beanstalkd


FROM alpine:3.6 AS libs

COPY --from=build /usr/src/beanstalk/beanstalkd /usr/local/bin/
COPY --from=build /var/cache/apk /var/cache/apk/

RUN set -euxo pipefail \
    \
    && echo '@community http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    && apk --update add upx@community \
    && scanelf --nobanner --needed /usr/local/bin/beanstalkd | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | xargs apk add \
    \
    && upx -9 /usr/local/bin/beanstalkd \
    && apk del --purge apk-tools upx \
    \
    && tar -czf lib.tar.gz /lib/*.so.*


FROM busybox

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

EXPOSE 11300

COPY --from=libs /usr/local/bin/beanstalkd /bin/
COPY --from=libs /lib.tar.gz /

RUN set -euxo pipefail \
    \
    && addgroup -S beanstalkd \
    && adduser -H -s /sbin/nologin -D -S -G beanstalkd beanstalkd \
    \
    && tar -xzf /lib.tar.gz \
    && rm -rf /*.tar.gz

USER beanstalkd
ENTRYPOINT ["beanstalkd", "-u", "beanstalkd"]

LABEL maintainer="Nev Stokes <mail@nevstokes.com>" \
        description="Beanstalkd general-purpose work queue" \
        org.label-schema.build-date="$BUILD_DATE" \
        org.label-schema.schema-version="1.0" \
        org.label-schema.vcs-ref="$VCS_REF" \
        org.label-schema.vcs-url="$VCS_URL"
