FROM alpine:3.6 AS build

COPY alpine.patch /

# Config
ENV BEANSTALKD_VERSION=1.10

RUN set -euxo pipefail

RUN apk --update add --no-cache \
    gcc \
    musl-dev \
    make \
    libressl \
    tar

# Fetch
RUN mkdir -p /usr/src/beanstalk \
    && wget -qO- https://github.com/kr/beanstalkd/archive/v$BEANSTALKD_VERSION.tar.gz | tar xz -C /usr/src/beanstalk --strip-components=1

# Build
RUN cd /usr/src/beanstalk \
    && patch -p0 < /alpine.patch \
    && make \
    \
    # Ensmallment
    && strip --strip-all beanstalkd


# Clean slate
FROM alpine:3.6

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

COPY --from=build /usr/src/beanstalk/beanstalkd /usr/local/bin/

EXPOSE 11300

ENTRYPOINT ["beanstalkd"]

RUN set -euxo pipefail \
    \
    # User
    && addgroup -S beanstalkd \
    && adduser -H -s /sbin/nologin -D -S -G beanstalkd beanstalkd \
    \
    # Requirements
    && apk update \
    && scanelf --nobanner --needed `which beanstalkd` | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | xargs apk add --no-cache \
    \
    # Tidy up
    && rm -rf /var/cache \
    && find /bin -type l | grep -v /sh | xargs rm -f

USER beanstalkd

LABEL maintainer="Nev Stokes <mail@nevstokes.com>" \
        description="Beanstalkd general-purpose work queue" \
        org.label-schema.build-date="$BUILD_DATE" \
        org.label-schema.schema-version="1.0" \
        org.label-schema.vcs-ref="$VCS_REF" \
        org.label-schema.vcs-url="$VCS_URL"
