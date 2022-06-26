#!/bin/bash
# Installer curl pour lancer ce script
# sudo apt install curl

# puis pour l'exécuter
# https://raw.githubusercontent.com/M-Paladin/lvsb/main/install_pxe_server.sh | bash


# Configuration d'un serveur Debian PXE

# Mise à jour des sources Debian
sudo apt-get update

# Installation de dnsmasq (DHCP, TFTP)
sudo apt-get install -y dnsmasq

