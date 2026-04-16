#!/bin/bash
# =================================================================
# MARTECH TOOLKIT V9.01 STYLE - SIMPLE DEPLOYER (ZIP MODE)
# =================================================================
set -e

# --- [ 0. CAPTURA DE ARGUMENTOS ] ---
GITHUB_TOKEN=${1:-""}
PROJECT_ID=${2:-""}
REGION=${3:-"us-central1"}
GA4_ENABLE=${4:-"true"}
META_ENABLE=${5:-"true"}
GADS_ENABLE=${6:-"true"}
ALERT_EMAIL_ENABLE=${7:-"false"}
SENDER_EMAIL=${8:-""}
RECEIVER_EMAIL=${9:-""}
EMAIL_PASSWORD=${10:-""}

# --- [ 1. PREPARAÇÃO ] ---
chmod +x "$0" 2>/dev/null || true
echo "---------------------------------------------------------"
echo "🚀 Iniciando Deploy Simplificado (Cloud Functions)"
echo "Projeto: ${PROJECT_ID}"
echo "---------------------------------------------------------"

# 1. Ativação de APIs necessárias para Cloud Functions
echo "📡 1. Preparando APIs do Google Cloud..."
gcloud services enable \
    cloudfunctions.googleapis.com \
    cloudbuild.googleapis.com \
    storage.googleapis.com \
    dataform.googleapis.com \
    workflows.googleapis.com \
    --project="${PROJECT_ID}" --quiet

# 2. Injetando Project ID no Dataform (Recursivo)
echo "📝 2. Configurando caminhos do BigQuery no Dataform..."
find ./dataform/definitions -type f -name "*.sqlx" -exec sed -i "s/ID_DO_PROJETO/${PROJECT_ID}/g" {} +

# 3. Terraform (Aqui o ZIP é criado e enviado automaticamente)
echo "🏗️  3. Provisionando Infraestrutura..."
cd terraform
# Cria pasta temporária para os ZIPs se não existir
mkdir -p files

terraform init -reconfigure
terraform apply -auto-approve \
  -var="project_id=${PROJECT_ID}" \
  -var="region=${REGION}" \
  -var="github_token=${GITHUB_TOKEN}" \
  -var="github_repo_url=https://github.com/Matheus-Fuzati-de-Carvalho/martech-toolkit-v9-02.git" \
  -var="ga4_enable=${GA4_ENABLE}" \
  -var="meta_ads_enable=${META_ENABLE}" \
  -var="google_ads_enable=${GADS_ENABLE}" \
  -var="alert_email_enable=${ALERT_EMAIL_ENABLE}" \
  -var="sender_email=${SENDER_EMAIL}" \
  -var="receiver_email=${RECEIVER_EMAIL}" \
  -var="email_password=${EMAIL_PASSWORD}"

echo "---------------------------------------------------------"
echo "🏆 DEPLOY CONCLUÍDO NO PADRÃO SIMPLIFICADO!"
echo "---------------------------------------------------------"