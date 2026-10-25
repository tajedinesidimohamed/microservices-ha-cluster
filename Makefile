# Commandes du projet (à lancer depuis WSL2)
.PHONY: up down test failover logs

## Génère le certificat si besoin puis lance toute la stack
up:
	./scripts/generate-cert.sh
	docker compose up -d --build

## Arrête et supprime les conteneurs
down:
	docker compose down

## Démontre le round-robin
test:
	./scripts/test-loadbalancing.sh

## Démontre la tolérance aux pannes (arrêt de api2)
failover:
	./scripts/test-failover.sh

## Affiche les logs JSON de Nginx en continu
logs:
	tail -f logs/access.log
