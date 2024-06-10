resource "proxmox_virtual_environment_download_file" "this" {
  content_type       = var.cloud_image_content_type
  datastore_id       = var.cloud_image_datastore_image
  file_name          = var.cloud_image_file_name
  node_name          = var.cloud_image_node_name
  url                = var.cloud_image_url
  checksum           = var.cloud_image_checksum
  checksum_algorithm = var.cloud_image_checksum_algorythm
  overwrite          = "true"
}
