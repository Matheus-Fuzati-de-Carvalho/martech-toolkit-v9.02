# terraform/variables.tf

variable "project_id" {
  description = "ID do projeto no Google Cloud"
  type        = string
}

variable "region" {
  description = "Região onde os recursos serão criados"
  type        = string
  default     = "us-central1"
}

# --- FLAGS DE MODULARIZAÇÃO ---

variable "ga4_enable" {
  description = "Habilita extração e tratamento de GA4"
  type        = bool
  default     = true
}

variable "meta_ads_enable" {
  description = "Habilita extração e tratamento de Meta Ads"
  type        = bool
  default     = true
}

variable "google_ads_enable" {
  description = "Habilita extração e tratamento de Google Ads"
  type        = bool
  default     = true
}

variable "alert_email_enable" {
  description = "Habilita o envio de alertas por e-mail em caso de falha"
  type        = bool
  default     = true
}

variable "sender_email" {
  description = "E-mail que enviará as notificações (ex: seu-servico@gmail.com)"
  type        = string
  default     = false
}

variable "receiver_email" {
  description = "E-mail que receberá os alertas técnicos"
  type        = string
  default     = false
}


# --- CONFIGURAÇÕES DE TERCEIROS ---

variable "email_password" {
  description = "Senha de app do Gmail para o serviço de alerta"
  type        = string
  sensitive   = true
  default     = false
}

variable "scheduler_cron" {
  description = "Expressão Cron para o agendamento (ex: 0 9 * * *)"
  type        = string
  default     = "0 6 * * *"
}

# --- REPOSITÓRIO E GITHUB (Referência v9) ---

variable "github_repo_url" {
  type        = string
  description = "URL do repositorio no GitHub para o Dataform"
  default     = "https://github.com/Matheus-Fuzati-de-Carvalho/martech-toolkit-v9-02.git"
}

variable "github_token" {
  description = "Token de acesso do GitHub"
  type        = string
  sensitive   = true
}