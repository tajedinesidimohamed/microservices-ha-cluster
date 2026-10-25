# Image légère et version précise
FROM python:3.12.7-slim-bookworm

# Pas de fichiers .pyc, logs Python non bufferisés
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

WORKDIR /app

# Dépendances d'abord (meilleure utilisation du cache Docker)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

# Utilisateur non-root pour limiter l'impact d'une compromission
RUN useradd --create-home --uid 1000 appuser
USER appuser

EXPOSE 8000

# Vérifie l'état du service via /health (sans installer curl)
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
