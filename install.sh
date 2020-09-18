#!/bin/bash

### openvpn, nftables, stubby, tinyproxy, dante are in the base image ###

# add contrib and non-free repos. sab is in contrib
sed -i "s| main| main contrib non-free|g" '/etc/apt/sources.list'
apt-get -y update
# create man1 folder otherwise openjdk-11-jre-headless would fail because of reasons
mkdir -p /usr/share/man/man1

# install packages required for sabnzbdplus
apt-get -y install unzip locales
# install packages required for nzbhydra2
apt-get -y install jq curl openjdk-11-jre-headless python3

# remove non-UTF-8 locales, enable some locales (enabling all make building very slow), set to en_GB for default
sed -i -e "/UTF-8/!d" /etc/locale.gen \
    && sed -i -e "s/# en_GB/en_GB/g" /etc/locale.gen \
    && sed -i -e "s/# en_US/en_US/g" /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG='en_GB.UTF-8'

# install sabnzbdplus
apt-get -y install sabnzbdplus

# install nzbhydra2
NZBHYDRA2_RELEASE=$(curl -sX GET "https://api.github.com/repos/theotherp/nzbhydra2/releases/latest" | jq -r .tag_name)
NZBHYDRA2_VER=${NZBHYDRA2_RELEASE#v} \
    && curl -L "https://github.com/theotherp/nzbhydra2/releases/download/v${NZBHYDRA2_VER}/nzbhydra2-${NZBHYDRA2_VER}-linux.zip" -o /tmp/nzbhydra2.zip \
    && mkdir -p /app/nzbhydra2 \
    && unzip /tmp/nzbhydra2.zip -d /app/nzbhydra2 \
    && chmod +x /app/nzbhydra2/nzbhydra2wrapperPy3.py \
    && chmod +x /app/nzbhydra2/nzbhydra2 \
    && rm -f /tmp/nzbhydra2.zip \
    && echo "$(date "+%d.%m.%Y %T") Added nzbhydra2 binary release ${NZBHYDRA2_RELEASE}" >> /build_date.info

# install my BrowserStartPage fork
cd /tmp \
    && curl -L "https://github.com/testdasi/BrowserStartPage/archive/master.zip" -o /tmp/launcher.zip \
    && mkdir -p /app \
    && unzip /tmp/launcher.zip \
    && mv /tmp/BrowserStartPage-master /app/launcher \
    && chmod +x /app/launcher/launcher-python2.sh \
    && chmod +x /app/launcher/launcher-python3.sh \
    && rm -f /tmp/launcher.zip

# clean up
apt-get -y autoremove \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*
