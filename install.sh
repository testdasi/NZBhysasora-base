#!/bin/bash

# add contrib and non-free repos. sab is in contrib
sed -i "s| main| main contrib non-free|g" '/etc/apt/sources.list'

# install more packages
apt-get -y update \
    && apt-get -y install wget unzip locales sabnzbdplus

# enable all UTF-8 locales and remove the rest
sed -i -e "/UTF-8/!d" locale.gen \\
    && sed -i -e "s/# //g" locale.gen

# remove sabnzbdplus config
rm -rf /etc/init.d/sabnzbdplus \
    && rm -rf /etc/default/sabnzbdplus

# clean up
#apt-get -y autoremove \
#    && apt-get -y autoclean \
#    && apt-get -y clean \
#    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*
