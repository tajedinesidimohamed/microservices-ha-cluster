# Explications des concepts

## Load balancing (répartition de charge)
Un **load balancer** reçoit toutes les requêtes des clients et les distribue entre plusieurs serveurs identiques. Avantages : plus de capacité (plusieurs serveurs travaillent en parallèle) et **haute disponibilité** (si un serveur tombe, les autres prennent le relais). Ici, c'est **Nginx** qui joue ce rôle, devant `api1`, `api2` et `api3`.

## Round-robin
Algorithme de répartition le plus simple : chaque nouvelle requête va au serveur suivant dans la liste (1 → 2 → 3 → 1…). C'est l'algorithme par défaut de Nginx. Autres algorithmes : `least_conn` (le serveur le moins chargé), `ip_hash` (un client va toujours au même serveur).

## Health check (vérification de l'état)
Mécanisme qui vérifie régulièrement qu'un service fonctionne, ici via la route `GET /health`.
- **Docker** : l'instruction `HEALTHCHECK` marque le conteneur `healthy` ou `unhealthy`.
- **Nginx (open source)** : contrôle **passif** — après `max_fails` échecs, le serveur est écarté pendant `fail_timeout`.
- **Kubernetes** : la **readiness probe** décide si le pod reçoit du trafic, la **liveness probe** redémarre un pod bloqué.

## TLS / HTTPS
**TLS** chiffre la communication entre le client et le serveur : personne ne peut lire ou modifier les données en chemin. Le serveur prouve son identité avec un **certificat** (clé publique signée). Ici le certificat est **auto-signé** (pratique en local, mais le navigateur affiche un avertissement). On accepte seulement **TLS 1.2 et 1.3** (les anciennes versions sont vulnérables), on redirige HTTP vers HTTPS, et l'en-tête **HSTS** demande au navigateur de toujours utiliser HTTPS.

## Conteneur vs machine virtuelle
| | Conteneur | Machine virtuelle |
|---|---|---|
| Isolation | Processus isolés, **noyau partagé** avec l'hôte | Système d'exploitation complet avec **son propre noyau** |
| Taille | Quelques Mo | Plusieurs Go |
| Démarrage | Secondes | Minutes |
| Usage | Microservices, déploiements rapides | Isolation forte, OS différents |

## Pod Kubernetes
Un **pod** est la plus petite unité déployable dans Kubernetes : un ou plusieurs conteneurs qui partagent la même adresse IP et le même stockage. On ne crée presque jamais de pod à la main : un **Deployment** maintient le nombre de pods voulu (ici 3) et en recrée un automatiquement s'il disparaît. Un **Service** donne une adresse stable devant ces pods, et un **Ingress** expose les services à l'extérieur avec un routage par chemin.

---

# 10 questions d'entretien

**1. Que se passe-t-il quand `api2` tombe ?**
Nginx n'arrive plus à s'y connecter, renvoie la requête vers un autre réplica (`proxy_next_upstream`), et après 3 échecs (`max_fails`) l'écarte pendant 30 s (`fail_timeout`). Le client ne voit aucune erreur.

**2. Pourquoi 3 réplicas et pas 2 ?**
Avec 3 réplicas, si un serveur tombe il en reste 2 : on garde de la redondance et la charge reste répartie. C'est aussi le minimum courant pour tolérer une panne pendant une maintenance.

**3. Quelle est la limite de cette architecture ?**
Nginx est un **point unique de défaillance** (SPOF). En production on mettrait 2 load balancers avec une IP virtuelle (Keepalived) ou un load balancer managé du cloud.

**4. Différence entre health check actif et passif ?**
Passif : on détecte la panne sur de vraies requêtes qui échouent (Nginx open source). Actif : le load balancer interroge `/health` régulièrement, même sans trafic (Nginx Plus, HAProxy, Kubernetes).

**5. Différence entre readiness et liveness probe ?**
Readiness : « le pod est-il prêt à recevoir du trafic ? » ; sinon il est retiré du Service. Liveness : « le pod est-il encore vivant ? » ; sinon Kubernetes le redémarre.

**6. Pourquoi un certificat auto-signé n'est pas adapté en production ?**
Il n'est signé par aucune autorité de confiance : le navigateur ne peut pas vérifier l'identité du serveur. En production on utilise une autorité reconnue, par exemple Let's Encrypt.

**7. Pourquoi désactiver TLS 1.0 et 1.1 ?**
Ces versions ont des failles connues (POODLE, BEAST) et des algorithmes faibles. TLS 1.2 et 1.3 sont les seules versions recommandées aujourd'hui.

**8. Pourquoi exécuter les conteneurs avec un utilisateur non-root ?**
Si l'application est compromise, l'attaquant n'a pas les droits root dans le conteneur, ce qui limite les dégâts et les risques d'évasion vers l'hôte.

**9. Pourquoi des logs au format JSON ?**
Chaque champ (statut, temps de réponse, réplica utilisé) est directement exploitable par des outils comme ELK, sans expressions régulières fragiles pour découper les lignes.

**10. Comment Kubernetes recrée-t-il un pod supprimé ?**
Le Deployment déclare un état voulu (3 réplicas). Un contrôleur compare en permanence l'état réel à cet état voulu : s'il manque un pod, il en crée un nouveau. C'est la **boucle de réconciliation**.
