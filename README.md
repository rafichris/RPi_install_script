# RPi_install_script
- please use a new SD card if installing on an arm/sbc device.
- will install lighttpd, samba and jenkins

### install the script's prerequisites
#### apt-get install wget sudo

### download script and execute
- the wget option -O needs to be a capital letter 'O'
- the second wget '-' has a space on both sides

#### sudo wget -O - https://raw.githubusercontent.com/rafichris/RPi_install_script/main/RPi_install_script.sh | sudo bash
#### -OR-
#### sudo curl -sSL https://raw.githubusercontent.com/rafichris/RPi_install_script/main/RPi_install_script.sh | sudo bash
