#!/bin/bash

# add contrib and non-free repos. sab is in contrib
sed -i "s| main| main contrib non-free|g" '/etc/apt/sources.list'

# install more packages
apt-get -y update \
    && apt-get -y install wget unzip locales sabnzbdplus

# remove non-UTF-8 locales and enable some locales (enabling all make building very slow)
sed -i -e "/UTF-8/!d" /etc/locale.gen \
    && sed -i -e "s/# en_GB/en_GB/g" /etc/locale.gen \
    && sed -i -e "s/# en_US/en_US/g" /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales

# remove sabnzbdplus config
rm -rf /etc/init.d/sabnzbdplus \
    && rm -rf /etc/default/sabnzbdplus

# clean up
#apt-get -y autoremove \
#    && apt-get -y autoclean \
#    && apt-get -y clean \
#    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*
