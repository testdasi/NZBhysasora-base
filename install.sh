#!/bin/bash

### openvpn, nftables, stubby, tinyproxy, dante are in the base image ###

# add contrib and non-free repos. sab is in contrib
sed -i "s| main| main contrib non-free|g" '/etc/apt/sources.list'

# install more packages
apt-get -y update \
    && apt-get -y install jq curl unzip python3 openjdk-11-jre-headless locales

# remove non-UTF-8 locales, enable some locales (enabling all make building very slow), set to en_GB for default
sed -i -e "/UTF-8/!d" /etc/locale.gen \
    && sed -i -e "s/# en_GB/en_GB/g" /etc/locale.gen \
    && sed -i -e "s/# en_US/en_US/g" /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG='en_GB.UTF-8'

# install sabnzbdplus
apt-get -y install sabnzbdplus \
    && rm -rf /etc/init.d/sabnzbdplus \
    && rm -rf /etc/default/sabnzbdplus

# install nzbhydra2
NZBHYDRA2_RELEASE=$(curl -sX GET "https://api.github.com/repos/theotherp/nzbhydra2/releases/latest" | jq -r .tag_name)
NZBHYDRA2_VER=${NZBHYDRA2_RELEASE#v} \
    && curl -o /tmp/nzbhydra2.zip -L "https://github.com/theotherp/nzbhydra2/releases/download/v${NZBHYDRA2_VER}/nzbhydra2-${NZBHYDRA2_VER}-linux.zip" \
    && mkdir -p /app/nzbhydra2 \
    && unzip /tmp/nzbhydra2.zip -d /app/nzbhydra2 \
    && chmod +x /app/nzbhydra2/nzbhydra2wrapperPy3.py \
    && rm -f /tmp/nzbhydra2.zip \
    && echo "$(date "+%d.%m.%Y %T") nzbhydra2 binary release ${NZBHYDRA2_RELEASE}" >> /build_date.info

# clean up
#apt-get -y autoremove \
#    && apt-get -y autoclean \
#    && apt-get -y clean \
#    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*
