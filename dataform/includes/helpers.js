// dataform/includes/helpers.js
const config = require("./config");

/**
 * Função de Taxonomia Unificada.
 * Define o "Contrato" de colunas para que todas as fontes sejam compatíveis.
 * Garante nomes consistentes como 'date', 'spend', 'clicks' e 'conversions'.
 */
function standardizedColumns() {
  return `
    event_date as date,
    platform as source,
    campaign_name as campaign,
    safe_cast(cost as float64) as spend,
    safe_cast(clicks as int64) as clicks,
    safe_cast(conversions as int64) as conversions
  `;
}

/**
 * Helper de Publicação Condicional.
 * Se a flag do módulo for 'false', retorna 'null', 
 * o que instrui o Dataform a não publicar o arquivo no BigQuery.
 * @param {boolean} enableFlag - A flag de ativação vinda do config.js
 * @param {string} type - O tipo de tabela (ex: "table", "view", "incremental")
 */
function shouldPublish(enableFlag, type = "table") {
  return enableFlag ? type : null;
}

module.exports = { 
  standardizedColumns,
  shouldPublish
};