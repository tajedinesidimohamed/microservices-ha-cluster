#!/usr/bin/env bash
# Démontre la tolérance aux pannes : on arrête api2 pendant que les requêtes continuent.
set -euo pipefail

URL="${URL:-https://localhost/}"
TARGET="api2"
TOTAL=30
STOP_AT=10
START_AT=20
failures=0

# Toujours redémarrer api2, même si le script est interrompu (Ctrl+C)
trap 'docker start "$TARGET" >/dev/null 2>&1 || true' EXIT

for i in $(seq 1 "$TOTAL"); do
  if [[ $i -eq $STOP_AT ]]; then
    echo ">>> Panne simulée : docker stop $TARGET"
    docker stop "$TARGET" >/dev/null
  fi
  if [[ $i -eq $START_AT ]]; then
    echo ">>> Réparation : docker start $TARGET"
    docker start "$TARGET" >/dev/null
  fi

  # Corps de la réponse suivi du code HTTP
  response=$(curl -sk --max-time 5 -w ' %{http_code}' "$URL" || echo ' 000')
  code="${response##* }"
  container=$(echo "$response" | sed -n 's/.*"container":"\([^"]*\)".*/\1/p')

  if [[ "$code" == "200" ]]; then
    echo "Requête $i -> $container (HTTP $code)"
  else
    echo "Requête $i -> ÉCHEC (HTTP $code)"
    failures=$((failures + 1))
  fi
  sleep 0.5
done

echo "Résultat : $((TOTAL - failures))/$TOTAL requêtes réussies"
