resource "proxmox_virtual_environment_vm" "this" {
  name       = "${var.virtual_machine_hostname}.${var.virtual_machine_dns_domain}"
  node_name  = var.virtual_machine_node_name
  boot_order = ["scsi0"]
  on_boot    = !var.virtual_machine_is_template
  vm_id      = var.virtual_machine_is_template ? var.virtual_machine_template_id : null
  tags       = var.virtual_machine_tags
  template   = var.virtual_machine_is_template

  cpu {
    architecture = "x86_64"
    type  = "x86-64-v2-AES"
    cores = var.virtual_machine_cpu_cores
  }

  memory {
    dedicated = var.virtual_machine_memory
  }

  agent {
    enabled = !var.virtual_machine_is_template
  }

  network_device {
    bridge      = "vmbr0"
    queues      = var.virtual_machine_cpu_cores
  }

  scsi_hardware = "virtio-scsi-single"
  disk {
    datastore_id = var.virtual_machine_datastore_disk
    file_id      = var.virtual_machine_is_template ? var.virtual_machine_downloaded_file_id : null
    interface    = "scsi0"
    size         = var.virtual_machine_disk_size
    discard      = "on"
    ssd          = true
    iothread     = true
  }

  # Direct attached Data disk
  dynamic "disk" {
    for_each = coalesce(var.virtual_machine_raw_disk_path,"no_disk") == "no_disk" ? [] : [ "vm is a NAS"  ]

    content {
      datastore_id      = ""
      path_in_datastore = var.virtual_machine_raw_disk_path
      file_format       = "raw"
      interface         = "scsi1"
      size              = "16764"
    }
  }

  serial_device {} # The Debian cloud image expects a serial port to be present

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  dynamic clone {
    for_each = var.virtual_machine_is_template ? [] : [ "vm is not a template" ]

    content {
      node_name = var.virtual_machine_template_node_name
      vm_id     = var.virtual_machine_template_id
    }
  }

  dynamic initialization {
    for_each = var.virtual_machine_is_template ? [] : [ "vm is not a template" ]

    content {
      datastore_id       = var.virtual_machine_datastore_disk
      user_data_file_id  = var.virtual_machine_config_file_id
      ip_config {
        ipv4 {
          address = var.virtual_machine_ip
          gateway = var.virtual_machine_gateway
        }
      }
      dns {
        domain  = var.virtual_machine_dns_domain
        servers = var.virtual_machine_dns_servers
      }
    }
  }
}
