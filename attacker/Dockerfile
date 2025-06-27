FROM python:3.9-slim

# Set environment variables for faster builds
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copy only the necessary file
COPY send_email.py .

# Use non-root user for security
RUN adduser --disabled-password --gecos '' appuser && \
    chown -R appuser:appuser /app
USER appuser

CMD ["python", "send_email.py"]