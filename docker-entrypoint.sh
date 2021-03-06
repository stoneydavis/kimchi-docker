#!/bin/bash
set -x
nginx -V
nginx &
test -d /run/user/0 || mkdir -p /run/user/0
test -d /var/log/wok || mkdir -p /var/log/wok
test -e /var/log/wok/wok-error.log || touch /var/log/wok/wok-error.log
test -e /var/log/wok/wok-access.log || touch /var/log/wok/wok-access.log

tail -f /var/log/wok/wok-error.log /var/log/wok/wok-access.log /var/log/nginx/access.log /var/log/nginx/error.log &

/usr/bin/wokd
