# ──────────────────────────────────────────────
# Variables
# ──────────────────────────────────────────────

variable "proxmox_url" {
  description = "URL de l'API Proxmox (ex: https://10.255.0.221:8006/)"
  type        = string
}

variable "proxmox_token" {
  description = "Token API Proxmox (ex: user@pve!token=secret)"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Nom du noeud Proxmox cible"
  type        = string
}

variable "proxmox_pool" {
  description = "Pool Proxmox personnel"
  type        = string
}

variable "template_vmid" {
  description = "VMID du template VM à cloner"
  type        = number
}

variable "vnet" {
  description = "Nom du VNet VXLAN (ex: vn00011)"
  type        = string
}

variable "vm_user" {
  description = "Utilisateur SSH des VMs"
  type        = string
  default     = "etudiant"
}

variable "vm_password" {
  description = "Mot de passe SSH des VMs"
  type        = string
  sensitive   = true
  default     = "etudiant"
}

variable "db_password" {
  description = "Mot de passe PostgreSQL"
  type        = string
  sensitive   = true
}

variable "rabbitmq_password" {
  description = "Mot de passe RabbitMQ"
  type        = string
  sensitive   = true
}

variable "minio_access_key" {
  description = "Clé accès MinIO"
  type        = string
  sensitive   = true
}

variable "minio_secret_key" {
  description = "Clé secrète MinIO"
  type        = string
  sensitive   = true
}

variable "bastion_host" {
  description = "IP du bastion pour atteindre le réseau interne"
  type        = string
  default     = "10.210.0.11"
}

variable "bastion_port" {
  description = "Port SSH du bastion (port forwarding OpenWrt)"
  type        = number
  default     = 2221
}
