# 1. Bucket para armazenar os arquivos ZIP
resource "google_storage_bucket" "source_bucket" {
  name                        = "${var.project_id}-functions-source"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
}

# 2. Configuração Genérica para os Módulos (GA4, Meta, Google, Alerta)
locals {
  modules = {
    "ga4"    = { enable = var.ga4_enable, src = "../cloud_run/ext_ga4" }
    "meta"   = { enable = var.meta_ads_enable, src = "../cloud_run/ext_meta_ads" }
    "google" = { enable = var.google_ads_enable, src = "../cloud_run/ext_google_ads" }
    "alert"  = { enable = var.alert_email_enable, src = "../cloud_run/alert_service" }
  }
}

# 3. Gerar o ZIP de cada pasta de código
data "archive_file" "source_zip" {
  for_each    = { for k, v in locals.modules : k => v if v.enable }
  type        = "zip"
  source_dir  = each.value.src
  output_path = "${path.module}/files/${each.key}.zip"
}

# 4. Upload do ZIP para o Google Cloud Storage
resource "google_storage_bucket_object" "zip_upload" {
  for_each = data.archive_file.source_zip
  name     = "${each.key}-${each.value.output_sha}.zip"
  bucket   = google_storage_bucket.source_bucket.name
  source   = each.value.output_path
}

# 5. Criação das Cloud Functions (v1 - Padrão Simples)
resource "google_cloudfunctions_function" "functions" {
  for_each    = { for k, v in locals.modules : k => v if v.enable }
  name        = "ext-${each.key}"
  description = "Modulo de extracao ${each.key} - v9.01 Style"
  runtime     = "python311"

  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.source_bucket.name
  source_archive_object = google_storage_bucket_object.zip_upload[each.key].name
  trigger_http          = true
  entry_point           = "main" # Nome da função no main.py
  timeout               = 540    # 9 minutos (limite da function)

  environment_variables = {
    PROJECT_ID     = var.project_id
    SENDER_EMAIL   = var.sender_email
    RECEIVER_EMAIL = var.receiver_email
    EMAIL_PASSWORD = var.email_password
  }
}

# 6. Permissão Pública (Para o Workflow conseguir chamar a Function)
resource "google_cloudfunctions_function_iam_member" "invoker" {
  for_each       = google_cloudfunctions_function.functions
  project        = var.project_id
  region         = var.region
  cloud_function = each.value.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}