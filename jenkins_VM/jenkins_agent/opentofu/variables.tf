################
# Cloud Images #
################
variable "cloud_images" {
  description = <<-EOT
    List of cloud images
    Cloud Image Name = {
      node_name             : Target Proxmox node for Template Machine
      content_type          : Content type (iso or vztmpl)
      img_url               : Linux Cloud Image URL
      img_checksum          : Linux Cloud Image checksum
      img_checksum_algorythm: Linux Cloud Image checksum algorythm
      img_file_name         : Linux Cloud Image target file name
    }
  EOT
  type = map(object({
    node_name              = string
    content_type           = string
    img_url                = string
    img_checksum           = optional(string, null)
    img_checksum_algorythm = optional(string, null)
    img_file_name          = optional(string, null)
  }))
}

#####################
# Virtual Templates #
#####################
variable "virtual_machine_templates" {
  description = <<-EOT
    List of templates
    Template Machine hostname = {
      node_name             : Target Proxmox node for Template Machine
      memory                : Template Machine memory amount
      disk_size             : Template Machine disk size (in GB)
      tags                  : Template Machine tags list
      template_id           : Template Machine id
      datastore_disk        : Storage used for VM disk
      cloud_image           : Image used to create the template
    }
  EOT
  type = map(object({
    node_name      = string
    memory         = number
    disk_size      = number
    tags           = list(string)
    template_id    = number
    datastore_disk = string
    cloud_image    = string
  }))
}

####################
# Virtual Machines #
####################
variable "virtual_machines" {
  description = <<-EOT
    List of virtual machines
    Virtual Machine hostname = {
      node_name     : Target Proxmox node for Virtual Machine
      memory        : Virtual Machine memory amount
      disk_size     : Virtual Machine disk size (in GB)
      tags          : Virtual Machine tags list
      template_id   : Template id for Virtual Machine
      ip            : IP address CIDR format (ex : 192.168.0.1/24)
      version_date  : When this information changes the machine will be recreated
      datastore_disk: Storage used for VM disk
      raw_disk_path : Dev path for the disk (used for passthrough)
      datastore_snippets : Storage used for Cloud-Init disk
      dns_servers   : DNS servers to use
      #disk_serial   : Serial number of above disk
    }
  EOT
  type = map(object({
    node_name          = string
    memory             = number
    disk_size          = number
    tags               = list(string)
    template_id        = number
    ip                 = string
    version_date       = string
    datastore_disk     = string
    raw_disk_path      = optional(string, null)
    datastore_snippets = optional(string, "local")
    dns_servers        = optional(list(string), ["192.168.0.3"])
    #disk_serial       = optional(string, null)
  }))
}

##################
# LXC Containers #
##################
variable "lxc_containers" {
  description = <<-EOT
    List of containers
    hostname: Container hostname
    {
      node_name     : Target Proxmox node for Container
      memory        : Container memory amount
      disk_size     : Container disk size (in GB)
      tags          : Container tags list
      ip            : IP address CIDR format (ex : 192.168.0.1/24)
      version_date  : When this information changes the machine will be recreated
      datastore_disk: Storage used for container disk
      cloud_image_id: Image ID used to create the container (storage:type/image_name)
      raw_disk_path : Dev path for the disk (used for passthrough)
      unpriviledged : is container unpriviledged
    }
  EOT
  type = map(object({
    node_name      = string
    memory         = number
    disk_size      = number
    tags           = list(string)
    ip             = string
    version_date   = string
    datastore_disk = string
    cloud_image_id = string
    raw_disk_path  = optional(string, null)
    unpriviledged  = optional(bool, true)
  }))
}


