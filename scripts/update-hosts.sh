#!/bin/bash
curl -o /etc/hosts "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
