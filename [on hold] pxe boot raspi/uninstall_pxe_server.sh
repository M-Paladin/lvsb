#!/bin/bash
# Installer curl pour lancer ce script
# sudo apt install curl

# puis pour l'exécuter
# curl https://raw.githubusercontent.com/M-Paladin/lvsb/main/uninstall_pxe_server.sh | bash

# Suppression de dnsmasq (DHCP, TFTP)
cd ~
sudo apt-get remove --purge -y dnsmasq*
sudo rm -rf /var/log/dnsmasq.log /srv/tftp
sudo apt-get autoremove --purge -y
