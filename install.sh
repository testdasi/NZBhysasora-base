#!/bin/bash

# add contrib and non-free repos. sab is in contrib
sed -i "s| main| main contrib non-free|g" '/etc/apt/sources.list'

# install more packages
apt-get -y update \
    && apt-get -y install dnsutils wget sipcalc locales

# remove non-UTF-8 locales, enable some locales (enabling all make building very slow), set to en_GB for default
sed -i -e "/UTF-8/!d" /etc/locale.gen \
    && sed -i -e "s/# en_GB/en_GB/g" /etc/locale.gen \
    && sed -i -e "s/# en_US/en_US/g" /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG='en_GB.UTF-8'

# install openvpn and nft
apt-get install -y openvpn
apt-get install -y nftables

# install stubby and clean config
apt-get -y install stubby \
    && mkdir -p /etc/stubby \
    && rm -rf /etc/stubby/*

# install dante server
apt-get -y install dante-server \
    && rm -f /etc/danted.conf

# install tinyproxy
apt-get -y install tinyproxy \
    && mkdir -p /etc/tinyproxy \
    && rm -rf /etc/tinyproxy/*

# remove sabnzbdplus config
apt-get -y install unzip sabnzbdplus \
    && rm -rf /etc/init.d/sabnzbdplus \
    && rm -rf /etc/default/sabnzbdplus

# clean up
#apt-get -y autoremove \
#    && apt-get -y autoclean \
#    && apt-get -y clean \
#    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*
