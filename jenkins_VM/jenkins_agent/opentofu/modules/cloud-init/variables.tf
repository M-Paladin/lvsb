# Variables with default value
variable "cloud-init_datastore_snippets" {
  description = "Proxmox datastore for snippets (hookscript such as cloud-init)"
  type        = string
  default     = "local"
}
variable "cloud-init_dns_domain" {
  description = "VM dns domain"
  type        = string
  default     = "maison.lvsb.fr"
}
variable "cloud-init_user_sshpubkey_ansible" {
  description = "public ssh key to be accessed from ansible"
  type        = string
  default     = "AAAAB3NzaC1yc2EAAAADAQABAAABgQC34EtA66CnvOo1LwlnBX98qxEqtkCzWwUOMkgqIC1kdVfQeOJyR9EcnfAwZiPZ940PWG/6nAzybYKNe1YgSKb/MVKRV0CKtb55hSatgBerK9vV0BByZSai3ILbSLsXHMbu2lh3spQAXi2SDroBPNITfeAWCS3BW6+dmuRErL93V5tkkWCF8MKzmQd6ev/C4xZs9H61TboeSjbaH+31eiPtOJmZ4qn4fGfgM6W6uHl1BvPLKEWlCUQ38i+4+TObwrjxxlRMzm80e+IQj7PG/6Ry9iWyUrU5ePi3hlwMBEI4KyxB1W/h5Ie3iLT3ug/H6+zgOT0qNzVXSgGro9xL8GkFSU9bNJpeCZuPwFflMivF56XeGFLQoKUkb1UBkpeChdz7pHUcUrO3cWsWXdFPdj/tskLEuA8zGLF6xvtFkFfKzX7vzGo8MYx1A2lvThi01syuIyUtUSrfONt6dImwOeqB7Xc7VXc8fAQFczjDlU+rFst3Wmx1ddNI4kaUyYkyZE0= jenkins_agent_ansible"
}
variable "cloud-init_user_name" {
  description = "VM username"
  type        = string
  default     = "jenkins"
}

# Variables to be filled
variable "cloud-init_node_name" {
 description = "Proxmox node"
 type        = string
}
variable "cloud-init_hostname" {
  description = "VM hostname"
  type        = string
}
variable "cloud-init_vm_version_date" {
  description = "string used to retrigger deployment for upgrade"
  type        = string
}