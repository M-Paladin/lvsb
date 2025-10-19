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
      datastore             : Datastore used for image
    }
  EOT
  type = map(object({
    node_name              = string
    content_type           = string
    img_url                = string
    img_checksum           = optional(string, null)
    img_checksum_algorythm = optional(string, null)
    img_file_name          = optional(string, null)
    datastore              = optional(string, "nfs")
  }))
}

#####################
# Virtual Templates #
#####################
variable "virtual_machine_templates" {
  description = <<-EOT
    List of templates
    Template Machine hostname = {
      node_name     : Target Proxmox node for Template Machine
      memory        : Template Machine memory amount
      cpu_cores     : Template Machine core amount
      disk_size     : Template Machine disk size (in GB)
      tags          : Template Machine tags list
      template_id   : Template Machine id
      datastore_disk: Storage used for VM disk
      cloud_image   : Image used to create the template
    }
  EOT
  type = map(object({
    node_name      = string
    memory         = number
    cpu_cores      = optional(number, 2)
    disk_size      = number
    tags           = list(string)
    template_id    = number
    datastore_disk = optional(string, "cephstorage")
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
      node_name            : Target Proxmox node for Virtual Machine
      memory               : Virtual Machine memory amount
      cpu_cores            : Virtual Machine core amount
      disk_size            : Virtual Machine disk size (in GB)
      datastore_disk       : Storage used for VM disk
      tags                 : Virtual Machine tags list
      vm-template          : Template Machine used
      ip                   : IP address CIDR format (ex : 192.168.0.1/24)
      gateway              : Gateway IP address (ex : 192.168.0.1)
      dns_servers          : DNS servers to use
      dns_domain           : DNS domain to use
      CI_datastore_snippets: Storage used for Cloud-Init disk
      CI_template-file     : Template file used to create cloud-init
      CI_user_name         : User created during cloud-init
      CI_deployment_info   : When this information changes the machine will be recreated
      # raw_disk_path        : Dev path for the disk (used for passthrough)
    }
  EOT
  type = map(object({
    node_name             = string
    memory                = number
    cpu_cores             = optional(number, 2)
    disk_size             = number
    datastore_disk        = optional(string, "cephstorage")
    tags                  = list(string)
    vm-template           = string
    ip                    = string
    gateway               = optional(string, "192.168.0.1")
    dns_servers           = optional(list(string), ["192.168.0.3"])
    dns_domain            = optional(string, "maison.lvsb.fr")
    CI_datastore_snippets = optional(string, "nfs")
    CI_template-file      = string
    CI_user_name          = optional(string, "ansible")
    CI_deployment_info    = string
    # raw_disk_path         = optional(string, null)
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
      node_name      : Target Proxmox node for Container
      memory         : Container memory amount
      cpu_cores      : Container core amount
      disk_size      : Container disk size (in GB)
      datastore_disk : Storage used for container disk
      raw_disk_path  : Dev path for the disk (used for passthrough)
      tags           : Container tags list
      ip             : IP address CIDR format (ex : 192.168.0.1/24)
      gateway        : Gateway IP address (ex : 192.168.0.1)
      dns_servers    : DNS servers to use
      dns_domain     : DNS domain to use
      cloud_image    : Image used to create the container from cloud_images list
      cloud_image_id : Image ID used to create the container (storage:type/image_name)
      unpriviledged  : is container unpriviledged
      startup_order  : Container startup order
      deployment_info: When this information changes the container will be recreated
    }
  EOT
  type = map(object({
    node_name                 = string
    memory                    = number
    cpu_cores                 = optional(number, 2)
    disk_size                 = number
    datastore_disk            = optional(string, "cephstorage")
    raw_disk_path             = optional(string, null)
    tags                      = list(string)
    ip                        = string
    gateway                   = optional(string, "192.168.0.1")
    dns_servers               = optional(list(string), ["192.168.0.3"])
    dns_domain                = optional(string, "maison.lvsb.fr")
    cloud_image               = string
    cloud_image_id            = string
    unpriviledged             = optional(bool, true)
    startup_order             = optional(number, null)
    deployment_info           = string
  }))
}

variable "jenkins_agent_ansible_user_sshpubkey" {
  description = "public ssh key to be accessed from ansible"
  type        = string
}

