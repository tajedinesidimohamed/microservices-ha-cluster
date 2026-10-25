#!/usr/bin/env bash
# Génère un certificat TLS auto-signé pour localhost (usage local uniquement).
# Le dossier certs/ est ignoré par Git : aucun secret n'est versionné.
set -euo pipefail

CERT_DIR="$(cd "$(dirname "$0")/.." && pwd)/certs"
mkdir -p "$CERT_DIR"

if [[ -f "$CERT_DIR/server.crt" && -f "$CERT_DIR/server.key" ]]; then
  echo "Certificat déjà présent dans $CERT_DIR (supprime-le pour le régénérer)."
  exit 0
fi

# Clé RSA 2048 bits, validité 365 jours, SAN obligatoire pour les navigateurs modernes
openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout "$CERT_DIR/server.key" \
  -out "$CERT_DIR/server.crt" \
  -subj "/C=FR/L=Rennes/O=microservices-ha-cluster/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

# Nginx (master root) lit la clé ; on restreint les droits au minimum utile
chmod 644 "$CERT_DIR/server.crt"
chmod 600 "$CERT_DIR/server.key"

echo "Certificat généré dans $CERT_DIR"
