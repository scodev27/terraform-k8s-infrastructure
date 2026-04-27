variable "docker_username" {
  description = "Usuari de Docker Hub"
  type        = string
  default     = "scodev27" 
}

variable "app_port" {
  description = "Port de l'aplicació backend"
  type        = string
  default     = "8080"
}
