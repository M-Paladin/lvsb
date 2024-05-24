variable "virtual_machines" {
  description = <<-EOT
    List of virtual machines
    hostname: Virtual Machine hostname
    {
      node_name   : Target Proxmox node for Virtual Machine
      memory      : Virtual Machine memory amount
      disk_size   : Virtual Machine disk size (in GB)
      tags        : Virtual Machine tags list
      template_id : Template id for Virtual Machine
      ip          : IP address CIDR format (ex : 192.168.0.1/24)
      version_date: When this information changes the machine will be recreated
    }
  EOT
  type = map(object({
    node_name      = string
    memory         = number
    disk_size      = number
    tags           = list(string)
    template_id    = number
    ip             = string
    version_date   = string
    datastore_disk = string
    raw_disk_path  = optional(string, null)
  }))
}
variable "templates" {
  description = <<-EOT
    List of templates
    hostname: Virtual Machine hostname
    {
      node_name             : Target Proxmox node for Template Machine
      memory                : Template Machine memory amount
      disk_size             : Template Machine disk size (in GB)
      tags                  : Template Machine tags list
      template_id           : Template Machine id
      img_url               : Linux Cloud Image URL
      img_checksum          : Linux Cloud Image checksum
      img_file_name         : Linux Cloud Image checksum algorythm
      img_checksum_algorythm: Linux Cloud Image target file name
    }
  EOT
  type = map(object({
    node_name              = string
    memory                 = number
    disk_size              = number
    tags                   = list(string)
    template_id            = number
    img_url                = string
    img_checksum           = string
    img_file_name          = string
    img_checksum_algorythm = string
    datastore_disk         = string
  }))
}
