resource "proxmox_virtual_environment_container" "this" {
  node_name     = var.lxc_container_node_name
  tags          = var.lxc_container_tags
  unprivileged  = var.lxc_container_is_unpriviledged

  startup {
    order = var.lxc_container_startup_order
  }

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

  # to be enhanced
  dynamic mount_point {
    for_each = coalesce(var.lxc_raw_disk_path,"no_disk") == "no_disk" ? [] : [ "vm is a NAS" ]

    content {
      # bind mount, *requires* root@pam authentication
      volume = var.lxc_raw_disk_path
      path   = "/srv/datadisk"
    }
  }

  # nfs server test syncthing
  # started = var.lxc_container_hostname == "nfs-server-test" ? false : true
  # dynamic mount_point {
  #   for_each = var.lxc_container_hostname == "nfs-server-test" ? [ "vm is testing" ] : []

  #   content {
  #     volume = "local-lvm"
  #     size   = "1G"
  #     path   = "/mnt/synthing_database"
  #   }
  # }

  operating_system {
    template_file_id = var.lxc_container_downloaded_file_id
    type = "debian"
  }

  features {
    nesting = true
    mount = ["nfs"]
  }

  initialization {
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
  }

  lifecycle {
    replace_triggered_by = [ 
      terraform_data.version_date_replacement
    ]
  }
}

resource "terraform_data" "version_date_replacement" {
  triggers_replace = var.lxc_container_version_date
}