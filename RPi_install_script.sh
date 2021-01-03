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
#apt-get update

echo "Installing lsb_release..."
#apt-get --yes --no-install-recommends --reinstall install lsb-release
 
echo "Install github "
apt-get --yes --no-install-recommends install git

echo "Install webserver"
apt-get --yes --no-install-recommends install lighttpd
cd /tmp/
rm -Rf RPi_install_script
git clone https://github.com/rafichris/RPi_install_script.git
/tmp/RPi_install_script/www/html



echo "Install samba server"
apt-get install install -y samba samba-common-bin smbclient cifs-utils

cp -a /etc/samba/smb.conf /etc/samba/smb.conf.bak.$(date "+%Y.%m.%d-%H.%M.%S")

cat << EOT > /etc/samba/smb.conf
[global]
workgroup = WORKGROUP
security = user
server role = standalone server
obey pam restrictions = yes
unix password sync = yes

# For Unix password sync to work on a Debian GNU/Linux system, the following
# parameters must be set (thanks to Ian Kahan <<kahan@informatik.tu-muenchen.de> for
# sending the correct chat script for the passwd program in Debian Sarge).
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfu$

# This boolean controls whether PAM will be used for password changes
# when requested by an SMB client instead of the program listed in
# 'passwd program'. The default is 'no'.
   pam password change = yes

# This option controls how unsuccessful authentication attempts are mapped
# to anonymous connections
   map to guest = bad user
   guest account = pi

# Allow users who've been granted usershare privileges to create
# public shares, not just authenticated ones
   usershare allow guests = yes

#[pi]
#comment = Pi Directories
#browseable = yes
#path = /home/pi
#read only = no
#create mask = 0775
#directory mask = 0775

[www]
comment = Server HTML root
path = /var/www
browsable = yes
public = no
guest ok = yes
read only = no
writeable = yes
create mask = 0755
directory mask = 0755
locking = no
EOT

service smbd restart
