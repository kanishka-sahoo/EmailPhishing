#!/usr/bin/env python3
import smtplib
import time
import sys
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_phishing_email():
    """Send a simulated phishing email to test detection capabilities."""
    
    # Create message
    msg = MIMEMultipart()
    msg["Subject"] = "URGENT: Your Account Has Been Suspended - Action Required"
    msg["From"] = "security@example-bank.com"
    msg["To"] = "user@example.com"
    
    # Phishing email body with common social engineering tactics
    body = """
Dear Valued Customer,

We have detected suspicious activity on your account and it has been temporarily suspended for your security.

To restore access to your account, please click the link below and verify your identity:

🔗 https://example-bank-verify.com/secure-login

This is an urgent matter. Failure to verify within 24 hours will result in permanent account closure.

Best regards,
Security Team
Example Bank
    """
    
    msg.attach(MIMEText(body, "plain"))
    
    # Try to send email with retry logic
    max_retries = 3
    retry_delay = 5
    
    for attempt in range(max_retries):
        try:
            print(f"🔄 Attempt {attempt + 1}/{max_retries}: Sending phishing email...")
            
            with smtplib.SMTP("email-server", 25, timeout=10) as smtp:
                smtp.send_message(msg)
                print("✅ Phishing email sent successfully to user@example.com")
                print("📧 Subject: URGENT: Your Account Has Been Suspended - Action Required")
                print("🎯 From: security@example-bank.com")
                return True
                
        except smtplib.SMTPException as e:
            print(f"❌ SMTP Error on attempt {attempt + 1}: {e}")
        except Exception as e:
            print(f"❌ Unexpected error on attempt {attempt + 1}: {e}")
        
        if attempt < max_retries - 1:
            print(f"⏳ Waiting {retry_delay} seconds before retry...")
            time.sleep(retry_delay)
    
    print("❌ Failed to send email after all retry attempts")
    return False

if __name__ == "__main__":
    print("🚀 Starting phishing email simulation...")
    print("🎯 Target: user@example.com")
    print("📧 Server: email-server:25")
    
    success = send_phishing_email()
    
    if success:
        print("🎭 Phishing simulation completed successfully!")
        print("🔍 Check Wazuh dashboard for detection events")
    else:
        print("💥 Phishing simulation failed!")
        sys.exit(1)