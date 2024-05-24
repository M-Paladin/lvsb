module "debian_cloud_image" {
  for_each = var.templates
  providers = {
    proxmox = proxmox
  }
  source                         = "./modules/cloud_image"
  cloud_image_node_name          = each.value.node_name
  cloud_image_url                = each.value.img_url
  cloud_image_file_name          = each.value.img_file_name
  cloud_image_checksum           = each.value.img_checksum
  cloud_image_checksum_algorythm = each.value.img_checksum_algorythm
}

module "debian_template" {
  for_each = var.templates
  source   = "./modules/virtual_machine"

  providers = {
    proxmox = proxmox
  }
  virtual_machine_hostname           = each.key
  virtual_machine_node_name          = each.value.node_name
  virtual_machine_memory             = each.value.memory
  virtual_machine_disk_size          = each.value.disk_size
  virtual_machine_tags               = each.value.tags
  virtual_machine_is_template        = true
  virtual_machine_template_id        = each.value.template_id
  virtual_machine_downloaded_file_id = module.debian_cloud_image[each.key].cloud_image_downloaded_file_id
  virtual_machine_datastore_disk     = each.value.datastore_disk
}

module "debian_cloud-init" {
  for_each = var.virtual_machines
  providers = {
    proxmox = proxmox
  }
  source                     = "./modules/cloud-init"
  cloud-init_hostname        = each.key
  cloud-init_node_name       = each.value.node_name
  cloud-init_vm_version_date = each.value.version_date
}

module "debian_virtual_machine" {
  for_each = var.virtual_machines
  source   = "./modules/virtual_machine"

  providers = {
    proxmox = proxmox
  }
  virtual_machine_hostname       = each.key
  virtual_machine_node_name      = each.value.node_name
  virtual_machine_memory         = each.value.memory
  virtual_machine_disk_size      = each.value.disk_size
  virtual_machine_tags           = each.value.tags
  virtual_machine_template_id    = each.value.template_id
  virtual_machine_ip             = each.value.ip
  virtual_machine_config_file_id = module.debian_cloud-init[each.key].cloud-init_config_file_id
  virtual_machine_datastore_disk = each.value.datastore_disk
  virtual_machine_raw_disk_path  = each.value.raw_disk_path

  depends_on = [module.debian_template]
}
