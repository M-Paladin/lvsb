# Variables with default value
variable "lxc_container_datastore_disk" {
  description = "Proxmox datastore for disk"
  type        = string
  default     = "local-lvm"
}
variable "lxc_container_is_unpriviledged" {
  description = "is container unpriviledged ?"
  type        = bool
  default     = false
}
# variable "lxc_container_is_template" {
#   description = "is VM a template ?"
#   type        = bool
#   default     = false
# }
# variable "lxc_container_template_node_name" {
#   description = "template used for VM creation"
#   type        = string
#   default     = "pve-node-3"
# }
variable "lxc_container_user_sshpubkey_jenkins_agent" {
  description = "public ssh key to be accessed from ansible"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC34EtA66CnvOo1LwlnBX98qxEqtkCzWwUOMkgqIC1kdVfQeOJyR9EcnfAwZiPZ940PWG/6nAzybYKNe1YgSKb/MVKRV0CKtb55hSatgBerK9vV0BByZSai3ILbSLsXHMbu2lh3spQAXi2SDroBPNITfeAWCS3BW6+dmuRErL93V5tkkWCF8MKzmQd6ev/C4xZs9H61TboeSjbaH+31eiPtOJmZ4qn4fGfgM6W6uHl1BvPLKEWlCUQ38i+4+TObwrjxxlRMzm80e+IQj7PG/6Ry9iWyUrU5ePi3hlwMBEI4KyxB1W/h5Ie3iLT3ug/H6+zgOT0qNzVXSgGro9xL8GkFSU9bNJpeCZuPwFflMivF56XeGFLQoKUkb1UBkpeChdz7pHUcUrO3cWsWXdFPdj/tskLEuA8zGLF6xvtFkFfKzX7vzGo8MYx1A2lvThi01syuIyUtUSrfONt6dImwOeqB7Xc7VXc8fAQFczjDlU+rFst3Wmx1ddNI4kaUyYkyZE0= jenkins_agent_ansible"
}
# variable "lxc_container_user_name" {
#   description = "Container username"
#   type        = string
#   default     = "jenkins"
# }

# Variables with default null value, filled depending if template or not
variable "lxc_container_ip" {
  description = "IP address CIDR format (ex : 192.168.0.1/24)"
  type        = string
  default     = null
}
variable "lxc_container_gateway" {
  description = "Default gateway IP address"
  type        = string
  default     = null
}
variable "lxc_container_dns_servers" {
  description = "DNS servers list"
  type        = list(string)
  default     = null
}
variable "lxc_container_dns_domain" {
  description = "DNS domain"
  type        = string
  default     = null
}
variable "lxc_raw_disk_path" {
  description = "lxc physical data disk path"
  type        = string
  default     = null
}
variable "lxc_container_startup_order" {
  description = "Startup order"
  type        = number
  default     = null
}
variable "lxc_container_deployment_info" {
  description = "Container Time creation, used to trigger replacement"
  type        = string
  default     = null
}

# Variables to be filled
variable "lxc_container_downloaded_file_id" {
  description = "id from the cloud_image module after resource creation"
  type        = string
}
variable "lxc_container_node_name" {
 description = "Proxmox node name on which it resides"
 type        = string
}
variable "lxc_container_hostname" {
  description = "Hostname"
  type        = string
}
variable "lxc_container_tags" {
  description = "Tags"
  type        = list(string)
}
variable "lxc_container_memory" {
  description = "Memory size in MB"
  type        = number
}
variable "lxc_container_cpu_cores" {
  description = "Number of cores"
  type        = number
}
variable "lxc_container_disk_size" {
  description = "Disk (size in GB)"
  type        = number
}
