variable "project_id" { type = string }
variable "region" { type = string }

# Extração (O que buscar?)
variable "enable_ga4" { type = bool }
variable "enable_meta_ads" { type = bool }
variable "enable_google_ads" { type = bool }

# Nomenclatura (Onde salvar?)
variable "dataset_bronze_name" { type = string }
variable "table_raw_ga4" { type = string }
variable "table_raw_meta" { type = string }
variable "table_raw_ads" { type = string }

# Orquestração (Como operar?)
variable "enable_error_alert" { type = bool }
variable "cron_schedule" { type = string }