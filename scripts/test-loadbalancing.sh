#!/usr/bin/env bash
# Envoie 9 requêtes et affiche quel réplica a répondu (preuve du round-robin).
set -euo pipefail

URL="${URL:-https://localhost/}"

echo "9 requêtes vers $URL"
for i in $(seq 1 9); do
  # -k : certificat auto-signé accepté
  container=$(curl -sk "$URL" | sed -n 's/.*"container":"\([^"]*\)".*/\1/p')
  echo "Requête $i -> ${container:-ERREUR}"
done
