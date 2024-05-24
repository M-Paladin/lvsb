#!/bin/bash
# Installer curl pour lancer ce script
# apt install curl

# puis pour l'exécuter
# https://raw.githubusercontent.com/M-Paladin/lvsb/main/install_pxe_server.sh | bash

# Configuration d'un serveur Debian PXE

#RESEAU="192.168.0.1"
#DHCP-SERVEUR="192.168.0.1"

# Mise à jour des sources Debian
#sudo apt-get update

# Backup de fichier originel de conf de dnsmasq
#cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup

# echo "
# # Repertoire pour boot bios et EFI"
# mkdir /tftp/data/netboot/{bios,efi64}

# echo "
# # Copier librairies specifiques a chaque architecture"
# cp \
#   /usr/lib/syslinux/modules/bios/{ldlinux,vesamenu,libcom32,libutil}.c32 \
#   /usr/lib/PXELINUX/pxelinux.0 \
#   /tftp/data/netboot/bios

# cp \
#   /usr/lib/syslinux/modules/efi64/ldlinux.e64 \
#   /usr/lib/syslinux/modules/efi64/{vesamenu,libcom32,libutil}.c32 \
#   /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi \
#   /tftp/data/netboot/efi64

# Installer dnsmasq
apt-get install -y dnsmasq

# echo "
# # Repertoire pour netinstall debian / proxmox"
# mkdir /srv/tftp/

# Création du fichier de configuration de dnsmasq
echo "Configuration de dnsmasq"
echo "
# Disable DNS Server
port=0

# Enable DHCP logging
log-dhcp

# Respond to PXE requests for the specified network
# Run as DHCP proxy
dhcp-range=192.168.0.110,192.168.0.115,24h
dhcp-boot=pxelinux.0,pxeserver,192.168.0.8

# Define cluster hosts
dhcp-host=78:2b:cb:b2:bf:72,192.168.0.111,pve1
dhcp-host=78:2b:cb:b2:bf:73,192.168.0.112,pve2
dhcp-host=78:2b:cb:b2:bf:74,192.168.0.113,pve3

# Provide network boot option called "Debian Proxmox Network Install"
pxe-service=x86PC,"Debian Proxmox Network Install",pxelinux

enable-tftp
tftp-root=/srv/tftp

log-queries
log-facility=/var/log/dnsmasq.log
" | tee /etc/dnsmasq.d/pxe.conf >/dev/null

# Création du répertoire de stockage des fichiers pour démarrer en tftp
echo "Creation des repertoires de tftp pour pxe"
mkdir -p /srv/tftp


#sudo apt-get install -y dnsmasq

# echo "
# /tftpboot/nfs   (ro,sync,no_wdelay,insecure_locks,no_root_squash,insecure,no_subtree_check) 
# " | tee -a /etc/exports >/dev/null
# exportfs -a

#cp -v /usr/lib/PXELINUX/pxelinux.0 /tftpboot/tftp
#cp -v /usr/lib/syslinux/modules/bios/{ldlinux.c32, libcom32.c32,libutil.c32, vesamenu.c32} /tftpboot/tftp

#mkdir -p /tftpboot/tftp/pxelinux.cfg
#touch /tftpboot/tftp/pxelinux.cfg/default

#isoimage="$(curl -s https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/ | grep netinst.iso | head -n 1 | cut -d '"' -f 6)"
#wget "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/${isoimage}"

#mount -o loop "${isoimage}" /mnt

#cp -Rfv /mnt/* /tftpboot/nfs/debian/

# Redémarrage du service dnsmasq pour prise en compte de la configuration
echo "Redémarrage du service dnsmasq pour prise en compte de la configuration"
service dnsmasq restart

# Recupération et installation des fichiers de boot Debian"
#echo "Recupération et installation des fichiers de boot Debian"
#curl --silent https://deb.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/netboot.tar.gz | tar xzf - -C /srv/tftp

# Ajout des droits de lecture sur le TFTP"
echo "Ajout des droits de lecture sur le TFTP"
chmod -R a+r /srv/tftp/*

# Démarrage en Bios ou UEFI possible"
#echo "Démarrage en Bios ou UEFI possible"
#cd /srv/tftp
#ln -s debian-installer/amd64/grubx64.efi .
#ln -s debian-installer/amd64/grub .
#ln -s /usr/lib/syslinux/modules/bios/chain.c32 .
#cd ~

sudo apt-get install xorriso cpio file zstd gzip genisoimage rsync squashfs-tools -y
pve_url="https://enterprise.proxmox.com/iso/"
pve_img="$(curl -s "${pve_url}" | grep proxmox-ve | sed -E "s/<[^>]*>//g" | sort -nr | head -n1 | cut -d" " -f1)"
wget "${pve_url}${pve_img}"
mkdir {pve-orig,pve-modified,pve-generated,pve-parts}
sudo mount -o loop ${pve_img}  pve-orig/
sudo rsync -av pve-orig/ pve-modified/
# initrd dans boot/initrd.img
# sudo zstd -d initrd.img -o initrd.img.unc
# sudo mkdir initrd.tmp
# cd initrd.tmp/
# sudo cpio -id < ../initrd.img.unc
sudo umount pve-orig
sudo dd if=${pve_img} bs=512 count=1 of=pve-parts/${pve_img}.mbr
#sudo nano boot/grub/grub.cfg
sudo mv pve-modified/boot/grub/grub.cfg pve-parts/
sed -i.orig "s/keep/keep\nset timeout=0/" pve-parts/grub.cfg
sudo mv pve-modified/pve-installer.squashfs pve-parts/
cd pve-parts
sudo unsquashfs pve-installer.squashfs
sudo mv pve-installer.squashfs pve-installer.squashfs.orig
cd squashfs-root
# https://github.com/proxmox/pve-installer/blob/master/proxinstall
# GUI global variables
sudo nano usr/bin/proxinstall
cd ..
sudo mksquashfs squashfs-root/ pve-installer.squashfs
cd ..
sudo cp pve-parts/grub.cfg pve-modified/boot/grub/grub.cfg
sudo cp pve-parts/pve-installer.squashfs pve-modified

cd pve-modified/
sudo xorriso -as mkisofs -o ../pve-generated/${pve_img} -r -V 'inspur' --grub2-mbr ../pve-parts/${pve_img}.mbr --protective-msdos-label -efi-boot-part --efi-boot-image  -c '/boot/boot.cat' -b '/boot/grub/i386-pc/eltorito.img' -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info -eltorito-alt-boot -e '/efi.img' -no-emul-boot .
cd ../pve-generated
wget https://raw.githubusercontent.com/morph027/pve-iso-2-pxe/master/pve-iso-2-pxe.sh
chmod +x pve-iso-2-pxe.sh

curl --silent https://deb.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/netboot.tar.gz | sudo tar xzf - -C /srv/tftp
cd /srv/tftp
mkdir proxmox
cd proxmox
ln -s /home/dietpi/pve-generated/pxeboot
cd debian-installer/amd64/boot-screens/
sudo cp txt.cfg txt.cfg.orig
#sudo nano menu.cfg
# set timeout=0
sudo nano txt.cfg
# label proxmox-install
#         menu label Install Proxmox
#         linux proxmox/pxeboot/linux26
#         append vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet splash=silent
#         initrd proxmox/pxeboot/initrd
