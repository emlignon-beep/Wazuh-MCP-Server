#!/bin/bash
# Script de gestion du serveur MCP Wazuh
# Usage: ./wazuh-mcp-manager.sh [commande]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function show_help() {
    echo -e "${BLUE}=== Gestionnaire du serveur MCP Wazuh ===${NC}\n"
    echo "Usage: $0 [commande]"
    echo ""
    echo "Commandes disponibles:"
    echo "  start           - Démarrer le serveur"
    echo "  stop            - Arrêter le serveur"
    echo "  restart         - Redémarrer le serveur"
    echo "  status          - Afficher le statut du serveur"
    echo "  logs            - Afficher les logs en temps réel"
    echo "  health          - Vérifier la santé du serveur"
    echo "  generate-key    - Générer une nouvelle clé API"
    echo "  get-token       - Obtenir un JWT token (requiert une clé API)"
    echo "  update-config   - Mettre à jour la configuration Claude Desktop"
    echo "  edit-env        - Éditer le fichier .env"
    echo "  rebuild         - Reconstruire et redémarrer le conteneur"
    echo ""
}

function start_server() {
    echo -e "${BLUE}🚀 Démarrage du serveur MCP Wazuh...${NC}"
    docker compose up -d --wait
    echo -e "${GREEN}✅ Serveur démarré avec succès${NC}"
    health_check
}

function stop_server() {
    echo -e "${YELLOW}⏹️  Arrêt du serveur MCP Wazuh...${NC}"
    docker compose stop
    echo -e "${GREEN}✅ Serveur arrêté${NC}"
}

function restart_server() {
    echo -e "${BLUE}🔄 Redémarrage du serveur MCP Wazuh...${NC}"
    docker compose restart
    sleep 3
    echo -e "${GREEN}✅ Serveur redémarré${NC}"
    health_check
}

function show_status() {
    echo -e "${BLUE}📊 Statut du serveur:${NC}\n"
    docker compose ps
}

function show_logs() {
    echo -e "${BLUE}📜 Logs du serveur (Ctrl+C pour quitter):${NC}\n"
    docker compose logs -f wazuh-mcp-remote-server
}

function health_check() {
    echo -e "\n${BLUE}🏥 Vérification de santé:${NC}\n"
    curl -s http://localhost:3000/health | jq '.'
}

function generate_api_key() {
    echo -e "${BLUE}🔑 Génération d'une nouvelle clé API...${NC}\n"

    API_KEY=$(docker compose exec -T wazuh-mcp-remote-server python -c "
import secrets
api_key = 'wazuh_' + secrets.token_urlsafe(32)
print(api_key)
" 2>/dev/null | tail -1)

    echo -e "${GREEN}✅ Clé API générée:${NC}"
    echo -e "${YELLOW}${API_KEY}${NC}"
    echo ""
    echo -e "${RED}⚠️  IMPORTANT: Sauvegardez cette clé en lieu sûr!${NC}"
    echo ""
    echo "Pour obtenir un JWT token, exécutez:"
    echo "  $0 get-token $API_KEY"
}

function get_jwt_token() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ Erreur: Clé API requise${NC}"
        echo "Usage: $0 get-token <API_KEY>"
        exit 1
    fi

    API_KEY="$1"
    echo -e "${BLUE}🎫 Obtention du JWT token...${NC}\n"

    RESPONSE=$(curl -s -X POST http://localhost:3000/auth/token \
        -H "Content-Type: application/json" \
        -d "{\"api_key\": \"$API_KEY\"}")

    TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')

    if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
        echo -e "${GREEN}✅ JWT Token obtenu:${NC}"
        echo -e "${YELLOW}${TOKEN}${NC}"
        echo ""
        echo "Pour mettre à jour la configuration Claude Desktop:"
        echo "  $0 update-config $TOKEN"
    else
        echo -e "${RED}❌ Erreur lors de l'obtention du token${NC}"
        echo "$RESPONSE" | jq '.'
        exit 1
    fi
}

function update_claude_config() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ Erreur: JWT token requis${NC}"
        echo "Usage: $0 update-config <JWT_TOKEN>"
        exit 1
    fi

    TOKEN="$1"
    CONFIG_FILE="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

    echo -e "${BLUE}📝 Mise à jour de la configuration Claude Desktop...${NC}"

    cat > "$CONFIG_FILE" << EOF
{
  "mcpServers": {
    "wazuh": {
      "transport": {
        "type": "sse",
        "url": "http://localhost:3000/sse"
      },
      "headers": {
        "Authorization": "Bearer $TOKEN"
      }
    }
  }
}
EOF

    echo -e "${GREEN}✅ Configuration mise à jour: $CONFIG_FILE${NC}"
    echo -e "${YELLOW}⚠️  Redémarrez Claude Desktop pour appliquer les changements${NC}"
}

function edit_env() {
    echo -e "${BLUE}📝 Édition du fichier .env...${NC}\n"

    if [ -n "$EDITOR" ]; then
        $EDITOR .env
    elif command -v nano &> /dev/null; then
        nano .env
    elif command -v vim &> /dev/null; then
        vim .env
    else
        echo -e "${YELLOW}Aucun éditeur trouvé. Utilisez: nano .env ou vim .env${NC}"
    fi
}

function rebuild_server() {
    echo -e "${BLUE}🔨 Reconstruction et redémarrage du serveur...${NC}"
    docker compose down
    docker compose build --no-cache
    docker compose up -d --wait
    echo -e "${GREEN}✅ Serveur reconstruit et démarré${NC}"
    health_check
}

# Menu principal
case "${1:-help}" in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    restart)
        restart_server
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    health)
        health_check
        ;;
    generate-key)
        generate_api_key
        ;;
    get-token)
        get_jwt_token "$2"
        ;;
    update-config)
        update_claude_config "$2"
        ;;
    edit-env)
        edit_env
        ;;
    rebuild)
        rebuild_server
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ Commande inconnue: $1${NC}\n"
        show_help
        exit 1
        ;;
esac
