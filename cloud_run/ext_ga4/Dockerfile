FROM python:3.11-slim

# Impede o Python de gerar arquivos .pyc e permite logs em tempo real
ENV PYTHONUNBUFFERED True

# Diretório de trabalho
ENV APP_HOME /app
WORKDIR $APP_HOME

# Instala dependências
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia o código
COPY main.py .

# Executa o serviço usando Gunicorn (servidor de produção)
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app