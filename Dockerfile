# Usa una imagen base oficial de Python. 
# python:3.10-slim es ligera y adecuada para producción.
FROM python:3.10-slim

# Establece la variable de entorno para que Python no escriba archivos .pyc en el disco 
# y para que los logs sean enviados directamente al stdout/stderr del contenedor.
ENV PYTHONUNBUFFERED 1

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de dependencia e instálalos primero. 
# Esto aprovecha el caché de Docker si las dependencias no cambian.
COPY requirements.txt .

# Instala las dependencias.
# Se utiliza --no-cache-dir para reducir el tamaño de la imagen final.
RUN pip install --no-cache-dir -r requirements.txt

# Copia el resto del código de la aplicación (incluyendo app.py y la carpeta templates)
# El '.' final en el comando COPY significa copiar todo desde la carpeta de contexto actual.
COPY . .

# Cloud Run requiere que el contenedor escuche en el puerto definido por la variable de entorno $PORT (por defecto 8080).
# Aunque no es estrictamente necesario, es buena práctica exponerlo.
EXPOSE 8080

# Comando de inicio para Gunicorn.
# Gunicorn es un servidor WSGI de producción que ejecuta la aplicación Flask.
# El formato es: gunicorn [OPCIONES] [ARCHIVO_FLASK]:[INSTANCIA_FLASK]
# -w 2: Ejecuta 2 procesos de trabajo (ajusta según el uso de memoria).
# --timeout 120: Aumenta el tiempo de espera para la carga inicial del modelo.
# -b 0.0.0.0:$PORT: Asegura que escuche en todas las interfaces y use el puerto de Cloud Run.
CMD exec gunicorn --bind 0.0.0.0:$PORT --workers 2 --threads 4 --timeout 120 app
