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

RUN git clone https://gist.github.com/blade2005/fb9299900a9645fb95e03fb530bdd0ee.git genpw

FROM debian:buster-backports

ARG KIMCHI_VERSION=3.0.0
ARG WOK_VERSION=3.0.0

WORKDIR /tmp

COPY --from=builder /src/wok/*.deb /tmp/
COPY --from=builder /src/kimchi/*.deb /tmp/
COPY --from=builder /src/genpw/genpw /tmp/

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-utils gettext gettext-devel libguestfs-tools libnl-route-3-dev \
    libvirt-clients libvirt-daemon-system libvirt0 logrotate nfs-common nginx \
    novnc open-iscsi openssl procps python3-cheetah python3-cherrypy \
    python3-cherrypy3 python3-configobj python3-ethtool python3-guestfs \
    python3-jsonschema python3-ldap python3-libvirt python3-lxml \
    python3-m2crypto python3-magic python3-openssl python3-pam python3-pampy \
    python3-paramiko python3-parted python3-pil python3-psutil \
    python3-websockify qemu-kvm sosreport spice-html5 systemd && \
    rm -rf /var/lib/apt/lists/* && \
    dpkg -i /tmp/wok-$WOK_VERSION-0.debian.noarch.deb; \
    sh -x /var/lib/dpkg/info/wok.postinst; \
    dpkg -i /tmp/kimchi-$KIMCHI_VERSION-0.noarch.deb; \
    rm -rf /var/lib/apt/lists/*
EXPOSE 8001 8010
COPY docker-entrypoint.sh /docker-entrypoint.sh
USER root
ARG LOG_LEVEL=info
ENV LOG_LEVEL=$LOG_LEVEL
CMD ["/docker-entrypoint.sh"]
