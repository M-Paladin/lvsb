variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox Virtual Environment API Endpoint (example: https://host:port)"
  default     = "https://my_ip:8006"
}

variable "proxmox_username" {
  type        = string
  description = "Proxmox Virtual Environment API name and realm (example: root@pam)"
  default     = "root@pam"
}

variable "proxmox_password" {
  type        = string
  description = "Proxmox Virtual Environment API password corresponding to proxmox_username"
  default     = "mypassword"
}

variable "proxmox_api_token" {
  type        = string
  description = "Proxmox Virtual Environment API token (example: USER@REALM!TOKENID=UUID)"
  default     = "root@pam!terraform=token_uuid"
}

variable "proxmox_nodes" {
  type        = map(string)
  description = "Proxmox Virtual Environment nodes and IPs"
}
