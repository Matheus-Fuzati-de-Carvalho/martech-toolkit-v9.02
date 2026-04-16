import pandas as pd
from google.cloud import bigquery
import requests
import io

def main(request):
    PROJECT_ID = os.getenv("PROJECT_ID")
    DATASET_ID = os.getenv("DATASET_ID", "martech_raw")
    table_id = f"{PROJECT_ID}.{DATASET_ID}.raw_ga4"
    file_id = "1UKpyUjs8HVKmcS4NMP1yGyq6RWgoln81"
    
    url = f'https://drive.google.com/uc?id={file_id}'
    
    try:
        # Lendo o JSON direto da URL pública do Drive
        df = pd.read_json(url)
        
        client = bigquery.Client(project=project_id)
        job_config = bigquery.LoadJobConfig(write_disposition="WRITE_TRUNCATE")
        
        client.load_table_from_dataframe(df, table_id, job_config=job_config).result()
        
        return f"Sucesso: {len(df)} linhas inseridas em {table_id}", 200
    except Exception as e:
        return f"Erro: {str(e)}", 500