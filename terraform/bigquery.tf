# terraform/bigquery.tf

# Dataset RAW: Onde os Cloud Runs de extração depositam os dados do Drive
resource "google_bigquery_dataset" "raw_dataset" {
  dataset_id                  = "RAW"
  friendly_name               = "Camada Raw"
  description                 = "Camada de ingestão de dados brutos (GA4, Meta, GAds)"
  location                    = var.region
  delete_contents_on_destroy = false

  labels = {
    env   = "prod"
    layer = "raw"
  }
}

# Dataset SILVER: Onde o Dataform processa a limpeza e dimensões
resource "google_bigquery_dataset" "silver_dataset" {
  dataset_id                  = "TRUSTED"
  friendly_name               = "Camada Trusted"
  description                 = "Camada de dados limpos, unnest e deduplicados"
  location                    = var.region
  delete_contents_on_destroy = false

  labels = {
    env   = "prod"
    layer = "silver"
  }
}

# Dataset GOLD: Onde residem as tabelas finais de performance e dashboards
resource "google_bigquery_dataset" "gold_dataset" {
  dataset_id                  = "REFINED"
  friendly_name               = "Camada Refined"
  description                 = "Camada de dados refinados e prontos para visualização"
  location                    = var.region
  delete_contents_on_destroy = false

  labels = {
    env   = "prod"
    layer = "gold"
  }
}