#!/bin/bash

echo "
##################################################
#
# Downloading the latest RasPiOS image available
# 
##################################################"

download_directory="/tmp"
mount_point="/tmp/bootpi"

if [[ ! -d "${mount_point}" ]]; then mkdir -p "${mount_point}"; fi

if grep -q "${mount_point}" <<< "$(mount)"; then sudo umount "${mount_point}"; fi

echo "
# Check the lastest version"
version_folder="$(curl --silent https://downloads.raspberrypi.org/raspios_lite_armhf/images/ | grep armhf-2 | cut -d "-" -f 2,3,4 | cut -d "/" -f 1 | tail -n 1)"
version_image="$(curl --silent "https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-${version_folder}/" | grep lite.img | cut -d "\"" -f 8 | cut -d "." -f 1 | tail -n 1)"

echo "
# Check if image file is already downloaded"
if [ ! -f "${download_directory}/${version_image}.img.xz" ]; then
    wget "https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-${version_folder}/${version_image}.img.xz" -P "${download_directory}/"
    chown 1000:1000 "$download_directory/$version_image.img.xz"
fi

echo "
# Check if checksum file is already downloaded"
if [ ! -f "${download_directory}/${version_image}.img.xz.sha256" ]; then
    wget "https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-${version_folder}/${version_image}.img.xz.sha256" -P "${download_directory}/"
    chown 1000:1000 "${download_directory}/${version_image}.img.xz.sha256"
fi

echo "
# Test checksum, if KO delete files downloaded"
sha256="$(sha256sum ${download_directory}/${version_image}.img.xz | cut -d" " -f1)"
if [ "${sha256}" != "$(cat ${download_directory}/${version_image}.img.xz.sha256 | cut -d" " -f1)" ]; then    
    echo "SHA256 calcul : ${sha256}"
    echo "SHA256 fichier : $(cat ${download_directory}/${version_image}.img.xz.sha256)"
    echo "difference de checksum, suppression en cours. Veuillez relancer le script pour télécharger à nouveau les fichiers"
    rm -rf "${download_directory}/${version_image}.img.xz*"
fi

echo "
# Uncompress image file and keep the compressed one"
if [ ! -f "${download_directory}/${version_image}.img" ]; then
    unxz -k "${download_directory}/${version_image}.img.xz"
    #chown 1000:1000 "${download_directory}/${version_image}.img"
fi

echo "
########################################################
#
# Customize image file
# https://gitlab.com/JimDanner/pi-boot-script
# https://raspberrypi.stackexchange.com/questions/33817/use-boot-cmdline-txt-for-creating-first-boot-script
#
########################################################"

echo "
# Mount boot partition from image"
sudo umount "${mount_point}"
rm -rf "${mount_point}"
mkdir -p "${mount_point}"
sudo mount -o loop,rw,sync,offset=4194304 "${download_directory}/${version_image}.img" "${mount_point}"
mount | grep 202

pwd="$(echo 'lvsb' | openssl passwd -6 -stdin)"
echo "lvsb:${pwd}" | sudo tee "${mount_point}/userconf.txt" >/dev/null

# For elaborate configuration it makes sense to run a script during a 'normal' boot.
# In that case, the unattended script only does the preparations to make it possible.
#echo "
# Download unattended script"
#curl --silent https://gitlab.com/JimDanner/pi-boot-script/-/raw/master/unattended | tee "${mount_point}/unattended" >/dev/null
#sed -i '7 a echo "Copying content to /home/pi ..."' "${mount_point}/unattended"
#sed -i '10 a sleep 5' "${mount_point}/unattended"
#sed -i '11 a "Copying content to / ..."' "${mount_point}/unattended"

echo "
# Create unattended script"
echo "
# 1. MAKING THE SYSTEM WORK. DO NOT REMOVE
mount -t tmpfs tmp /run
mkdir -p /run/systemd
mount / -o remount,rw
sed -i 's| init=.*||' /boot/cmdline.txt

# 2. THE USEFUL PART OF THE SCRIPT
echo 'Copying content of /boot/payload to /'
[[ -d /boot/payload ]] && cp --preserve=timestamps -r /boot/payload/* / && rm -rf /boot/payload
ls -la /usr/local/bin/*.sh
echo '----------'
ls -la /usr/lib/systemd/system/*script.service
echo '----------'
sleep 5
echo 'Creating a symlink for one-time-script.service'
[[ -f /usr/lib/systemd/system/one-time-script.service ]] && ln -s /usr/lib/systemd/system/one-time-script.service /etc/systemd/system/multi-user.target.wants/
ls -la /etc/systemd/system/multi-user.target.wants/o*
sleep 5

# 3. CLEANING UP AND REBOOTING
echo 'sync'
sync
echo 'remounting /boot in read-only'
umount /boot
mount / -o remount,ro
echo 'sync'
sync
echo 'modyfing /proc/sys/kernel/sysrq'
echo 1 > /proc/sys/kernel/sysrq
echo 'modyfing /proc/sysrq-trigger'
echo b > /proc/sysrq-trigger
sleep 5
" | sudo tee "${mount_point}/unattended" >/dev/null

# This project has two scripts for normal-boot execution:
# payload/usr/local/bin/one-time-script.sh for configuration
# payload/usr/local/bin/packages-script.sh for installation of packages, using apt-get.
echo "
# Create payload tree and download files and scripts"
sudo rm -rf "${mount_point}/payload"
sudo mkdir -p "${mount_point}/payload/usr/local/bin"
curl --silent https://gitlab.com/JimDanner/pi-boot-script/-/raw/master/one-time-script.conf | sudo tee "${mount_point}/one-time-script.conf" >/dev/null
curl --silent https://gitlab.com/JimDanner/pi-boot-script/-/raw/master/payload/usr/local/bin/one-time-script.sh | sudo tee "${mount_point}/payload/usr/local/bin/one-time-script.sh" >/dev/null
curl --silent https://gitlab.com/JimDanner/pi-boot-script/-/raw/master/payload/usr/local/bin/packages-script.sh | sudo tee "${mount_point}/payload/usr/local/bin/packages-script.sh" >/dev/null
curl --silent https://raw.githubusercontent.com/M-Paladin/lvsb/main/install_pxe_server.sh  | sudo tee "${mount_point}/payload/usr/local/bin/install_pxe_server.sh" >/dev/null

sudo mkdir -p "${mount_point}/payload/usr/lib/systemd/system"
curl --silent https://gitlab.com/JimDanner/pi-boot-script/-/raw/master/payload/lib/systemd/system/one-time-script.service | sudo tee "${mount_point}/payload/usr/lib/systemd/system/one-time-script.service" >/dev/null
curl --silent https://gitlab.com/JimDanner/pi-boot-script/-/raw/master/payload/lib/systemd/system/packages-script.service | sudo tee "${mount_point}/payload/usr/lib/systemd/system/packages-script.service" >/dev/null
chmod -x "${mount_point}/payload/usr/lib/systemd/system/*.service"

echo "
# Modifying kernel boot"
sudo sed -i 's|init=.*|init=/bin/bash -c "mount -t proc proc /proc; mount -t sysfs sys /sys; mount /boot; source /boot/unattended"|g' "${mount_point}/cmdline.txt"

echo "
# Customize one-time-script"
sudo sed -i "s|pi\$modelnr-\$new_hostname_tag-\$serial|\$new_hostname_tag|g" "${mount_point}/payload/usr/local/bin/one-time-script.sh"
sudo sed -i "s|^reboot||g" "${mount_point}/payload/usr/local/bin/one-time-script.sh"
echo "\
echo \"\
# static IP configuration:
# OpenNIC DNS
interface eth0
static ip_address=192.168.0.8/24
static routers=192.168.0.1
static domain_name_servers=95.217.190.236 95.216.99.249
\" | tee -a \"/etc/dhcpcd.conf\" >/dev/null

sed -i \"s|gb|fr|g\" /etc/default/keyboard

reboot" | sudo tee -a "${mount_point}/payload/usr/local/bin/one-time-script.sh" >/dev/null

echo "
# Customize packages-script"
install_pxe_server="
source /usr/local/bin/install_pxe_server.sh
reboot"
sudo sed -i "s|^reboot|source /usr/local/bin/install_pxe_server.sh\nreboot|g" "${mount_point}/payload/usr/local/bin/packages-script.sh"

echo "
# Customize scripts configuration"
sudo sed -i "s|#new_partition_size_MB = 100|new_partition_size_MB = 0|g" "${mount_point}/one-time-script.conf"
sudo sed -i "s|#new_locale = en_GB.UTF-8|new_locale = fr_FR.UTF-8|g" "${mount_point}/one-time-script.conf"
sudo sed -i "s|#new_timezone = Europe/London|new_timezone = Europe/Helsinki|g" "${mount_point}/one-time-script.conf"
sudo sed -i "s|#new_hostname_tag =|new_hostname_tag = pi-pxe-wol|g" "${mount_point}/one-time-script.conf"
sudo sed -i "s|#packages_to_install =|packages_to_install = dnsmasq pxelinux syslinux-efi|g" "${mount_point}/one-time-script.conf"

# voir /home/ludovic/DocLudo/jobs/IOGS/Mes Documents/Enseignement

echo "
# Unmount boot partition"
read -r -p "demonter et supprimer ${mount_point} [y/n] ?" answer
if [[ "${answer}" == "y" ]]; then
    sudo umount "${mount_point}"
    rm -rf "${mount_point}"
fi

echo "
# Write SD Card"
read -r -p "ecrire l'image sur la carte sd [y/n] ?" answer
if [[ "${answer}" == "y" ]]; then
    sudo umount "${mount_point}"
    sudo umount "/media/ludovic/boot"
    sudo umount "/media/ludovic/rootfs"
    sudo dd if="${download_directory}/${version_image}.img" of=/dev/sdb bs=4M conv=fsync status=progress
fi


