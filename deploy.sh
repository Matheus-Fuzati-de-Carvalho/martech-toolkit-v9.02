#!/bin/bash
set -e # Para o script se algo falhar

# --- [ 0. ARGUMENTOS ] ---
GITHUB_TOKEN=$1
PROJECT_ID=$2
REGION=$3
GA4_ENABLE=$4
META_ENABLE=$5
GADS_ENABLE=$6
ALERT_EMAIL_ENABLE=$7

echo "---------------------------------------------------------"
echo "🚀 REINICIANDO IMPLANTAÇÃO V9.02"
echo "---------------------------------------------------------"

# 1. Ativação de APIs (Uma por uma para não dar erro)
echo "📡 1. Ativando APIs..."
gcloud services enable run.googleapis.com --project=$PROJECT_ID
gcloud services enable cloudbuild.googleapis.com --project=$PROJECT_ID
gcloud services enable dataform.googleapis.com --project=$PROJECT_ID
gcloud services enable bigquery.googleapis.com --project=$PROJECT_ID
gcloud services enable workflows.googleapis.com --project=$PROJECT_ID

# 2. Build das Imagens (Sequencial - Sem erros de cota)
echo "📦 2. Construindo Motores de Extração..."

if [ "$GA4_ENABLE" == "true" ]; then
    echo "🔨 Construindo GA4..."
    gcloud builds submit --tag gcr.io/$PROJECT_ID/ext_ga4:latest ./cloud_run/ext_ga4 --project=$PROJECT_ID --quiet
fi

if [ "$META_ENABLE" == "true" ]; then
    echo "🔨 Construindo Meta Ads..."
    gcloud builds submit --tag gcr.io/$PROJECT_ID/ext_meta_ads:latest ./cloud_run/ext_meta_ads --project=$PROJECT_ID --quiet
fi

if [ "$GADS_ENABLE" == "true" ]; then
    echo "🔨 Construindo Google Ads..."
    gcloud builds submit --tag gcr.io/$PROJECT_ID/ext_google_ads:latest ./cloud_run/ext_google_ads --project=$PROJECT_ID --quiet
fi

# 3. Preparação do Dataform
echo "📝 3. Configurando IDs no Dataform..."
find ./dataform/definitions -type f -name "*.sqlx" -exec sed -i "s/ID_DO_PROJETO/${PROJECT_ID}/g" {} +

# 4. Terraform (A hora da verdade)
echo "🏗️  4. Provisionando Infraestrutura com Terraform..."
cd terraform
terraform init -reconfigure
terraform apply -auto-approve \
  -var="project_id=$PROJECT_ID" \
  -var="region=$REGION" \
  -var="github_token=$GITHUB_TOKEN" \
  -var="ga4_enable=$GA4_ENABLE" \
  -var="meta_ads_enable=$META_ENABLE" \
  -var="google_ads_enable=$GADS_ENABLE" \
  -var="alert_email_enable=$ALERT_EMAIL_ENABLE"

echo "---------------------------------------------------------"
echo "🏆 V9.02 IMPLANTADA COM SUCESSO!"
echo "---------------------------------------------------------"