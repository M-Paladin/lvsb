# Variables with default value
variable "virtual_machine_datastore_snippets" {
  description = "Proxmox datastore for snippets (hookscript such as cloud-init)"
  type        = string
  default     = "local"
}
variable "virtual_machine_datastore_disk" {
  description = "Proxmox datastore for disk"
  type        = string
  # default     = "cephstorage"
}
variable "virtual_machine_dns_domain" {
  description = "VM dns domain"
  type        = string
  default     = "maison.lvsb.fr"
}
variable "virtual_machine_cpu_cores" {
  description = "Number of cores"
  type        = number
  default     = 2
}
variable "virtual_machine_gateway" {
  description = "Default gateway IP address"
  type        = string
  default     = "192.168.0.1"
}
variable "virtual_machine_dns_servers" {
  description = "dns servers list"
  type        = list(string)
  # default     = ["192.168.0.3"]
}
variable "virtual_machine_is_template" {
  description = "is VM a template ?"
  type        = bool
  default     = false
}
variable "virtual_machine_template_node_name" {
  description = "template used for creation"
  type        = string
  default     = "pve-node-3"
}

# Variables with default null value, filled depending if template or not
variable "virtual_machine_ip" {
  description = "IP address CIDR format (ex : 192.168.0.1/24)"
  type        = string
  default     = null
}
variable "virtual_machine_config_file_id" {
  description = "id from the cloud-init module after resource creation"
  default     = null
}
variable "virtual_machine_downloaded_file_id" {
  description = "id from the cloud_image module after resource creation"
  default     = null
}
variable "virtual_machine_template_id" {
  description = "vm id for template VM"
  type        = number
  default     = null
}
variable "virtual_machine_raw_disk_path" {
  description = "vm data disk path for NAS VM"
  type        = string
  default     = null
}

# Variables to be filled
variable "virtual_machine_node_name" {
 description = "Proxmox node name on which it resides"
 type        = string
}
variable "virtual_machine_hostname" {
  description = "Hostname"
  type        = string
}
variable "virtual_machine_tags" {
  description = "Tags"
  type        = list(string)
}
variable "virtual_machine_memory" {
  description = "Memory size in MB"
  type        = number
}
variable "virtual_machine_disk_size" {
  description = "Disk (size in GB)"
  type        = number
}
