FROM debian:10

ARG KIMCHI_VERSION=3.0.0
ARG WOK_VERSION=3.0.0
# Install Wok
RUN wget https://github.com/kimchi-project/wok/releases/download/$WOK_VERSION/wok-$WOK_VERSION-0.debian.noarch.deb && apt install -y ./wok-*.debian.noarch.deb
# Some Kimchi dependencies need to be installed via pip
RUN apt install -y python3-pip pkg-config libnl-route-3-dev && pip3 install -r https://raw.githubusercontent.com/kimchi-project/kimchi/master/requirements-UBUNTU.txt 
# Install Kimchi
RUN wget https://github.com/kimchi-project/kimchi/releases/download/$KIMCHI_VERSION/kimchi-$KIMCHI_VERSION-0.noarch.deb && apt install -y ./kimchi-.noarch.deb

EXPOSE 8001 8010

CMD [service, wokd, start]

