# terraform/scheduler.tf

# Job do Cloud Scheduler para disparar o Workflow diariamente
resource "google_cloud_scheduler_job" "workflow_trigger" {
  name             = "martech-daily-trigger"
  description      = "Gatilho diário para o orquestrador do Martech Toolkit"
  schedule         = var.scheduler_cron
  time_zone        = "America/Sao_Paulo" # Ajustado para o seu fuso
  region           = var.region
  attempt_deadline = "320s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/${google_workflows_workflow.main_workflow.id}/executions"
    
    # Corpo da requisição (vazio, pois o Workflow já tem as variáveis injetadas pelo Terraform)
    body = base64encode("{}")

    # Autenticação Segura via OIDC (OpenID Connect)
    oidc_token {
      service_account_email = google_service_account.toolkit_sa.email
      audience              = "https://workflowexecutions.googleapis.com/"
    }
  }

  depends_on = [
    google_workflows_workflow.main_workflow
  ]
}