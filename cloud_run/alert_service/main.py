import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def main(request):
    """
    Ponto de entrada para Cloud Function (v9.01 style)
    Envia alertas de e-mail baseados em falhas do Workflow.
    """
    
    # 1. Configurações de E-mail via Variáveis de Ambiente
    SMTP_SERVER = "smtp.gmail.com"
    SMTP_PORT = 587
    SENDER_EMAIL = os.getenv("SENDER_EMAIL")
    RECEIVER_EMAIL = os.getenv("RECEIVER_EMAIL")
    EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")

    try:
        # Validação de credenciais
        if not all([SENDER_EMAIL, RECEIVER_EMAIL, EMAIL_PASSWORD]):
            print("❌ Erro: Configurações de e-mail ausentes.")
            return "Configurações SMTP incompletas", 500

        # 2. Captura do JSON enviado pelo Workflow
        envelope = request.get_json(silent=True)
        if not envelope:
            return "Payload vazio ou inválido", 400

        error_msg = envelope.get("error_message", "Erro não detalhado")
        execution_id = envelope.get("execution_id", "ID não disponível")
        step_name = envelope.get("step", "Passo Indefinido")

        # 3. Montagem do E-mail HTML
        message = MIMEMultipart("alternative")
        message["Subject"] = "🚨 ALERTA: Falha no Martech Toolkit v9.02"
        message["From"] = SENDER_EMAIL
        message["To"] = RECEIVER_EMAIL

        html = f"""
        <html>
          <body style="font-family: sans-serif; color: #333; line-height: 1.6;">
            <div style="background-color: #f8d7da; padding: 20px; border-radius: 10px; border: 1px solid #f5c6cb;">
              <h2 style="color: #721c24; margin-top: 0;">Falha Crítica no Workflow</h2>
              <p>Ocorreu um erro que interrompeu a execução do pipeline de dados.</p>
              <hr style="border: 0; border-top: 1px solid #f5c6cb;">
              <p><b>🔍 Passo do Erro:</b> {step_name}</p>
              <p><b>🆔 ID da Execução:</b> <code>{execution_id}</code></p>
              <div style="background: #ffffff; padding: 15px; border-radius: 5px; border-left: 5px solid #d9534f; font-family: monospace; white-space: pre-wrap;">
                  <b>Log do Erro:</b><br>{error_msg}
              </div>
            </div>
            <p style="font-size: 11px; color: #999; margin-top: 20px;">
                Este é um alerta automático v9.01 (Legacy Simple Mode) via Cloud Functions.
            </p>
          </body>
        </html>
        """
        message.attach(MIMEText(html, "html"))

        # 4. Envio via SMTP (Gmail)
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SENDER_EMAIL, EMAIL_PASSWORD)
        server.sendmail(SENDER_EMAIL, RECEIVER_EMAIL, message.as_string())
        server.quit()

        print(f"✅ Alerta enviado com sucesso para {RECEIVER_EMAIL}")
        return "E-mail de alerta enviado", 200

    except Exception as e:
        print(f"❌ Falha crítica no Alert Service: {str(e)}")
        return f"Erro interno: {str(e)}", 500