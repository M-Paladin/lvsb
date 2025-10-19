output "virtual_machine_template_id" {
  value = proxmox_virtual_environment_vm.this.vm_id
}

output "virtual_machine_template_node_name" {
  value = proxmox_virtual_environment_vm.this.node_name
}