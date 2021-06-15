#!/bin/bash
#
# Copyright (c) 2021 C. Rafetzeder
#
# This file is licensed under the terms of the GNU General Public
# License version 2. This program is licensed "as is" without any
# warranty of any kind, whether express or implied.
#
# Ideas/code used from:
# https://github.com/armbian/config/blob/master/debian-software
# https://forum.openmediavault.org/index.php/Thread/25062-Install-OMV5-on-Debian-10-Buster/
#
# version: 1.0
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

echo ">> Updating repos before installing..."
apt-get update
apt-get --yes upgrade
apt-get --yes dist-upgrade
apt full-upgrade -y
apt autoremove -y
apt-get autoclean -y

read -p "> Setting Timezone to Europe/Vienna? (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes )
echo ">> Setting Timezone Europe/Vienna"
timedatectl set-timezone Europe/Vienna

    ;;
    * )
        # skippng installation
    ;;
esac

#echo ">> Installing lsb_release..."
#apt-get --yes --no-install-recommends --reinstall install lsb-release

read -p "> Install tiles webpage? (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes )
echo ">> Install github "
apt-get --yes --no-install-recommends install git

echo ">> Install webserver"
apt-get --yes --no-install-recommends install lighttpd
cd /tmp/
rm -Rf RPi_install_script
git clone https://github.com/rafichris/RPi_install_script.git
chmod 777 -R /tmp/RPi_install_script/www
cp -a /tmp/RPi_install_script/www/html/* /var/www/html/.

#cp -a /www/html_bak/* /var/www/html/.

    ;;
    * )
        # skippng installation
    ;;
esac

read -p "> Install samba server? (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes )
echo ">> Install samba server"
apt-get  --yes --no-install-recommends install samba samba-common-bin smbclient cifs-utils

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

    ;;
    * )
        # skippng installation
    ;;
esac

read -p "> Install Jenkins? (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes )

# https://developer-blog.net/raspberry-pi-als-jenkins-server/
echo ">> Install Jenkins DevOp..."
apt-get --yes --no-install-recommends install openjdk-11-jdk

wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

#apt-get update
apt-get --yes --no-install-recommends install jenkins
#service jenkins status

echo ">> Jenkins installed ..."
echo " -> Next steps: https://developer-blog.net/raspberry-pi-als-jenkins-server-teil-2/"

    ;;
    * )
        # skippng installation
    ;;
esac

read -p "> Enable SSH? (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes )

echo ">> Enable SSH"
touch /boot/ssh

    ;;
    * )
        # skippng installation
    ;;
esac


read -p "> Install ZRAM? (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes )

echo ">> Install ZRAM"
# https://github.com/ecdye/zram-config
#apt-get --yes install git
git clone --recurse-submodules https://github.com/ecdye/zram-config
cd zram-config
./install.bash

zram-config "stop"
sleep 5

cat << EOT > /etc/ztab
# Use '#' to comment out any line, add new drives with the first column
# providing the drive type and then drive details separated by tab characters.
#
# All algorithms in /proc/crypto are supported but only lzo-rle, lzo, lz4, and
# zstd have zramctl text strings; lzo-rle is the fastest with zstd having much
# better text compression.
#
# mem_limit is the compressed memory limit and will set a hard memory limit for
# the system admin.
#
# disk_size is the virtual uncompressed size approx. 220-450% of memory
# allocated depending on the algorithm and input file. Don't make it much higher
# than the compression algorithm is capable of as it will waste memory because
# there is a ~0.1% memory overhead when empty
#
# swap_priority will set zram over alternative swap devices.
#
# page-cluster 0 means tuning to singular pages rather than the default 3 which
# caches 8 for HDD tuning, which can lower latency.
#
# swappiness 80 because the improved performance of zram allows more usage
# without any adverse affects from the default of 60. It can be raised up to 100
# but that will increase process queue on intense loads such as boot time.
#
# target_dir is the directory you wish to hold in zram, and the original will be
# moved to a bind mount 'bind_dir' and is synchronized on start, stop, and write
# commands.
#
# bind_dir is the directory where the original directory will be mounted for
# sync purposes. Usually in '/opt' or '/var', name optional.
#
# oldlog_dir will enable log-rotation to an off device directory while retaining
# only live logs in zram. Usually in '/opt' or '/var', name optional.
#
# If you need multiple zram swaps or zram directories, just create another entry
# in this file.
# To do this safely, first stop zram using 'sudo zram-config "stop"', then edit
# this file.
# Once finished, restart zram using 'sudo systemctl start zram-config.service'.

# swap  alg             mem_limit       disk_size       swap_priority   page-cluster    swappiness
swap    lzo-rle         250M            750M            75              0               80

# dir   alg             mem_limit       disk_size       target_dir              bind_dir
#dir    lzo-rle         50M             150M            /home/pi                /pi.bind

# log   alg             mem_limit       disk_size       target_dir              bind_dir                oldlog_dir
log     lzo-rle         50M             150M            /var/log                /log.bind               /opt/zram/oldlog
EOT

zram-config "start"

    ;;
    * )
        # skippng installation
    ;;
esac

read -p "> Set Static IP? (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes )

echo ">> Set static IP"
service dhcpcd start
systemctl enable dhcpcd

cat << EOT > /etc/dhcpcd.conf
# A sample configuration for dhcpcd.
# See dhcpcd.conf(5) for details.

# Allow users of this group to interact with dhcpcd via the control socket.
#controlgroup wheel

# Inform the DHCP server of our hostname for DDNS.
hostname

# Use the hardware address of the interface for the Client ID.
clientid
# or
# Use the same DUID + IAID as set in DHCPv6 for DHCPv4 ClientID as per RFC4361.
# Some non-RFC compliant DHCP servers do not reply with this set.
# In this case, comment out duid and enable clientid above.
#duid

# Persist interface configuration when dhcpcd exits.
persistent

# Rapid commit support.
# Safe to enable by default because it requires the equivalent option set
# on the server to actually work.
option rapid_commit

# A list of options to request from the DHCP server.
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
# Respect the network MTU. This is applied to DHCP routes.
option interface_mtu

# Most distributions have NTP support.
#option ntp_servers

# A ServerID is required by RFC2131.
require dhcp_server_identifier

# Generate SLAAC address using the Hardware Address of the interface
#slaac hwaddr
# OR generate Stable Private IPv6 Addresses based from the DUID
slaac private

# Example static IP configuration:
interface eth0
static ip_address=192.168.178.224/24
#static ip6_address=fd51:42f8:caae:d92e::ff/64
static routers=192.168.178.1
static domain_name_servers=192.168.178.1 195.202.128.23 62.40.128.3 8.8.8.8

# It is possible to fall back to a static IP if DHCP fails:
# define static profile
#profile static_eth0
#static ip_address=192.168.1.23/24
#static routers=192.168.1.1
#static domain_name_servers=192.168.1.1

# fallback to static profile on eth0
#interface eth0
#fallback static_eth0
EOT
service dhcpcd restart

    ;;
    * )
        # skippng installation
    ;;
esac

read -p "> Create Cron job for daily rebooting? (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes )

echo ">> Create CRON job for rebooting"
command="sudo reboot"
job="0 3 * * * $command"
cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -

    ;;
    * )
        # skippng installation
    ;;
esac

read -p "> Install IOBroker/InfluxDB/Grafan? (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes )
echo ">> Install IOBroker"
# https://www.iobroker.net/#de/documentation/install/linux.md
apt-get --purge --yes remove node
apt-get --purge --yes remove nodejs
apt-get --yes autoremove

curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt-get --yes install nodejs
apt-get --yes install gcc g++ make
curl -sL https://iobroker.net/install.sh | bash -

echo ">> Install Influxdb"
# https://simonhearne.com/2020/pi-influx-grafana/
wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/os-release
echo "deb https://repos.influxdata.com/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
#apt-get update
apt-get --yes install influxdb

systemctl unmask influxdb.service
systemctl start influxdb
systemctl enable influxdb.service

echo ">> Install Grafana"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
#apt-get update
apt-get --yes install grafana
systemctl unmask grafana-server.service
systemctl start grafana-server
systemctl enable grafana-server.service

    ;;
    * )
        # skippng installation
    ;;
esac

read -p "> Install PiVPN (Wireguard)? (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes )

echo ">> Install PiVPN"
curl -L https://install.pivpn.io | bash
pivpn add
pivpn -qr

    ;;
    * )
        # skippng installation
    ;;
esac

read -p "> Install OMV? (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes )

# https://github.com/OpenMediaVault-Plugin-Developers/installScript
echo ">> Install OpenMediaVault"
wget -O - https://github.com/OpenMediaVault-Plugin-Developers/installScript/raw/master/install | sudo bash

    ;;
    * )
        # skippng installation
    ;;
esac

read -p "> Install Unify Controller? (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes )

# https://community.ui.com/questions/Step-By-Step-Tutorial-Guide-Raspberry-Pi-with-UniFi-Controller-and-Pi-hole-from-scratch-headless/e8a24143-bfb8-4a61-973d-0b55320101dc
echo ">> Install Unify Controller"
apt install openjdk-8-jre-headless -y
apt install haveged -y
apt install apt-transport-https -y
echo 'deb https://www.ui.com/downloads/unifi/debian stable ubiquiti' | sudo tee /etc/apt/sources.list.d/100-ubnt-unifi.list
wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg
apt install unifi -y

    ;;
    * )
        # skippng installation
    ;;
esac

read -p "> Install Plex Media Server? (y/n)? " answer
case ${answer:0:1} in
    y|Y|yes|Yes )

# https://snapcraft.io/install/plexmediaserver/raspbian
echo ">> Install Plex Media Server"
apt install snapd -y
snap install core
snap install plexmediaserver
    ;;
    * )
        # skippng installation
    ;;
esac
