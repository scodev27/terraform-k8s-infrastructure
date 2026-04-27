output "nginx_node_port" {
  description = "El port per accedir a l'Nginx des de fora"
  value       = kubernetes_service.nginx.spec[0].port[0].node_port
}
