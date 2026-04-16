import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from flask import Flask, request

app = Flask(__name__)

# Configurações de E-mail (TODAS vindo do Sistema de Deploy/Terraform)
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587

# Variáveis injetadas via Variáveis de Ambiente no Cloud Run
SENDER_EMAIL = os.getenv("SENDER_EMAIL")
RECEIVER_EMAIL = os.getenv("RECEIVER_EMAIL")
EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")

@app.route("/", methods=["POST"])
def send_alert():
    try:
        # Validação básica de segurança
        if not all([SENDER_EMAIL, RECEIVER_EMAIL, EMAIL_PASSWORD]):
            return {"status": "error", "message": "Configurações de e-mail incompletas no servidor"}, 500

        # 1. Recebe os detalhes do erro do Workflow
        envelope = request.get_json()
        if not envelope:
            return {"status": "error", "message": "Payload vazio"}, 400

        error_msg = envelope.get("error_message", "Erro não especificado")
        execution_id = envelope.get("execution_id", "N/A")
        step_name = envelope.get("step", "Unknown")

        # 2. Monta o e-mail HTML
        message = MIMEMultipart("alternative")
        message["Subject"] = f"🚨 ALERTA: Falha no Martech Toolkit v9.02"
        message["From"] = SENDER_EMAIL
        message["To"] = RECEIVER_EMAIL

        html = f"""
        <html>
          <body style="font-family: sans-serif; color: #333; line-height: 1.6;">
            <div style="background-color: #f8d7da; padding: 20px; border-radius: 10px; border: 1px solid #f5c6cb;">
              <h2 style="color: #721c24; margin-top: 0;">Falha Crítica no Workflow</h2>
              <p>Ocorreu um erro que interrompeu a execução do pipeline.</p>
              <hr style="border: 0; border-top: 1px solid #f5c6cb;">
              <p><b>🔍 Passo do Erro:</b> {step_name}</p>
              <p><b>🆔 ID da Execução:</b> <code>{execution_id}</code></p>
              <div style="background: #ffffff; padding: 15px; border-radius: 5px; border-left: 5px solid #d9534f; font-family: monospace;">
                  <b>Log do Erro:</b><br>{error_msg}
              </div>
            </div>
            <p style="font-size: 11px; color: #999; margin-top: 20px;">
                Este é um alerta automático enviado pelo Martech Toolkit v9.02 via Google Cloud Run.
            </p>
          </body>
        </html>
        """
        message.attach(MIMEText(html, "html"))

        # 3. Conexão e Envio via SMTP
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SENDER_EMAIL, EMAIL_PASSWORD)
        server.sendmail(SENDER_EMAIL, RECEIVER_EMAIL, message.as_string())
        server.quit()

        return {"status": "success", "message": "E-mail de alerta enviado com sucesso!"}, 200

    except Exception as e:
        print(f"Erro ao enviar e-mail: {str(e)}")
        return {"status": "error", "message": f"Falha no envio: {str(e)}"}, 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))