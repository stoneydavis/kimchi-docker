#!/bin/bash
set -x

git clone https://gist.github.com/blade2005/fb9299900a9645fb95e03fb530bdd0ee.git genpw
chmod +x genpw/genpw
pw=$(genpw/genpw -q)
echo "root:$pw" | chpasswd
nginx -V
nginx &
test -d /run/user/0 || mkdir -p /run/user/0
test -d /var/log/wok || mkdir -p /var/log/wok
test -e /var/log/wok/wok-error.log || touch /var/log/wok/wok-error.log
test -e /var/log/wok/wok-access.log || touch /var/log/wok/wok-access.log

tail -f /var/log/wok/wok-error.log /var/log/wok/wok-access.log /var/log/nginx/access.log /var/log/nginx/error.log &

/usr/bin/wokd
