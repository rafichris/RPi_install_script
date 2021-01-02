#!/bin/bash
#
# shellcheck disable=SC1090,SC1091,SC1117,SC2016,SC2046,SC2086,SC2174
#
# Copyright (c) 2015-2020 OpenMediaVault Plugin Developers
# Copyright (c) 2017-2020 Armbian Developers
#
# This file is licensed under the terms of the GNU General Public
# License version 2. This program is licensed "as is" without any
# warranty of any kind, whether express or implied.
#
# Ideas/code used from:
# https://github.com/armbian/config/blob/master/debian-software
# https://forum.openmediavault.org/index.php/Thread/25062-Install-OMV5-on-Debian-10-Buster/
#
# version: 1.2.11
#

if [[ $(id -u) -ne 0 ]]; then
  echo "This script must be executed as root or using sudo."
  exit 99
fi

systemd="$(ps --no-headers -o comm 1)"
if [ ! "${systemd}" = "systemd" ]; then
  echo "This system is not running systemd.  Exiting..."
  exit 100
fi

echo "Updating repos before installing..."
apt-get update

echo "Installing lsb_release..."
apt-get --yes --no-install-recommends --reinstall install lsb-release
 
