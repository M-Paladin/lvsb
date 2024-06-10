resource "proxmox_virtual_environment_container" "this" {
  node_name     = var.lxc_container_node_name
  # start_on_boot = !var.lxc_container_is_template
  # vm_id         = var.lxc_container_is_template ? var.lxc_container_template_id : null
  tags          = var.lxc_container_tags
  # template      = var.lxc_container_is_template
  unprivileged  = true

  cpu {
    cores = var.lxc_container_cpu_cores
  }

  memory {
    dedicated = var.lxc_container_memory
  }

  console {}

  network_interface {
    bridge = "vmbr0"
    name   = "eth0"
  }

  disk {
    datastore_id = var.lxc_container_datastore_disk
    size         = var.lxc_container_disk_size
  }

  # dynamic operating_system {
  operating_system {
    # for_each = var.lxc_container_is_template ? ["container is a template"] : []

    # content {
    template_file_id = var.lxc_container_downloaded_file_id
    type = "debian"
    # }
  }

  features {
    nesting = true
  }
  # dynamic clone {
  #   for_each = var.lxc_container_is_template ? [] : [ "container is not a template" ]

  #   content {
  #     node_name = var.lxc_container_template_node_name
  #     vm_id     = var.lxc_container_template_id
  #   }
  # }

  # dynamic initialization {
  #   for_each = var.lxc_container_is_template ? ["container is a template" ] : []

  #   content {
  #     hostname = var.lxc_container_hostname
  #     # ip_config {
  #     #   ipv4 {
  #     #     address = "dhcp"
  #     #   }
  #     # }
  #     user_account {
  #       #keys = [var.lxc_container_user_sshpubkey_jenkins_agent]
  #       password = "lvsblvsb"
  #     }
  #   }
  # }

  # dynamic initialization {
  initialization {
    # for_each = var.lxc_container_is_template ? [] : [ "container is not a template" ]

    # content {
    hostname = var.lxc_container_hostname

    user_account {
      keys = [var.lxc_container_user_sshpubkey_jenkins_agent]
      password = "password"
    }

    ip_config {
      ipv4 {
        address = var.lxc_container_ip
        gateway = var.lxc_container_gateway
      }
    }
    dns {
      domain  = var.lxc_container_dns_domain
      servers = var.lxc_container_dns_servers
    }
    # }
  }

  lifecycle {
    replace_triggered_by = [ 
      terraform_data.version_date_replacement
    ]
  }
}

resource "terraform_data" "version_date_replacement" {
  # count = var.lxc_container_is_template ? 0 : 1
  # for_each = var.lxc_container_is_template ? [] : [ "container is not a template" ]
  triggers_replace = var.lxc_container_version_date
}