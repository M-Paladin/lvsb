# Variables with default value
variable "cloud_image_datastore_image" {
  description = "Proxmox datastore for images"
  type        = string
  default     = "local"
}

# Variables to be filled
variable "cloud_image_content_type" {
  description = "Image type"
  type        = string
}
variable "cloud_image_node_name" {
 description = "Proxmox node"
 type        = string
}
variable "cloud_image_url" {
  description = "Linux Cloud Image URL"
  type        = string
}
variable "cloud_image_checksum" {
  description = "Linux Cloud Image checksum"
  type        = string
  default     = null
}
variable "cloud_image_checksum_algorythm" {
  description = "Linux Cloud Image checksum algorythm"
  type        = string
  default     = null
}
variable "cloud_image_file_name" {
  description = "Linux Cloud Image target file name"
  type        = string
  default     = null
}
