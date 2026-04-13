terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Módulo 1: Extração (Cria o BQ Data Transfer e/ou Cloud Runs)
module "extraction" {
  source = "./modules/extraction"
  
  project_id          = var.project_id
  region              = var.region
  dataset_bronze_name = var.dataset_bronze_name
  
  enable_ga4        = var.enable_ga4
  table_raw_ga4     = var.table_raw_ga4
  
  enable_meta_ads   = var.enable_meta_ads
  table_raw_meta    = var.table_raw_meta
  
  enable_google_ads = var.enable_google_ads
  table_raw_ads     = var.table_raw_ads
}

# Módulo 2: Transformação (Provisiona o repositório Dataform)
module "transformation" {
  source     = "./modules/transformation"
  project_id = var.project_id
  region     = var.region
}

# Módulo 3: Orquestração (Workflow + Scheduler + Alertas)
module "orchestration" {
  source = "./modules/orchestration"
  
  project_id         = var.project_id
  region             = var.region
  cron_schedule      = var.cron_schedule
  enable_error_alert = var.enable_error_alert
  
  # Passamos o status das flags para o Workflow saber quais etapas invocar no Dataform
  active_extractors = {
    ga4        = var.enable_ga4
    meta_ads   = var.enable_meta_ads
    google_ads = var.enable_google_ads
  }
}