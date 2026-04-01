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

  initialization {
    datastore_id = "airbus-LUN1"

    dns {
      servers = ["10.100.11.254"]
    }

    ip_config {
      ipv4 {
        address = "10.100.11.${230 + count.index}/24"
        gateway = "10.100.11.254"
      }
    }

    user_account {
      username = var.vm_user
      password = var.vm_password
    }
  }
}

# ─── Installer Docker sur les 3 VMs (via bastion) ───
resource "null_resource" "install_docker" {
  count      = 3
  depends_on = [proxmox_virtual_environment_vm.nebula]

  connection {
    type     = "ssh"
    user     = var.vm_user
    password = var.vm_password
    host     = "10.100.11.${230 + count.index}"
    timeout  = "10m"

    bastion_host     = var.bastion_host
    bastion_port     = var.bastion_port
    bastion_user     = var.vm_user
    bastion_password = var.vm_password
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf",
      "sudo apt-get update -y",
      "curl -fsSL https://get.docker.com | sh",
      "sudo usermod -aG docker ${var.vm_user}",
      "sudo apt-get install -y sshpass"
    ]
  }
}

# ─── Init Swarm sur VM1 après installation Docker ───
resource "null_resource" "swarm_init" {
  depends_on = [null_resource.install_docker]

  connection {
    type     = "ssh"
    user     = var.vm_user
    password = var.vm_password
    host     = "10.100.11.230"
    timeout  = "5m"

    bastion_host     = var.bastion_host
    bastion_port     = var.bastion_port
    bastion_user     = var.vm_user
    bastion_password = var.vm_password
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker swarm init --advertise-addr 10.100.11.230 2>/dev/null || echo 'Swarm already initialized'"
    ]
  }
}

# ─── Joindre les 2 workers au Swarm depuis le manager ───
resource "null_resource" "swarm_join" {
  depends_on = [null_resource.swarm_init]

  connection {
    type     = "ssh"
    user     = var.vm_user
    password = var.vm_password
    host     = "10.100.11.230"
    timeout  = "5m"

    bastion_host     = var.bastion_host
    bastion_port     = var.bastion_port
    bastion_user     = var.vm_user
    bastion_password = var.vm_password
  }

  provisioner "remote-exec" {
    inline = [
      "TOKEN=$(sudo docker swarm join-token -q worker)",
      "sshpass -p '${var.vm_password}' ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 ${var.vm_user}@10.100.11.231 \"sudo docker swarm join --token $TOKEN 10.100.11.230:2377\" 2>/dev/null || echo 'Worker1 already joined or unreachable'",
      "sshpass -p '${var.vm_password}' ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 ${var.vm_user}@10.100.11.232 \"sudo docker swarm join --token $TOKEN 10.100.11.230:2377\" 2>/dev/null || echo 'Worker2 already joined or unreachable'"
    ]
  }
}

# ─── Créer les secrets et déployer le stack ───
resource "null_resource" "deploy_stack" {
  depends_on = [null_resource.swarm_join]

  connection {
    type     = "ssh"
    user     = var.vm_user
    password = var.vm_password
    host     = "10.100.11.230"
    timeout  = "5m"

    bastion_host     = var.bastion_host
    bastion_port     = var.bastion_port
    bastion_user     = var.vm_user
    bastion_password = var.vm_password
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'nameserver 8.8.8.8' | sudo tee /etc/resolv.conf",
      "sudo apt-get install -y git",
      "echo '${var.db_password}' | sudo docker secret create db_password - 2>/dev/null || true",
      "echo 'postgresql://nebula:${var.db_password}@postgres:5432/nebula' | sudo docker secret create db_url - 2>/dev/null || true",
      "echo '${var.rabbitmq_password}' | sudo docker secret create rabbitmq_password - 2>/dev/null || true",
      "echo '${var.minio_access_key}' | sudo docker secret create minio_access_key - 2>/dev/null || true",
      "echo '${var.minio_secret_key}' | sudo docker secret create minio_secret_key - 2>/dev/null || true",
      "rm -rf /tmp/esgi-docker-swarm",
      "cd /tmp && git clone https://github.com/axel-po/esgi-docker-swarm.git",
      "cd /tmp/esgi-docker-swarm && cp infra/swarm/docker-stack.yml . && sudo docker stack deploy -c docker-stack.yml nebula"
    ]
  }
}
