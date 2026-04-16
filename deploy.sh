#!/bin/bash

# =================================================================
# MARTECH TOOLKIT V9.02 - AUTOMATED DEPLOYER
# =================================================================

set -e # Para o script se qualquer comando falhar

echo "🚀 Iniciando o Deploy do Martech Toolkit v9.02..."

# 1. Coleta de Variáveis de Ambiente
read -p "ID do Projeto GCP: " PROJECT_ID
read -p "Região (ex: us-central1): " REGION
read -p "E-mail do Remetente (Gmail): " SENDER_EMAIL
read -p "E-mail do Destinatário: " RECEIVER_EMAIL
read -sp "Senha de App do Gmail (Remetente): " EMAIL_PASSWORD
echo ""
read -sp "Token do GitHub (para o Dataform): " GITHUB_TOKEN
echo ""

# 2. Configurar o GCloud
gcloud config set project $PROJECT_ID

# 3. Habilitar APIs Necessárias
echo "⚙️ Habilitando APIs do Google Cloud..."
gcloud services enable \
    compute.googleapis.com \
    run.googleapis.com \
    workflows.googleapis.com \
    dataform.googleapis.com \
    cloudscheduler.googleapis.com \
    cloudbuild.googleapis.com \
    secretmanager.googleapis.com

# 4. Build e Push das Imagens Cloud Run (via Cloud Build)
# Fazemos isso antes do Terraform para que as imagens já existam quando ele as chamar
echo "📦 Construindo e enviando imagens dos motores de extração..."

services=("ext_ga4" "ext_meta_ads" "ext_google_ads" "alert_service")

for service in "${services[@]}"; do
    echo "🔨 Construindo $service..."
    gcloud builds submit --tag "gcr.io/$PROJECT_ID/$service:latest" "./cloud_run/$service"
done

# 5. Ajustes Dinâmicos no Dataform (Substituição do ID do Projeto)
echo "📝 Ajustando referências de projeto no Dataform..."
sed -i "s/ID_DO_PROJETO/$PROJECT_ID/g" ./dataform/definitions/0_raw/sources.sqlx
sed -i "s/ID_DO_PROJETO/$PROJECT_ID/g" ./dataform/definitions/3_quality/dm_dq_finops_costs.sqlx

# 6. Execução do Terraform
echo "🏗️  Iniciando infraestrutura via Terraform..."
cd terraform
terraform init

terraform apply -auto-approve \
    -var="project_id=$PROJECT_ID" \
    -var="region=$REGION" \
    -var="sender_email=$SENDER_EMAIL" \
    -var="receiver_email=$RECEIVER_EMAIL" \
    -var="email_password=$EMAIL_PASSWORD" \
    -var="github_token=$GITHUB_TOKEN"

# 7. Finalização
echo "✅ DEPLOY CONCLUÍDO COM SUCESSO!"
echo "---------------------------------------------------------"
echo "PRÓXIMOS PASSOS:"
echo "1. Pegue o e-mail da Service Account gerada no IAM."
echo "2. Compartilhe o acesso (Leitor) dos arquivos do Drive com ela."
echo "3. O seu Workflow rodará automaticamente conforme o Scheduler,"
echo "   mas você já pode dispará-lo manualmente no console do Cloud Workflows."
echo "---------------------------------------------------------"