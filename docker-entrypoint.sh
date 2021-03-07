#!/bin/bash
set -x

# Reset root pw to a random
git clone https://gist.github.com/blade2005/fb9299900a9645fb95e03fb530bdd0ee.git genpw && \
chmod +x genpw/genpw && \
pw=$(python3 genpw/genpw -q -s -l 12) && \
echo "root:$pw" | chpasswd && 
echo "New password is '${pw}'"

# Start nginx forked
nginx -V
nginx &

# make sure the systemd run user dir exists
test -d /run/user/0 || mkdir -p /run/user/0

# ensure the parent log dir exists
test -d /var/log/wok || mkdir -p /var/log/wok

# ensure wok log files are present
test -e /var/log/wok/wok-error.log || touch /var/log/wok/wok-error.log
test -e /var/log/wok/wok-access.log || touch /var/log/wok/wok-access.log

# tail all the logs
tail -f /var/log/wok/wok-error.log /var/log/wok/wok-access.log /var/log/nginx/access.log /var/log/nginx/error.log &

# start the critical process
/usr/bin/wokd
