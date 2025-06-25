import smtplib
from email.mime.text import MIMEText

msg = MIMEText("👾 This is a malicious email payload!")
msg["Subject"] = "Malicious Email 🚨"
msg["From"] = "attacker@example.com"
msg["To"] = "user@example.com"

with smtplib.SMTP("email-server", 25) as smtp:
    smtp.send_message(msg)
    print("➤ Malicious email sent to user@example.com")