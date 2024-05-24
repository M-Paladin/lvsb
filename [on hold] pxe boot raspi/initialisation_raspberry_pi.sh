#!/bin/bash

# Launch this script from your computer with a SD card connected.
# It will be used to initialize the Raspberry Pi once it starts (DietPi unattended install).
# Then the script "install_pxe_server.sh" will be executed from the raspberry pi thanks to AUTO_SETUP_CUSTOM_SCRIPT_EXEC parameter in dietpi.txt

#----------
# Parameters for Raspberry OS
#----------
raspi_os="DietPi"
config_file="dietpi.txt"

# Get Debian version name in lowercase
debian_version="$(curl -s http://ftp.fr.debian.org/debian/dists/stable/Release | sed -n 's/Codename: \(.*\)/\1/p')"

# image name for Rpi2, first debian letter in uppercase thanks to this symbol "^" (Bash 4+ built-in)
image_name="${raspi_os}_RPi-ARMv7-${debian_version^}"
image_ext="img"
compressed_ext="xz"
raspi_os_download_base_url="https://dietpi.com/downloads/images"

# hash file to check validity
hash_file="${image_name}.${image_ext}.${compressed_ext}.sha256"

# to uncompress
uncompress_program="xz"
uncompress_options=("--keep" "--decompress")

# working directories
download_directory="/tmp/${raspi_os}"
mount_point="/tmp/bootpi"

#----------
# Parameters to customize Raspberry OS
#----------
# https://github.com/MichaIng/DietPi/blob/master/dietpi.txt
conf_locale="fr_FR.UTF-8"
conf_keyb="fr"
conf_timezone="Europe/Helsinki"
conf_static_ip="1"
conf_ip_address="192.168.0.8"
conf_ip_gateway="192.168.0.1"
conf_dns_server="88.198.92.222 192.71.166.92" # LibreOps DNS
conf_hostname="pi-pxe-wol"
conf_custom_script_url="https://raw.githubusercontent.com/M-Paladin/lvsb/main/install_pxe_server.sh"
conf_web_server_index="-2"
conf_browser_index="0"
conf_automated="1"
conf_global_passwd="lvsb"
conf_install_sw="84"
conf_survey="0"
conf_serial="0"
conf_enable_ipv6="0"
conf_disable_ssh_password_login="root"

echo "
###
###  Downloading the latest ${raspi_os} image available
###
"

# Create mount point if needed
if [[ ! -d "${mount_point}" ]]; then
    echo "==> Creating mount point ${mount_point}"
    mkdir -p "${mount_point}"
fi

# Unmount mount point if needed
if grep -q "${mount_point}" <<< "$(mount)"; then
    echo "==> Unmounting mount point ${mount_point}"
    sudo umount "${mount_point}"
fi

# Remove any existing version
if [[ -d "${download_directory}" ]]; then
    echo "==> Removing ${raspi_os} directory ${download_directory}"
    rm -rf "${download_directory}"
fi

# Create and move to download directory
mkdir -p "${download_directory}"
pushd "${download_directory}"

# Download latest image
echo "==> Download latest ${raspi_os} image"
wget "${raspi_os_download_base_url}/${image_name}.${image_ext}.${compressed_ext}"
wget "${raspi_os_download_base_url}/${hash_file}"

# Test checksum, if KO delete files downloaded and exit script
echo "==> Calculate file checksum"
sha256_for_image="$(sha256sum ${image_name}.${image_ext}.${compressed_ext})"
if [[ "$(cat ${hash_file})" != "${sha256_for_image}" ]]; then
    echo "SHA256 calcul : ${sha256_for_image}"
    printf "SHA256 fichier : $(cat ${hash_file})"
    echo "Wrong checksum !"
    echo "==> Script aborted"
    popd
    exit 1
else
    echo "Right checksum !"
fi

# Uncompress image
echo "==> Uncompress image file and keep the compressed one"
# create an array from command to be able to execute it (beacuse of multiple options)
mycmd=("${uncompress_program}" "${uncompress_options[@]}" "${image_name}.${image_ext}.${compressed_ext}")
echo "${mycmd[@]}"
# expand the array to run the command
"${mycmd[@]}"

echo "
###
###  Customize image file by editing ${config_file}
###
"

sudo echo "Mount boot partition from image"
# Find start of partition
offset="$(sfdisk -J ${image_name}.${image_ext} | jq .partitiontable.partitions[0].start)"
sector_size="$(sfdisk -J ${image_name}.${image_ext} | jq .partitiontable.sectorsize)"
offset_mount=$(( "${offset}" * "${sector_size}" ))
# Mount partition 0
sudo mount -o loop,rw,sync,offset="${offset_mount}" "${image_name}.${image_ext}" "${mount_point}"
if grep -q "${mount_point}" /proc/self/mountinfo; then
    echo "Partition 0 mounted to ${mount_point}"
else
    echo "Impossible to mount partition 0 to ${mount_point}"
    exit 1
fi

# Update config file
sudo sed -i "s|^AUTO_SETUP_LOCALE=.*|AUTO_SETUP_LOCALE=${conf_locale}|g
             s|^AUTO_SETUP_KEYBOARD_LAYOUT=.*|AUTO_SETUP_KEYBOARD_LAYOUT=${conf_keyb}|g
             s|^AUTO_SETUP_TIMEZONE=.*|AUTO_SETUP_TIMEZONE=${conf_timezone}|g
             s|^AUTO_SETUP_NET_USESTATIC=.*|AUTO_SETUP_NET_USESTATIC=${conf_static_ip}|g
             s|^AUTO_SETUP_NET_STATIC_IP=.*|AUTO_SETUP_NET_STATIC_IP=${conf_ip_address}|g
             s|^AUTO_SETUP_NET_STATIC_GATEWAY=.*|AUTO_SETUP_NET_STATIC_GATEWAY=${conf_ip_gateway}|g
             s|^AUTO_SETUP_NET_STATIC_DNS=.*|AUTO_SETUP_NET_STATIC_DNS=${conf_dns_server}|g
             s|^AUTO_SETUP_NET_HOSTNAME=.*|AUTO_SETUP_NET_HOSTNAME=${conf_hostname}|g
             s|^AUTO_SETUP_CUSTOM_SCRIPT_EXEC=.*|AUTO_SETUP_CUSTOM_SCRIPT_EXEC=${conf_custom_script_url}|g
             s|^AUTO_SETUP_WEB_SERVER_INDEX=.*|AUTO_SETUP_WEB_SERVER_INDEX=${conf_web_server_index}|g
             s|^AUTO_SETUP_BROWSER_INDEX=.*|AUTO_SETUP_BROWSER_INDEX=${conf_browser_index}|g
             s|^AUTO_SETUP_AUTOMATED=.*|AUTO_SETUP_AUTOMATED=${conf_automated}|g
             s|^AUTO_SETUP_GLOBAL_PASSWORD=.*|AUTO_SETUP_GLOBAL_PASSWORD=${conf_global_passwd}|g
             s|#AUTO_SETUP_INSTALL_SOFTWARE_ID=.*|AUTO_SETUP_INSTALL_SOFTWARE_ID=${conf_install_sw}|g
             s|^SURVEY_OPTED_IN=.*|SURVEY_OPTED_IN=${conf_survey}|g
             s|^CONFIG_SERIAL_CONSOLE_ENABLE=.*|CONFIG_SERIAL_CONSOLE_ENABLE=${conf_serial}|g
             s|^CONFIG_ENABLE_IPV6=.*|CONFIG_ENABLE_IPV6=${conf_enable_ipv6}|g
             s|^SOFTWARE_DISABLE_SSH_PASSWORD_LOGINS=.*|SOFTWARE_DISABLE_SSH_PASSWORD_LOGINS=${conf_disable_ssh_password_login}|g" "${mount_point}/${config_file}"

# Go back to previous directory
popd

# Unmount mounted Image Partition 0 (Boot) ?
echo ""
read -r -p "Unmount ${mount_point} [y/n] ?" answer
if [[ "${answer}" == "y" ]]; then
    sudo umount "${mount_point}"
fi

# Write modified Raspi OS Image to SD Card ?
echo ""
read -r -p "Write image on sd card [y/n] ?" answer
if [[ "${answer}" == "y" ]]; then
    echo "Root access is needed, please type your password"
    # SD card detection, need root access
    for device in /dev/sd[a-f] ;do
        if sudo gdisk -l "${device}" 2>/dev/null| grep "^Model:.*Storage">/dev/null; then
            sdcard_device="$(basename ${device})"
            echo "SD card is in /dev/${sdcard_device}"
            break;
        fi
    done

    # No SD card found
    if [[ "${sdcard_device}" != "sd*" ]]; then
      echo "No SD card found"
      exit 1
    fi

    # Umount what is needed
    if [[ "$(mount | grep /dev/$SD | wc -l)" -gt 0 ]]; then
        echo "Unmount SD card before writing"
        for mount_point in $(mount | grep /dev/$SD | cut -d " " -f 1); do
            sudo umount $mount_point
        done
    fi

    echo "Unmount ${mount_point} before writing image"
    sudo umount "${mount_point}"

    # Write image on SD card
    echo "Writing image ${download_directory}/${image_name}.img to /dev/${sdcard_device}"
    sudo dd if="${download_directory}/${image_name}.img" of="/dev/${sdcard_device}" bs=4M conv=fsync status=progress oflag=direct
fi


