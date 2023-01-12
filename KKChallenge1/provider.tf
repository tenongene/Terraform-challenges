terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }

    aws = {
      source = "hashicorp/aws"
      version = "4.49.0"
    }
  }

  backend "s3" {
    bucket = "tenon-remote-backend"
    key = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "tenon_state_locking"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
  # config_path    = "/root/.kube/config"
  # config_context = "kubernetes@kubernetes_admin"
}

provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "iamadmin-general"
}



##Service 
resource "kubernetes_service" "webapp-service" {
  metadata {
    name = "webapp-service"
  }
  spec {
    selector = {
      name = "webapp"
    }
    port {
      port = 8080
      node_port = 30080
    }
    type = "NodePort"
  }
}

## Deployment 

resource "kubernetes_deployment_v1" "frontend" {
  metadata {
    name = "frontend"
    labels = {
      name = "frontend"
    }
  }

  spec {
    replicas = 4

    selector {
      match_labels = {
        name = "webapp"
      }
    }

    template {
      metadata {
        labels = {
          name = "webapp"
        }
      }

      spec {
        container {
          image = "kodekloud/webapp-color:v1"
          name  = "simple-webapp"
          port {
            container_port = 8080
            protocol = "TCP"
          }
        }
      }
    }
  }
}