################
# Cloud Images #
################
module "cloud_images" {
  for_each = var.cloud_images
  source   = "./modules/cloud_image"

  providers = {
    proxmox = proxmox
  }

  cloud_image_node_name          = each.value.node_name
  cloud_image_content_type       = each.value.content_type
  cloud_image_url                = each.value.img_url
  cloud_image_checksum           = each.value.img_checksum
  cloud_image_checksum_algorythm = each.value.img_checksum_algorythm
  cloud_image_file_name          = each.value.img_file_name
  cloud_image_datastore_image    = each.value.datastore
}

# moved {
#   from = module.cloud_images["debian-vm-cloud-image-old"].proxmox_virtual_environment_download_file.this
#   to   = module.cloud_images["debian-vm-cloud-image-12-1740"].proxmox_virtual_environment_download_file.this
# }

#####################
# Virtual Templates #
#####################
module "virtual_machine_templates" {
  # for_each = { for k, v in var.templates : k => v if v.is_vm }
  for_each = var.virtual_machine_templates
  source   = "./modules/virtual_machine"

  providers = {
    proxmox = proxmox
  }

  virtual_machine_hostname           = each.key
  virtual_machine_node_name          = each.value.node_name
  virtual_machine_memory             = each.value.memory
  virtual_machine_cpu_cores          = each.value.cpu_cores
  virtual_machine_disk_size          = each.value.disk_size
  virtual_machine_tags               = each.value.tags
  virtual_machine_template_id        = each.value.template_id
  virtual_machine_downloaded_file_id = module.cloud_images[each.value.cloud_image].cloud_image_downloaded_file_id
  virtual_machine_datastore_disk     = each.value.datastore_disk

  virtual_machine_is_template = true
}

# moved {
#   from = module.virtual_machine_templates["vm-template-debian-old"].proxmox_virtual_environment_vm.this
#   to   = module.virtual_machine_templates["vm-template-debian-B"].proxmox_virtual_environment_vm.this
# }

# module "lxc_container_templates" {
#   # for_each = { for k, v in var.templates : k => v if !v.is_vm }
#   for_each = var.lxc_container_templates
#   source   = "./modules/lxc_container"

#   providers = {
#     proxmox = proxmox
#   }
#   lxc_container_hostname           = each.key
#   lxc_container_node_name          = each.value.node_name
#   lxc_container_memory             = each.value.memory
#   lxc_container_disk_size          = each.value.disk_size
#   lxc_container_tags               = each.value.tags
#   lxc_container_is_template        = true
#   lxc_container_template_id        = each.value.template_id
#   lxc_container_downloaded_file_id = module.cloud_images[each.value.cloud_image].cloud_image_downloaded_file_id
#   lxc_container_datastore_disk     = each.value.datastore_disk
#   lxc_container_version_date       = "N/A"
# }

####################
# Virtual Machines #
####################
module "cloud-init" {
  for_each = var.virtual_machines
  source   = "./modules/cloud-init"

  providers = {
    proxmox = proxmox
  }

  cloud-init_hostname           = each.key
  cloud-init_node_name          = each.value.node_name
  cloud-init_deployment_info    = each.value.CI_deployment_info
  cloud-init_template-file      = each.value.CI_template-file
  cloud-init_datastore_snippets = each.value.CI_datastore_snippets
  cloud-init_user_name          = each.value.CI_user_name
}

module "virtual_machines" {
  for_each = var.virtual_machines
  source   = "./modules/virtual_machine"

  providers = {
    proxmox = proxmox
  }

  virtual_machine_hostname           = each.key
  virtual_machine_node_name          = each.value.node_name
  virtual_machine_memory             = each.value.memory
  virtual_machine_cpu_cores          = each.value.cpu_cores
  virtual_machine_disk_size          = each.value.disk_size
  virtual_machine_tags               = each.value.tags
  virtual_machine_template_node_name = module.virtual_machine_templates[each.value.vm-template].virtual_machine_template_node_name
  virtual_machine_template_id        = module.virtual_machine_templates[each.value.vm-template].virtual_machine_template_id
  virtual_machine_ip                 = each.value.ip
  virtual_machine_gateway            = each.value.gateway
  virtual_machine_config_file_id     = module.cloud-init[each.key].cloud-init_config_file_id
  virtual_machine_datastore_disk     = each.value.datastore_disk
  virtual_machine_dns_servers        = each.value.dns_servers
  virtual_machine_dns_domain         = each.value.dns_domain

  # virtual_machine_raw_disk_path  = each.value.raw_disk_path

  depends_on = [module.virtual_machine_templates]
}

##################
# LXC Containers #
##################
module "lxc_containers" {
  for_each = var.lxc_containers
  source   = "./modules/lxc_container"

  providers = {
    proxmox = proxmox
  }
  lxc_container_hostname           = each.key
  lxc_container_node_name          = each.value.node_name
  lxc_container_memory             = each.value.memory
  lxc_container_cpu_cores          = each.value.cpu_cores
  lxc_container_disk_size          = each.value.disk_size
  lxc_container_datastore_disk     = each.value.datastore_disk
  lxc_raw_disk_path                = each.value.raw_disk_path
  lxc_container_tags               = each.value.tags
  lxc_container_ip                 = each.value.ip
  lxc_container_gateway            = each.value.gateway
  lxc_container_dns_servers        = each.value.dns_servers
  lxc_container_dns_domain         = each.value.dns_domain
  lxc_container_downloaded_file_id = module.cloud_images[each.value.cloud_image].cloud_image_downloaded_file_id # each.value.cloud_image_id
  lxc_container_is_unpriviledged   = each.value.unpriviledged
  lxc_container_startup_order      = each.value.startup_order
  lxc_container_deployment_info    = each.value.deployment_info
  
  # lxc_container_template_id    = each.value.template_id

  # depends_on = [module.lxc_container_templates]
  depends_on = [module.cloud_images]
}

# data "proxmox_virtual_environment_vms" "fileserver" {
#   tags       = ["fileserver"]
#   depends_on = [module.debian_virtual_machine]
# }

# resource "terraform_data" "fileserver_inject_data_hdd_serial_number" {
#   count = 2

#   #depends_on = [data.proxmox_virtual_environment_vms.fileserver]
#   triggers_replace = var.virtual_machines["samba-${count.index+1}"].version_date

#   connection {
#     type     = "ssh"
#     user     = "root"
#     password = var.proxmox_password
#     host     = var.proxmox_nodes[data.proxmox_virtual_environment_vms.fileserver.vms[count.index].node_name]
#     agent    = false
#     timeout  = "10s"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "vmid='${data.proxmox_virtual_environment_vms.fileserver.vms[count.index].vm_id}'",
#       "if ! grep -q 'serial=' /etc/pve/qemu-server/$vmid.conf; then",
#       "  sed -i 's/${var.virtual_machines[data.proxmox_virtual_environment_vms.fileserver.vms[count.index].name].disk_serial}/&,serial=&/' /etc/pve/qemu-server/$vmid.conf",
#       "  qm reboot $vmid",
#       "  echo '${data.proxmox_virtual_environment_vms.fileserver.vms[count.index].name} rebooted'",
#       "fi",
#     ]
#   }
# }