FROM alpine:3.6 AS build

COPY alpine.patch github-releases.xsl /

ENV GITHUB_REPO=kr/beanstalkd

RUN apk --update add \
        gcc \
        libressl \
        libxslt-dev \
        make \
        musl-dev

RUN mkdir -p /usr/src/beanstalk \
    \
    && export BEANSTALKD_VERSION=`wget -q https://github.com/$GITHUB_REPO/releases.atom -O - | xsltproc /github-releases.xsl - | awk -F/ '{ print $NF; }'` \
    && wget -qO- https://github.com/$GITHUB_REPO/archive/$BEANSTALKD_VERSION.tar.gz | tar xz -C /usr/src/beanstalk --strip-components=1

RUN cd /usr/src/beanstalk \
    && patch -p0 < /alpine.patch \
    && make CFLAGS=-Os \
    \
    && strip --strip-all beanstalkd


FROM alpine:3.6 AS libs

COPY --from=build /usr/src/beanstalk/beanstalkd /usr/local/bin/
COPY --from=build /var/cache/apk /var/cache/apk/

RUN echo '@community http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    && apk --update add upx@community \
    && scanelf --nobanner --needed /usr/local/bin/beanstalkd | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | xargs apk add \
    \
    && upx -9 /usr/local/bin/beanstalkd \
    && apk del --purge apk-tools upx


FROM scratch

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

EXPOSE 11300

COPY --from=libs /usr/local/bin/beanstalkd /bin/
COPY --from=libs /lib/ld-musl-x86_64.so.1 /lib/

ENTRYPOINT ["beanstalkd"]

LABEL maintainer="Nev Stokes <mail@nevstokes.com>" \
        description="Beanstalkd general-purpose work queue" \
        org.label-schema.build-date="$BUILD_DATE" \
        org.label-schema.schema-version="1.0" \
        org.label-schema.vcs-ref="$VCS_REF" \
        org.label-schema.vcs-url="$VCS_URL"
