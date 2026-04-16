# terraform/workflow.tf

# Definição do Cloud Workflow
resource "google_workflows_workflow" "main_workflow" {
  name            = "martech-toolkit-orchestrator"
  region          = var.region
  description     = "Orquestrador principal: Extração -> Dataform -> Alerta"
  service_account = google_service_account.toolkit_sa.id

  # O código do workflow será lido de um arquivo YAML externo
  source_contents = templatefile("${path.module}/../workflows/main_orchestrator.yaml", {
    # Injetamos as variáveis e URLs para que o Workflow seja dinâmico
    project_id         = var.project_id
    location           = var.region
    ga4_enable         = var.ga4_enable
    meta_enable        = var.meta_ads_enable
    gads_enable        = var.google_ads_enable
    alert_enable       = var.alert_email_enable
    
    # Passamos as URLs apenas se os serviços existirem (usando sintaxe de lista para evitar erro se count=0)
    url_ext_ga4   = var.ga4_enable ? google_cloud_run_service.ext_ga4[0].status[0].url : ""
    url_ext_meta  = var.meta_ads_enable ? google_cloud_run_service.ext_meta[0].status[0].url : ""
    url_ext_gads  = var.google_ads_enable ? google_cloud_run_service.ext_gads[0].status[0].url : ""
    url_alert     = var.alert_email_enable ? google_cloud_run_service.alert_service[0].status[0].url : ""
    
    # Nome do Repositório Dataform para a compilação dinâmica
    dataform_repo_id = google_dataform_repository.martech_repository.name
  })

  depends_on = [
    google_cloud_run_service.ext_ga4,
    google_cloud_run_service.ext_meta,
    google_cloud_run_service.ext_gads,
    google_cloud_run_service.alert_service,
    google_dataform_repository.martech_repository
  ]
}