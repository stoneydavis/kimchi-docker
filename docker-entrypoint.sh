#!/bin/bash
set -x
nginx -V
nginx &
test -d /run/user/0 || mkdir -p /run/user/0
/usr/bin/wokd
