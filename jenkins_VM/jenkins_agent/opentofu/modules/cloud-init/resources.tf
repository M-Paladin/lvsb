resource "proxmox_virtual_environment_file" "this" {
  content_type = "snippets"
  datastore_id = var.cloud-init_datastore_snippets
  node_name = var.cloud-init_node_name

  source_raw {
    # local file in the same directory
    # data = file("cloud-init/user_data")
    data = templatefile("./modules/cloud-init/template/user-data.yaml",
      {
        hostname                = var.cloud-init_hostname
        dns_domain              = var.cloud-init_dns_domain
        username                = var.cloud-init_user_name
        sshpubkey_jenkins_agent = var.cloud-init_user_sshpubkey_jenkins_agent
        vm_version_date         = var.cloud-init_vm_version_date
      }
    )
    file_name = "${var.cloud-init_hostname}.${var.cloud-init_dns_domain}_CI_user-data.yaml"
  }
}
