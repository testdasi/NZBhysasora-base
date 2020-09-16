#!/bin/bash

### openvpn, nftables, stubby, tinyproxy, dante are in the base image ###

# install more packages
apt-get -y update \
    && apt-get -y install jq curl unzip locales openjdk-11-jre-headless python3 apt-transport-https dirmngr gnupg ca-certificates

# add contrib and non-free repos. sab is in contrib
sed -i "s| main| main contrib non-free|g" '/etc/apt/sources.list'

# add mono + mediaarea repo and install packages required for radarr
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && echo "deb https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list
curl -L "https://mediaarea.net/repo/deb/repo-mediaarea_1.0-13_all.deb" -o /tmp/key.deb \
    && dpkg -i /tmp/key.deb \
    && rm -f /tmp/key.deb \
    && echo "deb https://mediaarea.net/repo/deb/debian buster main" | tee /etc/apt/sources.list.d/mediaarea.list
apt-get -y update \
    && apt-get -y install bzip2 ca-certificates-mono libcurl4-openssl-dev mediainfo mono-devel mono-vbnc python sqlite3

# remove non-UTF-8 locales, enable some locales (enabling all make building very slow), set to en_GB for default
sed -i -e "/UTF-8/!d" /etc/locale.gen \
    && sed -i -e "s/# en_GB/en_GB/g" /etc/locale.gen \
    && sed -i -e "s/# en_US/en_US/g" /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG='en_GB.UTF-8'

# install sabnzbdplus
apt-get -y install sabnzbdplus

# install deluge
apt-get -y install deluged deluge-web

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

# install radarr
RADARR_RELEASE=$(curl -sX GET "https://api.github.com/repos/Radarr/Radarr/releases" | jq -r '.[0] | .tag_name')
radarr_url=$(curl -s https://api.github.com/repos/Radarr/Radarr/releases/tags/"${RADARR_RELEASE}" |jq -r '.assets[].browser_download_url' |grep linux) \
    && mkdir -p /app/radarr \
    && curl -L "${radarr_url}" -o /tmp/radar.tar.gz \
    && tar ixzf /tmp/radar.tar.gz -C /app/radarr --strip-components=1 \
    && rm -f /tmp/radar.tar.gz \
    && echo "$(date "+%d.%m.%Y %T") Added radarr binary release ${RADARR_RELEASE}" >> /build_date.info

# clean up
#apt-get -y autoremove \
#    && apt-get -y autoclean \
#    && apt-get -y clean \
#    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*
