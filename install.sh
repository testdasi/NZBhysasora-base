#!/bin/bash

# add contrib and non-free repos. sab is in contrib
sed -i "s| main| main contrib non-free|g" '/etc/apt/sources.list'

# install more packages
apt-get -y update \
    && apt-get -y install wget unzip sabnzbdplus

# remove sabnzbdplus config
rm -rf /etc/init.d/sabnzbdplus \
    && rm -rf /etc/default/sabnzbdplus

# clean up
#apt-get -y autoremove \
#    && apt-get -y autoclean \
#    && apt-get -y clean \
#    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*
