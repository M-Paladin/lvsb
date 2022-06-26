#!/bin/bash
# Installer curl pour lancer ce script
# sudo apt install curl

# puis pour l'exécuter
# curl curl -H 'Authorization: token GHSAT0AAAAAABWAJ3QCTMCTROBMCJK567PWYVYULVQ' -H 'Accept: application/vnd.github.v3.raw' -O -L https://api.github.com/repos/M-Paladin/lvsb/main/install_pxe_server.sh | bash


# Setup Debian PXEinstall environment

# Mise à jour des sources Debian
sudo apt update

# Installation de dnsmasq (DHCP, TFTP)
sudo apt install dnsmasq
