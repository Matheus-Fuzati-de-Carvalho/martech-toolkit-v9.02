# terraform/iam.tf

# 1. Criação da Service Account principal do Martech Toolkit
resource "google_service_account" "toolkit_sa" {
  account_id   = "martech-toolkit-sa"
  display_name = "Service Account para Orquestração e Extração Martech"
}

# 2. Permissão para a SA escrever no BigQuery (Datasets Raw, Silver e Gold)
resource "google_bigquery_dataset_iam_member" "bq_editor_raw" {
  dataset_id = google_bigquery_dataset.raw_dataset.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.toolkit_sa.email}"
}

resource "google_bigquery_dataset_iam_member" "bq_editor_silver" {
  dataset_id = google_bigquery_dataset.silver_dataset.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.toolkit_sa.email}"
}

resource "google_bigquery_dataset_iam_member" "bq_editor_gold" {
  dataset_id = google_bigquery_dataset.gold_dataset.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.toolkit_sa.email}"
}

# 3. Permissão para o Workflow invocar os serviços do Cloud Run
# Aplicamos isso apenas se o serviço for criado (usando o mesmo count das flags)
resource "google_cloud_run_service_iam_member" "workflow_invokes_ga4" {
  count    = var.ga4_enable ? 1 : 0
  location = google_cloud_run_service.ext_ga4[0].location
  service  = google_cloud_run_service.ext_ga4[0].name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.toolkit_sa.email}"
}

resource "google_cloud_run_service_iam_member" "workflow_invokes_meta" {
  count    = var.meta_ads_enable ? 1 : 0
  location = google_cloud_run_service.ext_meta[0].location
  service  = google_cloud_run_service.ext_meta[0].name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.toolkit_sa.email}"
}

# 4. Permissão para o Dataform acessar o Secret Manager (Token do GitHub)
resource "google_secret_manager_secret_iam_member" "dataform_secret_access" {
  secret_id = google_secret_manager_secret.github_token.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dataform.iam.gserviceaccount.com"
}

# 5. Permissão de Job User no BigQuery para a SA conseguir rodar Queries
resource "google_project_iam_member" "toolkit_bq_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.toolkit_sa.email}"
}