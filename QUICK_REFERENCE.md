# Référence Rapide - Serveur MCP Wazuh

## 🚀 Démarrage rapide

```bash
# 1. Démarrer le serveur
cd /Users/emmanuellignon/Wazuh-MCP-Server
./wazuh-mcp-manager.sh start

# 2. Générer une clé API
./wazuh-mcp-manager.sh generate-key
# Résultat : wazuh_VOTRE_CLE_API

# 3. Obtenir un JWT token
./wazuh-mcp-manager.sh get-token wazuh_VOTRE_CLE_API
# Résultat : eyJhbGciOiJIUzI1NiIs...

# 4. Mettre à jour Claude Desktop
./wazuh-mcp-manager.sh update-config VOTRE_JWT_TOKEN

# 5. Redémarrer Claude Desktop
```

---

## 📦 Script de gestion

```bash
./wazuh-mcp-manager.sh [commande]
```

### Commandes principales

```bash
start           # Démarrer le serveur
stop            # Arrêter le serveur
restart         # Redémarrer le serveur
status          # Afficher le statut
logs            # Voir les logs en temps réel
health          # Check de santé
generate-key    # Générer une clé API
get-token       # Obtenir un JWT token
update-config   # Mettre à jour Claude Desktop
edit-env        # Éditer .env
rebuild         # Reconstruire le conteneur
```

---

## 🐳 Commandes Docker directes

```bash
# Démarrage
docker compose up -d --wait

# Arrêt
docker compose stop

# Redémarrage
docker compose restart

# Logs
docker compose logs -f wazuh-mcp-remote-server

# Statut
docker compose ps

# Cleanup
docker compose down
docker compose down -v  # avec volumes

# Rebuild
docker compose build --no-cache
docker compose up -d --wait
```

---

## 🔐 Gestion des tokens

### Générer une clé API

```bash
docker compose exec wazuh-mcp-remote-server python -c "
import secrets
api_key = 'wazuh_' + secrets.token_urlsafe(32)
print(api_key)
"
```

### Obtenir un JWT token

```bash
curl -X POST http://localhost:3000/auth/token \
  -H "Content-Type: application/json" \
  -d '{"api_key": "wazuh_VOTRE_CLE"}'
```

### Extraire uniquement le token

```bash
curl -s -X POST http://localhost:3000/auth/token \
  -H "Content-Type: application/json" \
  -d '{"api_key": "wazuh_VOTRE_CLE"}' | jq -r '.access_token'
```

---

## 🏥 Health checks

```bash
# Check de santé
curl http://localhost:3000/health | jq

# Métriques
curl http://localhost:3000/metrics

# Documentation API
open http://localhost:3000/docs
```

---

## ⚙️ Configuration

### Fichier .env

```bash
# Éditer
nano .env

# Variables essentielles
WAZUH_HOST=https://votre-serveur-wazuh.com
WAZUH_USER=votre-utilisateur
WAZUH_PASS=votre-mot-de-passe
WAZUH_PORT=55000
MCP_HOST=127.0.0.1
MCP_PORT=3000
AUTH_SECRET_KEY=votre-cle-secrete
```

### Configuration Claude Desktop

Fichier : `~/Library/Application Support/Claude/claude_desktop_config.json`

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

---

## 🔍 Diagnostic

### Vérifier le serveur

```bash
# Logs en direct
docker compose logs -f

# Dernières 50 lignes
docker compose logs --tail=50

# Filtrer les erreurs
docker compose logs | grep -i error

# Statut des conteneurs
docker compose ps
```

### Tester la connectivité

```bash
# Test local
curl http://localhost:3000/health

# Test depuis une autre machine
curl http://VOTRE_IP:3000/health

# Test Wazuh
curl -k -u user:password https://wazuh-server:55000
```

### Ports

```bash
# Vérifier que le port est ouvert
lsof -i :3000

# Tuer un processus sur le port 3000
kill -9 $(lsof -t -i:3000)
```

---

## 🔄 Renouvellement du token (24h)

### Méthode automatisée

```bash
# 1. Obtenir nouveau token
NEW_TOKEN=$(./wazuh-mcp-manager.sh get-token wazuh_VOTRE_CLE | tail -1)

# 2. Mettre à jour config
./wazuh-mcp-manager.sh update-config $NEW_TOKEN

# 3. Redémarrer Claude Desktop
```

### Méthode manuelle

```bash
# 1. Obtenir token
curl -s -X POST http://localhost:3000/auth/token \
  -H "Content-Type: application/json" \
  -d '{"api_key": "wazuh_VOTRE_CLE"}' | jq -r '.access_token'

# 2. Copier le token

# 3. Éditer config
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json

# 4. Remplacer le token

# 5. Redémarrer Claude Desktop
```

---

## 📁 Chemins importants

```bash
# Dossier du serveur
/Users/emmanuellignon/Wazuh-MCP-Server/

# Configuration serveur
/Users/emmanuellignon/Wazuh-MCP-Server/.env

# Script de gestion
/Users/emmanuellignon/Wazuh-MCP-Server/wazuh-mcp-manager.sh

# Config Claude Desktop
~/Library/Application Support/Claude/claude_desktop_config.json

# Logs Docker
docker compose logs
```

---

## 🛠️ Maintenance

### Mise à jour du serveur

```bash
cd /Users/emmanuellignon/Wazuh-MCP-Server

# Pull des changements
git pull

# Rebuild
docker compose down
docker compose build --no-cache
docker compose up -d --wait
```

### Nettoyage

```bash
# Arrêter et supprimer
docker compose down

# Supprimer avec volumes
docker compose down -v

# Nettoyer Docker
docker system prune -a
```

### Sauvegarde

```bash
# Sauvegarder .env
cp .env .env.backup

# Sauvegarder config Claude
cp ~/Library/Application\ Support/Claude/claude_desktop_config.json \
   ~/claude_desktop_config.backup.json

# Sauvegarder la clé API (dans un gestionnaire de mots de passe)
```

---

## ❌ Dépannage rapide

### Le serveur ne démarre pas

```bash
# Vérifier Docker
docker --version
docker compose --version

# Vérifier les logs
docker compose logs

# Reconstruire
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Claude ne voit pas le serveur

1. ✅ Serveur démarré : `curl http://localhost:3000/health`
2. ✅ Token valide (< 24h)
3. ✅ Config correcte : `cat ~/Library/Application\ Support/Claude/claude_desktop_config.json`
4. ✅ Claude Desktop redémarré

### Erreurs Wazuh

```bash
# Vérifier config
cat .env | grep WAZUH

# Tester connexion
curl -k -u $WAZUH_USER:$WAZUH_PASS $WAZUH_HOST:$WAZUH_PORT

# Logs serveur
docker compose logs | grep -i wazuh
```

---

## 🔗 URLs utiles

```bash
# Local
http://localhost:3000/health   # Health check
http://localhost:3000/metrics  # Métriques
http://localhost:3000/docs     # Documentation API
http://localhost:3000/sse      # Endpoint SSE

# Wazuh
https://votre-serveur:55000    # API Wazuh
https://votre-serveur:443      # Dashboard Wazuh
```

---

## 📊 Monitoring one-liner

```bash
# Watch health status
watch -n 5 'curl -s http://localhost:3000/health | jq ".services"'

# Monitor logs
docker compose logs -f --tail=20 | grep -E "ERROR|WARN|INFO"

# Check memory/CPU
docker stats wazuh-mcp-remote-server
```

---

## 💡 Tips

### Alias pratiques

Ajoutez à votre `~/.zshrc` ou `~/.bashrc` :

```bash
alias wmcp='cd /Users/emmanuellignon/Wazuh-MCP-Server'
alias wmcp-start='cd /Users/emmanuellignon/Wazuh-MCP-Server && ./wazuh-mcp-manager.sh start'
alias wmcp-logs='cd /Users/emmanuellignon/Wazuh-MCP-Server && ./wazuh-mcp-manager.sh logs'
alias wmcp-health='curl -s http://localhost:3000/health | jq'
alias wmcp-restart='cd /Users/emmanuellignon/Wazuh-MCP-Server && ./wazuh-mcp-manager.sh restart'
```

Puis rechargez :
```bash
source ~/.zshrc  # ou source ~/.bashrc
```

### Variables d'environnement

```bash
# Définir pour la session
export WAZUH_MCP_DIR="/Users/emmanuellignon/Wazuh-MCP-Server"
export WAZUH_API_KEY="wazuh_VOTRE_CLE"

# Utiliser
cd $WAZUH_MCP_DIR
```

---

**Dernière mise à jour :** 31 janvier 2026
