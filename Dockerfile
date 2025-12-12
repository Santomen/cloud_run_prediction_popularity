FROM python:3.10-slim

# Evita que Python genere .pyc y fuerza logs a consola
ENV PYTHONUNBUFFERED 1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Buena práctica exponer el puerto
EXPOSE 8080

# AJUSTE CLAVE:
# 1. Usamos 'app:app' (Archivo app.py : Objeto app)
# 2. --workers 1 (Para ahorrar RAM, TensorFlow es pesado)
# 3. --timeout 0 (Para evitar que Cloud Run mate el proceso si tarda en arrancar)
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app
