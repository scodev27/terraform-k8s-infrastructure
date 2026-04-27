terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Configura Terraform per connectar-se al teu Minikube local
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# 1. El ConfigMap
resource "kubernetes_config_map" "app_config" {
  metadata {
    name = "app-config"
  }
  data = {
    APP_PORT = var.app_port
  }
}

# 2. El Backend (Deployment + Service)
resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend-deployment"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "backend"
        }
      }
      spec {
        container {
          name  = "backend"
          image = "${var.docker_username}/backend-gsx:v1"
          port {
            container_port = 8080
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_config.metadata[0].name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name = "backend"
  }
  spec {
    selector = {
      app = "backend"
    }
    port {
      port        = 8080
      target_port = 8080
    }
  }
}

# 3. L'Nginx (Deployment + Service)
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-deployment"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
          name  = "nginx"
          image = "${var.docker_username}/nginx-gsx:v1"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-service"
  }
  spec {
    selector = {
      app = "nginx"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "NodePort"
  }
}
