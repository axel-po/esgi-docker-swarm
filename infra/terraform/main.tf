# ──────────────────────────────────────────────
# Nebula — Terraform Proxmox (bpg/proxmox)
# Crée 3 VMs pour le cluster Docker Swarm
# ──────────────────────────────────────────────

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_url
  api_token = var.proxmox_token
  insecure  = true
}

# ─── 3 VMs identiques ───
resource "proxmox_virtual_environment_vm" "nebula" {
  count     = 3
  name      = "nebula-vm${count.index + 1}"
  node_name = var.proxmox_node
  pool_id   = var.proxmox_pool

  clone {
    vm_id = var.template_vmid
    full  = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = var.vnet
    model  = "virtio"
  }
}

# ─── Init Swarm sur VM1 après création des 3 VMs ───
resource "null_resource" "swarm_init" {
  depends_on = [proxmox_virtual_environment_vm.nebula]

  connection {
    type     = "ssh"
    user     = var.vm_user
    password = var.vm_password
    host     = "10.100.11.230"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker swarm init --advertise-addr 10.100.11.230"
    ]
  }
}
