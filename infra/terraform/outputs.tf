output "vm_ips" {
  value = [for i in range(3) : "10.100.11.${230 + i}"]
  description = "IPs des 3 VMs"
}

output "manager_ip" {
  value       = "10.100.11.230"
  description = "IP du manager (VM1)"
}

output "instructions" {
  value = <<-EOT

    === 3 VMs créées ! ===

    Manager : 10.100.11.230
    Worker1 : 10.100.11.231
    Worker2 : 10.100.11.232

    1. Récupère le token Swarm sur le manager :
       ssh etudiant@10.100.11.230
       docker swarm join-token worker

    2. Rejoins le cluster sur les 2 workers :
       ssh etudiant@10.100.11.231
       docker swarm join --token TOKEN 10.100.11.230:2377

       ssh etudiant@10.100.11.232
       docker swarm join --token TOKEN 10.100.11.230:2377

    3. Déploie Nebula depuis le manager :
       docker stack deploy -c docker-stack.yml nebula
  EOT
}
