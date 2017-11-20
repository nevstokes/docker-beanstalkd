FROM alpine:3.6 AS build

COPY alpine.patch github-releases.xsl /

ENV GITHUB_REPO=kr/beanstalkd

RUN echo '@community http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
        && apk --update add \
        gcc \
        libressl \
        libxslt-dev \
        make \
        musl-dev \
        upx@community

RUN mkdir -p /usr/src/beanstalk \
    \
    && export BEANSTALKD_VERSION=`wget -q https://github.com/$GITHUB_REPO/releases.atom -O - | xsltproc /github-releases.xsl - | awk -F/ '{ print $NF; }'` \
    && wget -qO- https://github.com/$GITHUB_REPO/archive/$BEANSTALKD_VERSION.tar.gz | tar xz -C /usr/src/beanstalk --strip-components=1

RUN cd /usr/src/beanstalk \
    && patch -p0 < /alpine.patch \
    && make CFLAGS=-Os \
    \
    && strip --strip-all beanstalkd \
    && upx -9 beanstalkd


FROM scratch

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

EXPOSE 11300

COPY --from=build /usr/src/beanstalk/beanstalkd /bin/
COPY --from=build /lib/ld-musl-x86_64.so.1 /lib/

ENTRYPOINT ["beanstalkd"]

LABEL maintainer="Nev Stokes <mail@nevstokes.com>" \
        description="Beanstalkd general-purpose work queue" \
        org.label-schema.build-date="$BUILD_DATE" \
        org.label-schema.schema-version="1.0" \
        org.label-schema.vcs-ref="$VCS_REF" \
        org.label-schema.vcs-url="$VCS_URL"
