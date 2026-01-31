# Guide d'Installation et d'Utilisation - Serveur MCP Wazuh

## 📋 Table des matières

1. [Introduction](#introduction)
2. [Prérequis](#prérequis)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Utilisation](#utilisation)
6. [Commandes utiles](#commandes-utiles)
7. [Dépannage](#dépannage)
8. [Renouvellement du token](#renouvellement-du-token)

---

## Introduction

Le serveur MCP Wazuh est un serveur conforme au protocole MCP (Model Context Protocol) qui permet d'intégrer Wazuh SIEM avec Claude Desktop. Il fournit 29 outils spécialisés pour les opérations de sécurité assistées par IA.

### Fonctionnalités principales

- **Gestion des alertes** (4 outils) : Récupération, résumés, analyse de patterns
- **Gestion des agents** (6 outils) : Informations, santé, surveillance des processus/ports
- **Gestion des vulnérabilités** (3 outils) : Scans et évaluations
- **Analyse de sécurité** (6 outils) : Analyse de menaces, réputation IoC, évaluation des risques
- **Surveillance système** (10 outils) : Statistiques, santé du cluster, règles, logs

---

## Prérequis

- **Docker** 20.10+ avec Compose v2.20+
- **macOS** (ou Linux/Windows avec Docker)
- **Serveur Wazuh** 4.8.0 - 4.14.1 avec accès API (optionnel pour le démarrage)
- **Claude Desktop** installé

---

## Installation

### Étape 1 : Cloner le repository

```bash
git clone https://github.com/gensecaihq/Wazuh-MCP-Server.git
cd Wazuh-MCP-Server
```

### Étape 2 : Créer le fichier de configuration

```bash
cp .env.example .env
```

### Étape 3 : Générer une clé secrète

```bash
openssl rand -hex 32
```

### Étape 4 : Éditer le fichier .env

```bash
nano .env
```

Contenu minimal du fichier `.env` :

```bash
# === Wazuh Configuration ===
# À CONFIGURER : Remplacez par vos credentials Wazuh réels
WAZUH_HOST=https://votre-serveur-wazuh.com
WAZUH_USER=votre-utilisateur-api
WAZUH_PASS=votre-mot-de-passe
WAZUH_PORT=55000

# === MCP Server Configuration ===
MCP_HOST=127.0.0.1
MCP_PORT=3000

# === Authentication ===
AUTH_SECRET_KEY=votre-cle-secrete-generee

# Token lifetime in hours
TOKEN_LIFETIME_HOURS=24

# === CORS Configuration ===
ALLOWED_ORIGINS=https://claude.ai,https://*.anthropic.com,http://localhost:*

# === Logging ===
LOG_LEVEL=INFO

# === Wazuh SSL ===
WAZUH_VERIFY_SSL=false
WAZUH_ALLOW_SELF_SIGNED=true
```

### Étape 5 : Démarrer le serveur

```bash
docker compose up -d --wait
```

---

## Configuration

### Configuration de Claude Desktop

#### 1. Générer une clé API

```bash
docker compose exec wazuh-mcp-remote-server python -c "
import secrets
api_key = 'wazuh_' + secrets.token_urlsafe(32)
print(api_key)
"
```

**Exemple de clé générée :**
```
wazuh_DNKA2U3wBNn09Rwf2ZEitpigiMclWb68m7GMTAZludc
```

⚠️ **IMPORTANT** : Sauvegardez cette clé en lieu sûr !

#### 2. Échanger la clé API contre un JWT token

```bash
curl -X POST http://localhost:3000/auth/token \
  -H "Content-Type: application/json" \
  -d '{"api_key": "wazuh_VOTRE_CLE_API"}'
```

**Exemple de réponse :**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 86400
}
```

#### 3. Créer/Mettre à jour la configuration Claude Desktop

Créez ou éditez le fichier :
```
~/Library/Application Support/Claude/claude_desktop_config.json
```

Avec le contenu suivant :

```json
{
  "mcpServers": {
    "wazuh": {
      "transport": {
        "type": "sse",
        "url": "http://localhost:3000/sse"
      },
      "headers": {
        "Authorization": "Bearer VOTRE_JWT_TOKEN"
      }
    }
  }
}
```

#### 4. Redémarrer Claude Desktop

Fermez et relancez Claude Desktop pour que les changements soient pris en compte.

---

## Utilisation

### Script de gestion (Recommandé)

Un script de gestion est fourni pour simplifier toutes les opérations :

```bash
./wazuh-mcp-manager.sh [commande]
```

#### Commandes disponibles :

| Commande | Description |
|----------|-------------|
| `start` | Démarrer le serveur |
| `stop` | Arrêter le serveur |
| `restart` | Redémarrer le serveur |
| `status` | Afficher le statut du serveur |
| `logs` | Afficher les logs en temps réel |
| `health` | Vérifier la santé du serveur |
| `generate-key` | Générer une nouvelle clé API |
| `get-token <API_KEY>` | Obtenir un JWT token |
| `update-config <JWT_TOKEN>` | Mettre à jour la config Claude Desktop |
| `edit-env` | Éditer le fichier .env |
| `rebuild` | Reconstruire et redémarrer le conteneur |

#### Exemples d'utilisation :

```bash
# Démarrer le serveur
./wazuh-mcp-manager.sh start

# Voir les logs en temps réel
./wazuh-mcp-manager.sh logs

# Générer une nouvelle clé API
./wazuh-mcp-manager.sh generate-key

# Vérifier la santé du serveur
./wazuh-mcp-manager.sh health
```

---

## Commandes utiles

### Gestion du serveur Docker

```bash
# Démarrer le serveur
docker compose up -d --wait

# Arrêter le serveur
docker compose stop

# Redémarrer le serveur
docker compose restart

# Voir le statut
docker compose ps

# Voir les logs
docker compose logs -f wazuh-mcp-remote-server

# Arrêter et supprimer
docker compose down

# Reconstruire l'image
docker compose build --no-cache
docker compose up -d --wait
```

### Vérification de la santé

```bash
# Check de santé complet
curl http://localhost:3000/health | jq

# Métriques
curl http://localhost:3000/metrics

# Documentation API
open http://localhost:3000/docs
```

### Gestion des tokens

```bash
# Générer une clé API
docker compose exec wazuh-mcp-remote-server python -c "
import secrets
api_key = 'wazuh_' + secrets.token_urlsafe(32)
print(api_key)
"

# Obtenir un JWT token
curl -X POST http://localhost:3000/auth/token \
  -H "Content-Type: application/json" \
  -d '{"api_key": "wazuh_VOTRE_CLE"}'

# Extraire juste le token
curl -s -X POST http://localhost:3000/auth/token \
  -H "Content-Type: application/json" \
  -d '{"api_key": "wazuh_VOTRE_CLE"}' | jq -r '.access_token'
```

---

## Dépannage

### Le serveur ne démarre pas

**Vérifier les logs :**
```bash
docker compose logs wazuh-mcp-remote-server
```

**Problèmes courants :**

1. **Port 3000 déjà utilisé :**
   ```bash
   # Modifier MCP_PORT dans .env
   MCP_PORT=3001
   ```

2. **Erreur de configuration .env :**
   ```bash
   # Vérifier que les variables sont bien formatées
   cat .env
   ```

3. **Docker pas démarré :**
   ```bash
   # Démarrer Docker Desktop
   open -a Docker
   ```

### Connection à Wazuh échoue

**Symptômes :**
```
⚠️  Wazuh client initialization failed: Cannot connect to Wazuh server
```

**Solutions :**

1. Vérifier les credentials dans `.env`
2. Vérifier que le serveur Wazuh est accessible :
   ```bash
   curl -k https://votre-serveur-wazuh.com:55000
   ```

3. Vérifier les paramètres SSL :
   ```bash
   WAZUH_VERIFY_SSL=false
   WAZUH_ALLOW_SELF_SIGNED=true
   ```

### Claude Desktop ne voit pas le serveur MCP

**Vérifications :**

1. Le serveur MCP est démarré :
   ```bash
   curl http://localhost:3000/health
   ```

2. Le fichier de configuration existe :
   ```bash
   cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

3. Claude Desktop a été redémarré après la modification

4. Le JWT token n'est pas expiré (validité : 24h)

### Les outils de vulnérabilité ne fonctionnent pas

**Solution :**

Configurer Wazuh Indexer dans `.env` :

```bash
WAZUH_INDEXER_HOST=votre-wazuh-indexer.com
WAZUH_INDEXER_PORT=9200
WAZUH_INDEXER_USER=admin
WAZUH_INDEXER_PASS=admin
```

Puis redémarrer :
```bash
docker compose restart
```

---

## Renouvellement du token

Le JWT token expire après 24 heures. Pour le renouveler :

### Méthode 1 : Avec le script de gestion

```bash
# 1. Utiliser la même clé API
./wazuh-mcp-manager.sh get-token wazuh_VOTRE_CLE_API

# 2. Mettre à jour la configuration
./wazuh-mcp-manager.sh update-config NOUVEAU_JWT_TOKEN

# 3. Redémarrer Claude Desktop
```

### Méthode 2 : Manuellement

```bash
# 1. Obtenir un nouveau token
NEW_TOKEN=$(curl -s -X POST http://localhost:3000/auth/token \
  -H "Content-Type: application/json" \
  -d '{"api_key": "wazuh_VOTRE_CLE"}' | jq -r '.access_token')

# 2. Éditer le fichier de configuration
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json

# 3. Remplacer l'ancien token par le nouveau

# 4. Redémarrer Claude Desktop
```

---

## Configuration avancée

### Redis pour le mode serverless

Pour supporter plusieurs instances ou le mode serverless :

```bash
# Ajouter dans .env
REDIS_URL=redis://redis:6379/0
SESSION_TTL_SECONDS=1800

# Démarrer avec Redis
docker compose -f compose.yml -f compose.redis.yml up -d
```

### Haute disponibilité

Le serveur inclut :
- Circuit breaker automatique après 5 échecs
- Fenêtre de récupération de 60 secondes
- 3 tentatives de retry avec backoff exponentiel

### Support TLS/HTTPS

```bash
# Ajouter dans .env
SSL_KEYFILE=/chemin/vers/privkey.pem
SSL_CERTFILE=/chemin/vers/fullchain.pem

# Redémarrer
docker compose restart
```

---

## Endpoints disponibles

| Endpoint | Description |
|----------|-------------|
| `/mcp` | Streamable HTTP (Recommandé - 2025-06-18) |
| `/sse` | SSE only (Legacy) |
| `/auth/token` | Authentification |
| `/health` | Health check |
| `/metrics` | Métriques Prometheus |
| `/docs` | Documentation API |

---

## Informations de sécurité

### Bonnes pratiques

1. **Protégez vos clés API :**
   - Ne les committez jamais dans Git
   - Stockez-les dans un gestionnaire de mots de passe
   - Régénérez-les régulièrement

2. **Limitez l'accès réseau :**
   - Utilisez `MCP_HOST=127.0.0.1` pour un accès local uniquement
   - Configurez un pare-feu si exposé

3. **Surveillez les logs :**
   ```bash
   docker compose logs -f | grep -i error
   ```

4. **Mettez à jour régulièrement :**
   ```bash
   git pull
   docker compose down
   docker compose build --no-cache
   docker compose up -d
   ```

### Configuration de production

Pour un environnement de production, considérez :

- Activer TLS/HTTPS
- Configurer Redis pour la scalabilité
- Augmenter les limites de ressources dans `compose.yml`
- Configurer la rotation des logs
- Mettre en place une surveillance (Prometheus/Grafana)

---

## Support et ressources

- **Repository GitHub :** https://github.com/gensecaihq/Wazuh-MCP-Server
- **Documentation Wazuh :** https://documentation.wazuh.com/
- **Documentation MCP :** https://modelcontextprotocol.io/
- **Issues :** https://github.com/gensecaihq/Wazuh-MCP-Server/issues

---

## Fichiers importants

| Fichier | Description |
|---------|-------------|
| `.env` | Configuration du serveur |
| `compose.yml` | Configuration Docker |
| `wazuh-mcp-manager.sh` | Script de gestion |
| `~/Library/Application Support/Claude/claude_desktop_config.json` | Config Claude Desktop |

---

## Licence

MIT License - Voir le fichier LICENSE pour plus de détails.

---

**Dernière mise à jour :** 31 janvier 2026
