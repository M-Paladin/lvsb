#!/bin/bash

# This script will be launched at Raspberry Pi DietPi startup (AUTO_SETUP_CUSTOM_SCRIPT_EXEC).
# It will :
# - initialize DHCP/PXE server
# - prepare Debian unattended installation
# - install ansible (?)

#----------
#  Parameters to customize if needed
#----------
webserser_ip_address="192.168.0.8"
tftpserser_ip_address="192.168.0.8"
gw_ip_address="192.168.0.1"
domain_name="maison.lvsb.fr"
dns_servers="88.198.92.222,192.71.166.92" # LibreOps DNS

# target hosts
target_hosts_ip=(192.168.0.111 192.168.0.112 192.168.0.113)
target_hosts_mac=(78:2b:cb:b2:bf:72 b8:ca:3a:7c:d5:b9 00:24:1d:d3:71:3e) #d0:50:99:ab:4a:d9
target_hosts_name=(pve-node1 pve-node2 pve-node3)

# pxe, tftp, dhcp infos
tftp_path="/srv/tftp"
dnsmasq_conf_file="/etc/dnsmasq.d/pxe.conf"
preseed_filename="pve-preseed.cfg"
install_mode="bios" # "uefi" ?

# ssh keys
ssh_key_path="$HOME/.ssh"
ssh_key_type="ed25519"
ssh_key_name="id_${ssh_key_type}"
ssh_pubkey_name="${ssh_key_name}.pub"

# Refresh install
apt update
#apt-get upgrade -y

# Install dnsmasq
apt-get install -y dnsmasq
# cpio file zstd gzip genisoimage
# wget https://enterprise.proxmox.com/iso/$(curl -s https://enterprise.proxmox.com/iso/SHA256SUMS | awk '/proxmox-ve/{ print $2 }' | sort | tail -n1)
# wget https://raw.githubusercontent.com/morph027/pve-iso-2-pxe/master/pve-iso-2-pxe.sh
# chmod +x pve-iso-2-pxe.sh
# ./pve-iso-2-pxe.sh proxmox-ve_8.1-1.iso
# mv pxeboot/* /var/www/
# wget http://boot.ipxe.org/undionly.kpxe
# nano /etc/dnsmasq.d/pxe.conf
# pxe-service=x86PC, "Debian Network Install (for Proxmox)", "undionly.kpxe"
## iPXE sends a 175 option.
#dhcp-match=set:ipxe,175
#dhcp-boot=tag:!ipxe,undionly.kpxe
#dhcp-boot=http://192.168.0.8/bootpve.ipxe
# nano bootpve.ipxe
##!ipxe
#dhcp
#initrd http://192.168.0.8/initrd
#chain http://192.168.0.8/linux26 vga=791 video=vesafb:ywrap,mtrr ramdisk_size=16777216 rw quiet initrd=initrd splash=silent






# Create dnsmasq config file
echo "==> Create dnsmasq config"

cat > "${dnsmasq_conf_file}" << EOF
# Disable DNS Server
port=0

# Enable DHCP logging
log-dhcp

# Respond to PXE requests for the specified network
# Run as DHCP proxy
dhcp-range=${target_hosts_ip[0]},${target_hosts_ip[-1]},24h
dhcp-boot=pxelinux.0,pxeserver,$(hostname -I)

dhcp-option=option:dns-server,${dns_servers}
dhcp-option=option:router,${gw_ip_address}
dhcp-option=option:domain-name,${domain_name}

# Ignore hosts not declared
dhcp-ignore=tag:!known

# Define cluster hosts
EOF

# add all hosts to dnsmasq config file
for (( i=0; i<${#target_hosts_ip[@]}; i++ )); do
        echo "dhcp-host=${target_hosts_mac[i]},${target_hosts_ip[i]},${target_hosts_name[i]}" | tee -a "${dnsmasq_conf_file}" >/dev/null
done

# add rest of dnsmsq config file
cat > "${dnsmasq_conf_file}" << EOF
### PXE's native menu ###
pxe-prompt="Press F8 to choose boot device:",5
pxe-service=x86PC, "Boot from local disk"
pxe-service=x86PC, "Debian Network Install (for Proxmox)", "pxelinux"

enable-tftp
tftp-root=${tftp_path}

log-queries
log-facility=/var/log/dnsmasq.log
EOF

# Create TFTP directory for PXE boot
echo "Create TFTP directory for PXE boot"
mkdir -p "${tftp_path}"

# Restart dnsmasq service with new config
echo "Restart dnsmasq service with new config"
service dnsmasq restart

# Download Debian network install and extract it"
echo "Download Debian network install and extract it"
curl --silent https://deb.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/netboot.tar.gz | tar xzf - -C "${tftp_path}"

# Configure rights on TFTP directory"
echo "Configure rights on TFTP directory"
chmod -R a+r "${tftp_path}/"

# Allow BIOS or UEFI boot (we currently use bios)
echo "Allow BIOS or UEFI PXE boot"
pushd "${tftp_path}" >/dev/null
ln -s debian-installer/amd64/grubx64.efi .
ln -s debian-installer/amd64/grub .
ln -s /usr/lib/syslinux/modules/bios/chain.c32 .

# Download and create preseed file for unattended installation
# Full explaination : https://preseed.debian.net/debian-preseed/
curl --silent -o "${preseed_filename}" https://www.debian.org/releases/stable/example-preseed.txt

# Don't use simple locale
sed -i "s|d-i debian-installer/locale string en_US|#d-i debian-installer/locale string en_US|" "${preseed_filename}"
# Language french
sed -i "s|#d-i debian-installer/language string en|d-i debian-installer/language string fr|" "${preseed_filename}"
# country Finland
sed -i "s|#d-i debian-installer/country string NL|d-i debian-installer/country string FI|" "${preseed_filename}"
# locale french UTF-8
sed -i "s|#d-i debian-installer/locale string en_GB.UTF-8|d-i debian-installer/locale string fr_FR.UTF-8|" "${preseed_filename}"

# keyboard french azerty
sed -i "s|d-i keyboard-configuration/xkb-keymap select us|d-i console-keymaps-at/keymap select fr-latin9\nd-i keyboard-configuration/xkb-keymap select fr(latin9)|" "${preseed_filename}"

# wait for network and dhcp
sed -i "s|#d-i netcfg/link_wait_timeout string 10|d-i netcfg/link_wait_timeout string 10|" "${preseed_filename}"
sed -i "s|#d-i netcfg/dhcp_timeout string 60|d-i netcfg/dhcp_timeout string 60|" "${preseed_filename}"
# name and domain set by dhcp server
sed -i "s|d-i netcfg/get_hostname string unassigned-hostname|#d-i netcfg/get_hostname string unassigned-hostname|" "${preseed_filename}"
sed -i "s|d-i netcfg/get_domain string unassigned-domain|#d-i netcfg/get_domain string unassigned-domain|" "${preseed_filename}"

# use firmware non-free if needed
sed -i "s|#d-i hw-detect/load_firmware boolean true|d-i hw-detect/load_firmware boolean true|" "${preseed_filename}"

# use ftp.fi.debian.org as apt mirror
sed -i "s|d-i mirror/http/hostname string http.us.debian.org|d-i mirror/http/hostname string ftp.fi.debian.org|" "${preseed_filename}"

# no need for a user
sed -i "s|#d-i passwd/make-user boolean false|d-i passwd/make-user boolean false|" "${preseed_filename}"
# choose root password (probably temporary)
sed -i "s|#d-i passwd/root-password password r00tme|d-i passwd/root-password password lvsb|" "${preseed_filename}"
sed -i "s|#d-i passwd/root-password-again password r00tme|d-i passwd/root-password-again password lvsb|" "${preseed_filename}"

# Timezone Finland
sed -i "s|d-i time/zone string US/Eastern|d-i time/zone string Europe/Helsinki|" "${preseed_filename}"

# Disk partitionning, normal, non lvm
sed -i "s|d-i partman-auto/method string lvm|d-i partman-auto/method string regular|" "${preseed_filename}"
sed -i "s|d-i partman-auto-lvm/guided_size string max|#d-i partman-auto-lvm/guided_size string max|" "${preseed_filename}"
sed -i "s|d-i partman-lvm/device_remove_lvm boolean true|#d-i partman-lvm/device_remove_lvm boolean true|" "${preseed_filename}"
sed -i "s|d-i partman-md/device_remove_md boolean true|#d-i partman-md/device_remove_md boolean true|" "${preseed_filename}"
sed -i "s|d-i partman-lvm/confirm boolean true|#d-i partman-lvm/confirm boolean true|" "${preseed_filename}"
sed -i "s|d-i partman-lvm/confirm_nooverwrite boolean true|#d-i partman-lvm/confirm_nooverwrite boolean true|" "${preseed_filename}"
# choose partitions
sed -zi 's|#d-i partman-auto/expert_recipe string|d-i partman-auto/expert_recipe string|1' "${preseed_filename}" # Replace only first occurence
sed -zi 's|#\( *boot-root\)|\1|' "${preseed_filename}"
if [[ ${install_mode} == "bios" ]]; then
        # 1 root and 1 swap partition
        sed -zi 's|#\( *\)40 50 100 ext3       |\1100000 110000 -1 ext4|g' "${preseed_filename}"
        sed -zi 's|#\( *\)\$primary{ } \$bootable{ }|\1\$primary{ } \$bootable{ }|g' "${preseed_filename}"
        sed -zi 's|#\( *\)method{ format } format{ }|\1method{ format } format{ }|g' "${preseed_filename}"
        sed -zi 's|#\( *\)use_filesystem{ } filesystem{ ext3 }|\1use_filesystem{ } filesystem{ ext4 }|g' "${preseed_filename}"
        sed -zi 's|#\( *\)mountpoint{ /boot }.*mountpoint{ / }\( *\)\\\n#|\1mountpoint{ / }\2\\\n|g' "${preseed_filename}" # Consider new line as a 1 line
        sed -zi 's|#\( *\)64 512 300% linux-swap       |\116384 120000 16384 linux-swap|' "${preseed_filename}"
        sed -zi 's|#\( *\)method{ swap } format{ }            \( *\)\\\n#|\1$primary{ } method{ swap } format{ }\2\\\n|' "${preseed_filename}"
else # uefi
        # 1 EFI, 1 root and 1 swap partition
        sed -zi 's|#\( *\)40 50 100 ext3   |\1538 538 1075 free|' "${preseed_filename}"
        sed -zi 's|#\( *\)$primary{ } $bootable{ }|\1$iflabel{ gpt }         |' "${preseed_filename}"
        sed -zi 's|#\( *\)method{ format } format{ }|\1$reusemethod{ }           |' "${preseed_filename}"
        sed -zi 's|#\( *\)use_filesystem{ } filesystem{ ext3 }|\1method{ efi }                       |' "${preseed_filename}"
        sed -zi 's|#\( *\)mountpoint{ /boot }\( *\)\\\n#|\1format{ }          \2\\\n|' "${preseed_filename}"
        sed -zi 's|#\( *\)500 10000 1000000000 ext3|\1100000 110000 -1 ext4    |' "${preseed_filename}"
        sed -zi 's|#\( *\)method{ format } format{ }|\1$primary{ } $bootable{ }                \\\n\1method{ format } format{ }|' "${preseed_filename}"
        sed -zi 's|#\( *\)use_filesystem{ } filesystem{ ext3 }|\1use_filesystem{ } filesystem{ ext4 }|' "${preseed_filename}"
        sed -zi 's|#\( *\)mountpoint{ / }\( *\)\\\n#|\1mountpoint{ / }\2\\\n|' "${preseed_filename}"
        sed -zi 's|#\( *\)64 512 300% linux-swap       |\116384 120000 16384 linux-swap|' "${preseed_filename}"
        sed -zi 's|#\( *\)method{ swap } format{ }            \( *\)\\\n#|\1$primary{ } method{ swap } format{ }\2\\\n|' "${preseed_filename}"
        # UEFI booting
        sed -i "s|#d-i partman-efi/non_efi_system boolean true|d-i partman-efi/non_efi_system boolean true|" "${preseed_filename}"
        sed -i "s|#d-i partman-partitioning/choose_label select gpt|d-i partman-partitioning/choose_label select gpt|" "${preseed_filename}"
        sed -i "s|#d-i partman-partitioning/default_label string gpt|d-i partman-partitioning/default_label string gpt|" "${preseed_filename}"
fi

# no cdrom source for apt
sed -i "s|d-i apt-setup/cdrom/set-first boolean false|#d-i apt-setup/cdrom/set-first boolean false|" "${preseed_filename}"
sed -i "s|#d-i apt-setup/disable-cdrom-entries boolean true|d-i apt-setup/disable-cdrom-entries boolean true|" "${preseed_filename}"

# certificate not needed
sed -i "s|#d-i debian-installer/allow_unauthenticated boolean true|d-i debian-installer/allow_unauthenticated boolean true|" "${preseed_filename}"

# only server standard
sed -i "s|#tasksel tasksel/first multiselect standard, web-server, kde-desktop|tasksel tasksel/first multiselect standard|" "${preseed_filename}"

# with ssh and net-tools
sed -i "s|#d-i pkgsel/include string openssh-server build-essential|d-i pkgsel/include string openssh-server net-tools|" "${preseed_filename}"

# no survey
sed -i "s|#popularity-contest popularity-contest/participate boolean false|popularity-contest popularity-contest/participate boolean false|" "${preseed_filename}"

# disk detection before partitionning
# place a flag to upgrade to proxmox
# download ssh keys
# allow ssh root login
# enhance locale
# enhance /etc/hosts
cat >> "${preseed_filename}" <<EOF

d-i partman/early_command string \\
	BOOTDISK="\$(parted_devices | sort -k 2 -n | head -n1 | cut -f1)"; \\
	debconf-set partman-auto/disk \$BOOTDISK; \\
	debconf-set grub-installer/bootdev \$BOOTDISK

d-i preseed/late_command string \\
        in-target bash -c "touch /root/upgrade_debian_to_proxmox"; \\
        in-target bash -c "apt-get install -y curl"; \\
        in-target bash -c "mkdir /root/.ssh"; \\
        in-target bash -c "curl http://${webserser_ip_address}/${ssh_pubkey_name} | tee /root/.ssh/authorized_keys"; \\
        in-target bash -c "sed -i 's\#PermitRootLogin.*\PermitRootLogin yes\g' /etc/ssh/sshd_config"; \\
        in-target bash -c "echo 'LANGUAGE=\"fr_FR.UTF-8\"' | tee -a /etc/default/locale"; \\
        in-target bash -c "echo 'LC_ALL=\"fr_FR.UTF-8\"' | tee -a /etc/default/locale"; \\
        in-target bash -c "sed -i '/^127.0.1.1/d' /etc/hosts";
EOF

popd >/dev/null

# Change boot menu entry
echo "Change PXE boot menu entry"
pushd /srv/tftp/debian-installer/amd64/boot-screens/ >/dev/null
sed -i "s/menu.cfg/debian-proxmox.cfg/g" syslinux.cfg
sed -i "s/timeout 0/timeout 1/g" syslinux.cfg
cat > "debian-proxmox.cfg" <<EOF
menu tabmsg
menu title Network Deploy Debian

label install
    menu default
    menu label ^Debian Install (for Proxmox)
    kernel debian-installer/amd64/linux
    append auto=true priority=critical vga=788 initrd=debian-installer/amd64/initrd.gz preseed/url=tftp://${tftpserser_ip_address}/${preseed_filename} --- quiet

menu end
EOF

popd >/dev/null

# Generate ssh keys
echo "Generate ssh keys"
ssh-keygen -t "${ssh_key_type}" -f "${ssh_key_path}/${ssh_key_name}" -N ""

# Copy public key to web server
echo "Copy public key to web server"
cp ${ssh_key_path}/${ssh_pubkey_name} /var/www

# Install python
echo "Install Python Ansible"
apt-get install -y python3 python3-pip python3-venv
python3 -m venv /root/venv_ansible
source /root/venv_ansible/bin/activate
pip3 install --upgrade pip
pip3 install ansible jmespath dnspython netaddr

# Install ansible
#echo "Install ansible"
#apt-get install -y ansible python3-cryptography python3-yaml

# Disable ssh key verification
cat > /etc/ssh/ssh_config.d/no_key_verifying.conf <<EOF
Host 192.168.0.*
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
EOF