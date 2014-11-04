#!/bin/bash
apt-get -y update
apt-get -y install python-software-properties
apt-get -y install build-essential

add-apt-repository ppa:nginx/stable
apt-get -y update

add-apt-repository ppa:ondrej/php5
apt-get -y update