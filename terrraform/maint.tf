# terraform/main.tf

# Configuração do Terraform e Provedores
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }
}

# Provedor Google padrão
provider "google" {
  project = var.project_id
  region  = var.region
}

# Provedor Google Beta (necessário para alguns recursos específicos do Dataform/Workflows)
provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Ativação das APIs necessárias no projeto
resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "bigquery.googleapis.com",
    "dataform.googleapis.com",
    "workflows.googleapis.com",
    "run.googleapis.com",
    "cloudscheduler.googleapis.com",
    "iam.googleapis.com",
    "pubsub.googleapis.com",
    "eventarc.googleapis.com"
  ])

  service = each.key

  # Não desativa as APIs ao destruir o Terraform para evitar interrupções em outros serviços do projeto
  disable_on_destroy = false
}

# Dados sobre o projeto atual (útil para referenciar o número do projeto)
data "google_project" "project" {}