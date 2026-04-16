# terraform/cloud_run.tf

# 1. Serviço de Extração GA4
resource "google_cloud_run_service" "ext_ga4" {
  count    = var.ga4_enable ? 1 : 0
  name     = "ext-ga4-processor"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/ext-ga4:latest" # Imagem será buildada no deploy.sh
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "DATASET_ID"
          value = google_bigquery_dataset.raw_dataset.dataset_id
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# 2. Serviço de Extração Meta Ads
resource "google_cloud_run_service" "ext_meta" {
  count    = var.meta_ads_enable ? 1 : 0
  name     = "ext-meta-processor"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/ext-meta:latest"
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "DATASET_ID"
          value = google_bigquery_dataset.raw_dataset.dataset_id
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# 3. Serviço de Extração Google Ads
resource "google_cloud_run_service" "ext_gads" {
  count    = var.google_ads_enable ? 1 : 0
  name     = "ext-gads-processor"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/ext-gads:latest"
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "DATASET_ID"
          value = google_bigquery_dataset.raw_dataset.dataset_id
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# 4. Serviço de Alerta (SMTP)
resource "google_cloud_run_service" "alert_service" {
  count    = var.alert_email_enable ? 1 : 0
  name     = "martech-alert-service"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/alert-service:latest"
        
        # Injeção das Variáveis de Ambiente para o Python
        env {
          name  = "SENDER_EMAIL"
          value = var.sender_email
        }
        env {
          name  = "RECEIVER_EMAIL"
          value = var.receiver_email
        }
        env {
          name  = "EMAIL_PASSWORD"
          value = var.email_password
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}