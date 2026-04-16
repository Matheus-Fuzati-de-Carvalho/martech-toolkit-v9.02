import os
import json
import io
from flask import Flask, request
from google.cloud import bigquery
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseDownload

app = Flask(__name__)

# Configurações via Variáveis de Ambiente
PROJECT_ID = os.getenv("PROJECT_ID")
DATASET_ID = os.getenv("DATASET_ID", "martech_raw")
TABLE_NAME = "meta_ads_raw"

# ID FIXO DO ARQUIVO NO DRIVE (Substitua pelo ID do seu arquivo de Meta Ads)
DRIVE_FILE_ID = "1aKjgVEGa-Xv95TyXX6SM2p2EEIqhGRpt"

@app.route("/", methods=["POST"])
def run_extraction():
    try:
        # 1. Autenticação na API do Google Drive
        drive_service = build('drive', 'v3')
        
        # 2. Download do conteúdo usando o ID Direto
        request_media = drive_service.files().get_media(fileId=DRIVE_FILE_ID)
        file_stream = io.BytesIO()
        downloader = MediaIoBaseDownload(file_stream, request_media)
        
        done = False
        while done is False:
            status, done = downloader.next_chunk()
        
        # 3. Decodifica o conteúdo JSON
        file_stream.seek(0)
        data = json.loads(file_stream.read().decode('utf-8'))

        # 4. Inicializa o cliente BigQuery
        bq_client = bigquery.Client(project=PROJECT_ID)
        table_ref = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_NAME}"

        # 5. Configuração do Job de Carga (WRITE_TRUNCATE)
        job_config = bigquery.LoadJobConfig(
            write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
            source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
            autodetect=True
        )

        # 6. Converte para NDJSON
        if isinstance(data, list):
            ndjson_content = "\n".join([json.dumps(record) for record in data])
        else:
            ndjson_content = json.dumps(data)

        # 7. Executa a carga no BQ
        load_job = bq_client.load_table_from_string(
            ndjson_content, 
            table_ref, 
            job_config=job_config
        )
        load_job.result()

        return {
            "status": "success", 
            "message": f"Extração Meta Ads concluída. Tabela {TABLE_NAME} atualizada."
        }, 200

    except Exception as e:
        print(f"Erro Crítico Meta Ads: {str(e)}")
        return {"status": "error", "message": str(e)}, 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))