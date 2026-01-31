# 📚 Index de la Documentation - Serveur MCP Wazuh

Bienvenue ! Voici tous les fichiers de documentation disponibles pour vous aider à utiliser le serveur MCP Wazuh.

---

## 🎯 Par où commencer ?

### Vous débutez ?
➡️ Lisez **[GUIDE_FR.md](GUIDE_FR.md)** - Guide complet d'installation et d'utilisation

### Vous cherchez une commande ?
➡️ Consultez **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Référence rapide

### Vous voulez voir votre configuration ?
➡️ Ouvrez **[CONFIGURATION_ACTUELLE.md](CONFIGURATION_ACTUELLE.md)** - Votre installation

---

## 📖 Documentation disponible

| Fichier | Taille | Description |
|---------|--------|-------------|
| **[GUIDE_FR.md](GUIDE_FR.md)** | 11K | 📘 Guide complet en français |
| **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** | 7.2K | ⚡ Référence rapide des commandes |
| **[CONFIGURATION_ACTUELLE.md](CONFIGURATION_ACTUELLE.md)** | 8.1K | ⚙️ Votre configuration spécifique |
| **[wazuh-mcp-manager.sh](wazuh-mcp-manager.sh)** | 5.6K | 🔧 Script de gestion automatisé |
| **[INDEX.md](INDEX.md)** | - | 📚 Ce fichier (index) |

---

## 📘 GUIDE_FR.md - Guide complet

**Contenu :**
- Introduction et fonctionnalités
- Prérequis système
- Installation pas à pas
- Configuration de Claude Desktop
- Utilisation du script de gestion
- Commandes utiles
- Dépannage détaillé
- Renouvellement des tokens
- Configuration avancée (Redis, TLS, HA)
- Sécurité et bonnes pratiques

**Quand l'utiliser :**
- Première installation
- Comprendre le fonctionnement
- Configuration avancée
- Résoudre des problèmes complexes

---

## ⚡ QUICK_REFERENCE.md - Référence rapide

**Contenu :**
- Démarrage rapide (5 étapes)
- Toutes les commandes du script de gestion
- Commandes Docker directes
- Gestion des tokens (génération, renouvellement)
- Health checks et monitoring
- Configuration (.env et Claude Desktop)
- Diagnostic et troubleshooting
- Maintenance et mises à jour
- Alias pratiques pour le terminal

**Quand l'utiliser :**
- Besoin rapide d'une commande
- Aide-mémoire quotidien
- Vérifications de routine
- Dépannage rapide

---

## ⚙️ CONFIGURATION_ACTUELLE.md - Votre installation

**Contenu :**
- Vos chemins spécifiques
- Votre clé API personnelle
- Votre JWT token actuel
- Configuration complète (.env)
- Configuration Claude Desktop
- Commandes de démarrage rapide
- Prochaines étapes à suivre
- Checklist de vérification

**Quand l'utiliser :**
- Retrouver votre clé API
- Vérifier votre configuration
- Renouveler votre token
- Voir ce qu'il reste à faire

---

## 🔧 wazuh-mcp-manager.sh - Script de gestion

**Fonctionnalités :**
- Démarrer/arrêter/redémarrer le serveur
- Voir les logs en temps réel
- Générer des clés API
- Obtenir des JWT tokens
- Mettre à jour la config Claude Desktop automatiquement
- Éditer la configuration
- Rebuild du conteneur

**Utilisation :**
```bash
./wazuh-mcp-manager.sh [commande]
```

**Commandes disponibles :**
- `start` - Démarrer le serveur
- `stop` - Arrêter le serveur
- `restart` - Redémarrer
- `status` - Statut
- `logs` - Voir les logs
- `health` - Check de santé
- `generate-key` - Nouvelle clé API
- `get-token <API_KEY>` - Obtenir JWT
- `update-config <TOKEN>` - MAJ Claude Desktop
- `edit-env` - Éditer .env
- `rebuild` - Reconstruire

---

## 🚀 Démarrage rapide (résumé)

### 1. Démarrer le serveur

```bash
cd /Users/emmanuellignon/Wazuh-MCP-Server
./wazuh-mcp-manager.sh start
```

### 2. Vérifier que tout fonctionne

```bash
./wazuh-mcp-manager.sh health
```

### 3. Redémarrer Claude Desktop

```bash
# Fermez et relancez Claude Desktop
# Le serveur "wazuh" devrait apparaître dans les outils disponibles
```

### 4. Configurer Wazuh (prochaine étape)

```bash
# Éditez .env avec vos vraies credentials Wazuh
./wazuh-mcp-manager.sh edit-env

# Puis redémarrez
./wazuh-mcp-manager.sh restart
```

---

## 🔍 Trouver rapidement

### Commandes essentielles

| Besoin | Commande | Voir |
|--------|----------|------|
| Démarrer | `./wazuh-mcp-manager.sh start` | [QUICK_REFERENCE.md](QUICK_REFERENCE.md#-script-de-gestion) |
| Voir logs | `./wazuh-mcp-manager.sh logs` | [QUICK_REFERENCE.md](QUICK_REFERENCE.md#-commandes-docker-directes) |
| Check santé | `curl http://localhost:3000/health` | [QUICK_REFERENCE.md](QUICK_REFERENCE.md#-health-checks) |
| Nouvelle clé API | `./wazuh-mcp-manager.sh generate-key` | [GUIDE_FR.md](GUIDE_FR.md#1-générer-une-clé-api) |
| Renouveler token | `./wazuh-mcp-manager.sh get-token <KEY>` | [GUIDE_FR.md](GUIDE_FR.md#renouvellement-du-token) |

### Configuration

| Fichier | Chemin | Contenu |
|---------|--------|---------|
| Config serveur | `/Users/emmanuellignon/Wazuh-MCP-Server/.env` | Credentials Wazuh, ports, clés |
| Config Claude | `~/Library/Application Support/Claude/claude_desktop_config.json` | JWT token, URL serveur |
| Script | `/Users/emmanuellignon/Wazuh-MCP-Server/wazuh-mcp-manager.sh` | Outil de gestion |

### Dépannage

| Problème | Solution | Documentation |
|----------|----------|---------------|
| Serveur ne démarre pas | Voir logs : `./wazuh-mcp-manager.sh logs` | [GUIDE_FR.md](GUIDE_FR.md#le-serveur-ne-démarre-pas) |
| Claude ne voit pas le serveur | Vérifier token et config | [GUIDE_FR.md](GUIDE_FR.md#claude-desktop-ne-voit-pas-le-serveur-mcp) |
| Erreur Wazuh | Vérifier credentials dans .env | [GUIDE_FR.md](GUIDE_FR.md#connection-à-wazuh-échoue) |
| Token expiré | Renouveler (24h) | [GUIDE_FR.md](GUIDE_FR.md#renouvellement-du-token) |

---

## 📱 Accès rapide

### Ouvrir la documentation

```bash
# Dans le terminal
cd /Users/emmanuellignon/Wazuh-MCP-Server

# Ouvrir avec un éditeur
open GUIDE_FR.md              # Guide complet
open QUICK_REFERENCE.md       # Référence rapide
open CONFIGURATION_ACTUELLE.md # Votre config

# Ou lire dans le terminal
cat QUICK_REFERENCE.md | less
```

### URLs importantes

```bash
# Serveur local
http://localhost:3000/health   # Santé
http://localhost:3000/docs     # Documentation API
http://localhost:3000/metrics  # Métriques

# Ouvrir dans le navigateur
open http://localhost:3000/docs
```

---

## 💡 Conseils

### Nouveaux utilisateurs

1. Lisez **GUIDE_FR.md** en entier au moins une fois
2. Gardez **QUICK_REFERENCE.md** ouvert pour les commandes
3. Consultez **CONFIGURATION_ACTUELLE.md** pour vos infos spécifiques
4. Utilisez le script `wazuh-mcp-manager.sh` pour tout

### Utilisateurs expérimentés

- **QUICK_REFERENCE.md** est votre ami
- Créez des alias shell (voir le guide)
- Automatisez le renouvellement du token
- Surveillez les logs régulièrement

### En production

- Lisez la section "Configuration avancée" du **GUIDE_FR.md**
- Configurez Redis pour la scalabilité
- Activez TLS/HTTPS
- Mettez en place du monitoring

---

## 📞 Besoin d'aide ?

### Consultez d'abord

1. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Section dépannage rapide
2. **[GUIDE_FR.md](GUIDE_FR.md)** - Section dépannage détaillé
3. Logs du serveur : `./wazuh-mcp-manager.sh logs`

### Ressources externes

- [GitHub Issues](https://github.com/gensecaihq/Wazuh-MCP-Server/issues)
- [Documentation Wazuh](https://documentation.wazuh.com/)
- [Model Context Protocol](https://modelcontextprotocol.io/)

---

## ✅ Checklist de démarrage

- [ ] J'ai lu l'index (ce fichier)
- [ ] J'ai parcouru GUIDE_FR.md
- [ ] J'ai essayé les commandes de QUICK_REFERENCE.md
- [ ] J'ai vérifié CONFIGURATION_ACTUELLE.md
- [ ] Le serveur démarre : `./wazuh-mcp-manager.sh start`
- [ ] Health check OK : `./wazuh-mcp-manager.sh health`
- [ ] J'ai sauvegardé ma clé API
- [ ] Claude Desktop redémarré
- [ ] Je dois encore configurer les credentials Wazuh réels

---

## 🎓 Parcours d'apprentissage recommandé

### Jour 1 : Installation et découverte
1. Lire GUIDE_FR.md (sections Introduction à Installation)
2. Démarrer le serveur : `./wazuh-mcp-manager.sh start`
3. Tester les commandes de base
4. Vérifier dans Claude Desktop

### Jour 2 : Configuration et personnalisation
1. Configurer les credentials Wazuh réels
2. Explorer les commandes du script
3. Personnaliser .env si nécessaire
4. Créer des alias shell

### Jour 3 : Utilisation et maintenance
1. Utiliser les outils dans Claude Desktop
2. Comprendre le renouvellement de token
3. Mettre en place un monitoring
4. Planifier les sauvegardes

---

**Dernière mise à jour :** 31 janvier 2026
**Version serveur :** 4.0.3
**Statut :** ✅ Documentation complète
