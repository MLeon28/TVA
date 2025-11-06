#!/bin/bash

################################################################################
# AztecAI - Instalación Rápida desde GitHub
# 
# Descripción: Script simplificado para instalación rápida
# Versión: 1.0
# Uso: sudo bash quick_install.sh
################################################################################

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         AztecAI - Instalación Rápida desde GitHub         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# Verificar root
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}⚠ Este script debe ejecutarse con sudo${NC}"
    exit 1
fi

echo -e "${BLUE}[1/5]${NC} Instalando Git..."
apt update -qq && apt install -y git > /dev/null 2>&1
echo -e "${GREEN}✓ Git instalado${NC}"

echo -e "${BLUE}[2/5]${NC} Clonando repositorio desde GitHub..."
cd /opt
if [[ -d "TVA" ]]; then
    echo -e "${YELLOW}⚠ Directorio TVA ya existe, actualizando...${NC}"
    cd TVA && git pull
else
    git clone https://github.com/MLeon28/TVA.git
fi
echo -e "${GREEN}✓ Repositorio descargado${NC}"

echo -e "${BLUE}[3/5]${NC} Verificando estructura..."
if [[ ! -f "/opt/TVA/AztecAI_Model_V1/04_Scripts/deploy_production.sh" ]]; then
    echo -e "${YELLOW}✗ Error: No se encontró el script de despliegue${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Estructura verificada${NC}"

echo -e "${BLUE}[4/5]${NC} Dando permisos de ejecución..."
chmod +x /opt/TVA/AztecAI_Model_V1/04_Scripts/*.sh
echo -e "${GREEN}✓ Permisos configurados${NC}"

echo -e "${BLUE}[5/5]${NC} Ejecutando despliegue automatizado..."
echo -e "${YELLOW}⚠ Este proceso tomará 30-60 minutos${NC}\n"

cd /opt/TVA/AztecAI_Model_V1/04_Scripts
bash deploy_production.sh

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✅ Instalación Completada                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📂 Ubicación:${NC} /opt/TVA/AztecAI_Model_V1"
echo -e "${BLUE}🌐 Acceso:${NC} http://$(hostname -I | awk '{print $1}'):3000"
echo -e "${BLUE}🔧 Verificar:${NC} cd /opt/TVA/AztecAI_Model_V1/04_Scripts && ./verify_installation.sh"
echo ""

