#!/bin/bash
# Installer curl pour lancer ce script
# sudo apt install curl

# puis pour l'exécuter
# https://raw.githubusercontent.com/M-Paladin/lvsb/main/install_pxe_server.sh | bash

# Configuration d'un serveur Debian PXE

RESEAU="192.168.1.1"
DHCP-SERVEUR="192.168.1.1"

# Mise à jour des sources Debian
sudo apt-get update

# Installation de dnsmasq (DHCP, TFTP)
sudo apt-get install -y dnsmasq

# Configuration de dnsmasq
echo "
port=0
dhcp-range=$RESEAU,proxy
dhcp-boot=pxelinux.0,pxeserver,DHCP-SERVEUR
pxe-service=x86PC, "Install Linux", pxelinux
enable-tftp
tftp-root=/srv/tftp
log-queries
log-facility=/var/log/dnsmasq.log
" | sudo tee /etc/dnsmasq.d/pxe.conf

sudo mkdir -p /srv/tftp
curl https://deb.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/netboot.tar.gz
sudo tar xzf -C /srv/tftp netboot.tar.gz
sudo rm -rf netboot.tar.gz
