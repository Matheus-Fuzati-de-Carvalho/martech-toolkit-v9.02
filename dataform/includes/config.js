// dataform/includes/config.js

// Estas variáveis serão editadas via 'sed' no script de deploy.sh
const GA4_ENABLE = true;
const META_ADS_ENABLE = true;
const GOOGLE_ADS_ENABLE = true;
const ALERT_EMAIL_ENABLE = true;

// Configurações de Projeto (Injetadas via Workflow no v9.02)
const PROJECT_ID = "ID_DO_PROJETO";
const LOCATION = "us-central1";

module.exports = { 
    GA4_ENABLE, 
    META_ADS_ENABLE, 
    GOOGLE_ADS_ENABLE, 
    ALERT_EMAIL_ENABLE,
    PROJECT_ID,
    LOCATION
};