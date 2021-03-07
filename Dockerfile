FROM debian:buster-backports as builder

ARG KIMCHI_VERSION=3.0.0
ARG WOK_VERSION=3.0.0

WORKDIR /src

USER 0

RUN apt-get update && apt-get install -y python3-pip gcc make autoconf automake git python3-pip python3-requests python3-mock gettext pkgconf xsltproc python3-dev pep8 pyflakes python3-yaml --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN git clone --single-branch -b $WOK_VERSION https://github.com/kimchi-project/wok.git && \
    cd wok && \
    ./autogen.sh --system && \
    make && \
    make deb

RUN git clone --single-branch -b $KIMCHI_VERSION https://github.com/kimchi-project/kimchi.git && \
    cd kimchi && \
    ./autogen.sh --system && \
    make && \
    make deb

FROM debian:buster-backports

ARG KIMCHI_VERSION=3.0.0
ARG WOK_VERSION=3.0.0

WORKDIR /tmp

COPY --from=builder /src/wok/*.deb /tmp/
COPY --from=builder /src/kimchi/*.deb /tmp/

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y python3-psutil procps python3-ldap python3-lxml \
    python3-websockify python3-jsonschema openssl nginx python3-cherrypy3 \
    python3-cheetah python3-pampy python3-m2crypto gettext python3-openssl \
    apt-utils git --no-install-recommends && \
    rm -rf /var/lib/apt/lists/* && \
    dpkg -i /tmp/wok-$WOK_VERSION-0.debian.noarch.deb; \
    sh -x /var/lib/dpkg/info/wok.postinst; \
    dpkg -i /tmp/kimchi-$KIMCHI_VERSION-0.noarch.deb; \
    rm -rf /var/lib/apt/lists/*
EXPOSE 8001 8010
COPY docker-entrypoint.sh /docker-entrypoint.sh
USER root
CMD ["/docker-entrypoint.sh"]
