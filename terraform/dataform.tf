# terraform/dataform.tf

# Criação do Repositório do Dataform
resource "google_dataform_repository" "martech_repository" {
  provider = google-beta
  name     = "martech-toolkit-repo"
  region   = var.region

  # Configuração do Git (Conexão com seu GitHub)
  git_remote_settings {
    url                                = var.github_repo_url
    default_branch                     = "main"
    authentication_token_secret_version = google_secret_manager_secret_version.github_token_version.id
  }

  # Link para o Workspace (opcional no provisionamento, mas útil para o ambiente)
  workspace_compilation_overrides {
    default_database = var.project_id
  }

  depends_on = [
    google_project_service.services,
    google_secret_manager_secret_version.github_token_version
  ]
}

# Secret Manager para armazenar o Token do GitHub com segurança
resource "google_secret_manager_secret" "github_token" {
  secret_id = "dataform-github-token"
  
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "github_token_version" {
  secret    = google_secret_manager_secret.github_token.id
  secret_data = var.github_token
}