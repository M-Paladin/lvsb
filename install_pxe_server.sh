#!/bin/bash
# Installer curl pour lancer ce script
# sudo apt install curl

# puis pour l'exécuter
# curl

# Setup Debian PXEinstall environment

# Mise à jour des sources Debian
sudo apt update

# Installation de dnsmasq (DHCP, TFTP)
sudo apt install dnsmasq
