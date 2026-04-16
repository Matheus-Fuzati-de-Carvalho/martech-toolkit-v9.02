#!/bin/bash
# =================================================================
# MARTECH TOOLKIT V9.02 - PRODUCTION DEPLOYER (CLEAN LOGS)
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
echo "🚀 Iniciando Deploy Martech Toolkit v9.02"
echo "Project: ${PROJECT_ID} | Region: ${REGION}"
echo "---------------------------------------------------------"

echo "📡 1. Ativando APIs necessárias..."
gcloud services enable run.googleapis.com cloudbuild.googleapis.com \
    dataform.googleapis.com cloudscheduler.googleapis.com \
    workflows.googleapis.com secretmanager.googleapis.com \
    bigquery.googleapis.com --project="${PROJECT_ID}" --quiet

echo "📦 2. Build das imagens (Sequencial para logs limpos)..."
services=()
[[ "$GA4_ENABLE" == "true" ]] && services+=("ext_ga4")
[[ "$META_ENABLE" == "true" ]] && services+=("ext_meta_ads")
[[ "$GADS_ENABLE" == "true" ]] && services+=("ext_google_ads")
[[ "$ALERT_EMAIL_ENABLE" == "true" ]] && services+=("alert_service")

for svc in "${services[@]}"; do
    echo "🔨 Construindo $svc... (Aguarde)"
    gcloud builds submit --tag "gcr.io/${PROJECT_ID}/$svc:latest" "./cloud_run/$svc" --project="${PROJECT_ID}" --quiet
    echo "✅ $svc finalizado com sucesso."
done

echo "📝 3. Injetando Project ID no Dataform..."
find ./dataform/definitions -type f -name "*.sqlx" -exec sed -i "s/ID_DO_PROJETO/${PROJECT_ID}/g" {} +

echo "🏗️  4. Provisionando Infraestrutura (Terraform)..."
cd terraform
terraform init -reconfigure

# Comando inline para evitar erros de quebra de linha
terraform apply -auto-approve -var="project_id=${PROJECT_ID}" -var="region=${REGION}" -var="github_token=${GITHUB_TOKEN}" -var="ga4_enable=${GA4_ENABLE}" -var="meta_ads_enable=${META_ENABLE}" -var="google_ads_enable=${GADS_ENABLE}" -var="alert_email_enable=${ALERT_EMAIL_ENABLE}" -var="sender_email=${SENDER_EMAIL}" -var="receiver_email=${RECEIVER_EMAIL}" -var="email_password=${EMAIL_PASSWORD}"

echo "---------------------------------------------------------"
echo "🏆 DEPLOY FINALIZADO COM SUCESSO!"
echo "---------------------------------------------------------"S