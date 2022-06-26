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
sudo mkdir -p /srv/tftp
sudo apt-get install -y dnsmasq

# Configuration de dnsmasq
netboot.tar.gz
echo "\
port=0
dhcp-range=$RESEAU,proxy
dhcp-boot=pxelinux.0,pxeserver,DHCP-SERVEUR
pxe-service=x86PC, "Install Linux", pxelinux
enable-tftp
tftp-root=/srv/tftp
log-queries
log-facility=/var/log/dnsmasq.log
" | sudo tee /etc/dnsmasq.d/pxe.conf

# Redémarrage du service pour prise en compte de la configuration
sudo service dnsmasq restart

# Recupération des fichiers de boot Debian
curl https://deb.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/netboot.tar.gz | sudo tar xzf - -C /srv/tftp

# droits de lecture sur le TFTP
chmod -R a+r /srv/tftp/*

# Démarrage en Bios ou UEFI possible
cd /srv/tftp
ln -s debian-installer/amd64/grubx64.efi .
ln -s debian-installer/amd64/grub .
cd ~
