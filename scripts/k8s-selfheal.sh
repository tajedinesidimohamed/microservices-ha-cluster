#!/usr/bin/env bash
# Supprime un pod de l'API et montre que Kubernetes le recrée automatiquement.
set -euo pipefail

URL="${URL:-http://localhost:8080/}"

echo "Pods avant :"
kubectl get pods -l app=api -o wide

victim=$(kubectl get pods -l app=api -o jsonpath='{.items[0].metadata.name}')
echo ">>> Suppression du pod $victim"
kubectl delete pod "$victim" --wait=false

# Le service reste disponible pendant la recréation
for i in $(seq 1 5); do
  container=$(curl -s --max-time 3 "$URL" | sed -n 's/.*"container":"\([^"]*\)".*/\1/p')
  echo "Requête $i -> ${container:-ERREUR}"
  sleep 1
done

# Attente du retour à 3 pods prêts
echo ">>> Attente de 3 pods prêts..."
until [[ $(kubectl get pods -l app=api -o jsonpath='{range .items[*]}{.status.containerStatuses[0].ready}{"\n"}{end}' | grep -c true) -eq 3 ]]; do
  sleep 2
done

echo "Pods après (un nouveau nom remplace $victim) :"
kubectl get pods -l app=api -o wide
