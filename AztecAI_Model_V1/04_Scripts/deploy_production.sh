#!/bin/bash

################################################################################
# AztecAI - Script de Despliegue en Producción
# 
# Descripción: Instalación automatizada completa de AztecAI en servidor
# Versión: 2.0
# Autor: IAA - Héctor Romero Pico
# Fecha: 5 de Noviembre 2025
#
# Uso: sudo ./deploy_production.sh
#
# Requisitos:
# - Ubuntu 22.04 LTS
# - Acceso root/sudo
# - 32GB+ RAM
# - 100GB+ almacenamiento
# - Conexión a internet
################################################################################

set -e  # Exit on error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
INSTALL_DIR="/opt/aztecai"
MODEL_NAME="aztecai"
BASE_MODEL="gpt-oss:20b"
OPENWEBUI_PORT=3000
OLLAMA_PORT=11434

################################################################################
# Funciones de Utilidad
################################################################################

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Este script debe ejecutarse como root (usa sudo)"
        exit 1
    fi
}

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "No se puede detectar el sistema operativo"
        exit 1
    fi
    
    source /etc/os-release
    
    if [[ "$ID" != "ubuntu" ]]; then
        print_warning "Sistema operativo: $ID (recomendamos Ubuntu 22.04 LTS)"
        read -p "¿Continuar de todas formas? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "Sistema operativo: Ubuntu $VERSION_ID"
    fi
}

check_resources() {
    print_header "Verificando Recursos del Sistema"
    
    # RAM
    TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
    if [[ $TOTAL_RAM -lt 32 ]]; then
        print_warning "RAM: ${TOTAL_RAM}GB (recomendado: 32GB+)"
        read -p "¿Continuar de todas formas? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "RAM: ${TOTAL_RAM}GB"
    fi
    
    # Almacenamiento
    AVAIL_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $AVAIL_SPACE -lt 100 ]]; then
        print_error "Espacio disponible: ${AVAIL_SPACE}GB (mínimo: 100GB)"
        exit 1
    else
        print_success "Espacio disponible: ${AVAIL_SPACE}GB"
    fi
    
    # CPU cores
    CPU_CORES=$(nproc)
    if [[ $CPU_CORES -lt 8 ]]; then
        print_warning "CPU cores: $CPU_CORES (recomendado: 8+)"
    else
        print_success "CPU cores: $CPU_CORES"
    fi
}

check_ports() {
    print_header "Verificando Puertos Disponibles"
    
    for port in $OPENWEBUI_PORT $OLLAMA_PORT; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            print_error "Puerto $port ya está en uso"
            exit 1
        else
            print_success "Puerto $port disponible"
        fi
    done
}

################################################################################
# Instalación de Dependencias
################################################################################

install_dependencies() {
    print_header "Instalando Dependencias del Sistema"
    
    print_info "Actualizando repositorios..."
    apt update -qq
    
    print_info "Instalando paquetes base..."
    apt install -y \
        curl \
        wget \
        git \
        build-essential \
        python3 \
        python3-pip \
        htop \
        vim \
        tmux \
        jq \
        > /dev/null 2>&1
    
    print_success "Dependencias instaladas"
}

################################################################################
# Instalación de Ollama
################################################################################

install_ollama() {
    print_header "Instalando Ollama"
    
    if command -v ollama &> /dev/null; then
        print_warning "Ollama ya está instalado"
        ollama --version
    else
        print_info "Descargando e instalando Ollama..."
        curl -fsSL https://ollama.ai/install.sh | sh
        print_success "Ollama instalado"
    fi
    
    # Verificar que Ollama esté corriendo
    print_info "Verificando servicio de Ollama..."
    sleep 2
    
    if systemctl is-active --quiet ollama; then
        print_success "Servicio Ollama activo"
    else
        print_warning "Iniciando servicio Ollama..."
        systemctl start ollama
        sleep 2
        
        if systemctl is-active --quiet ollama; then
            print_success "Servicio Ollama iniciado"
        else
            print_error "No se pudo iniciar Ollama"
            exit 1
        fi
    fi
}

################################################################################
# Descarga y Creación del Modelo
################################################################################

download_base_model() {
    print_header "Descargando Modelo Base"
    
    print_warning "Este proceso descargará ~40-50 GB y puede tomar 30-60 minutos"
    print_info "Por favor, no interrumpas el proceso..."
    
    ollama pull $BASE_MODEL
    
    if ollama list | grep -q "$BASE_MODEL"; then
        print_success "Modelo base $BASE_MODEL descargado"
    else
        print_error "Fallo al descargar modelo base"
        exit 1
    fi
}

create_custom_model() {
    print_header "Creando Modelo Personalizado AztecAI"
    
    # Buscar Modelfile
    MODELFILE_PATH=""
    
    # Intentar varias ubicaciones
    if [[ -f "../02_Modelfiles/Modelfile.AztecAI.Professional" ]]; then
        MODELFILE_PATH="../02_Modelfiles/Modelfile.AztecAI.Professional"
    elif [[ -f "$INSTALL_DIR/02_Modelfiles/Modelfile.AztecAI.Professional" ]]; then
        MODELFILE_PATH="$INSTALL_DIR/02_Modelfiles/Modelfile.AztecAI.Professional"
    elif [[ -f "/opt/AztecAI_Model/02_Modelfiles/Modelfile.AztecAI.Professional" ]]; then
        MODELFILE_PATH="/opt/AztecAI_Model/02_Modelfiles/Modelfile.AztecAI.Professional"
    else
        print_error "No se encontró Modelfile.AztecAI.Professional"
        print_info "Búscalo manualmente y ejecuta:"
        print_info "  ollama create $MODEL_NAME -f /ruta/al/Modelfile"
        exit 1
    fi
    
    print_info "Usando Modelfile: $MODELFILE_PATH"
    print_info "Creando modelo personalizado..."
    
    ollama create $MODEL_NAME -f "$MODELFILE_PATH"
    
    if ollama list | grep -q "$MODEL_NAME"; then
        print_success "Modelo $MODEL_NAME creado exitosamente"
    else
        print_error "Fallo al crear modelo personalizado"
        exit 1
    fi
}

################################################################################
# Instalación de OpenWebUI
################################################################################

install_openwebui() {
    print_header "Instalando OpenWebUI"
    
    print_info "Instalando vía Docker..."
    
    # Verificar si Docker está instalado
    if ! command -v docker &> /dev/null; then
        print_info "Docker no encontrado, instalando..."
        apt install -y docker.io
        systemctl start docker
        systemctl enable docker
        print_success "Docker instalado"
    fi
    
    # Detener contenedor existente si lo hay
    if docker ps -a | grep -q open-webui; then
        print_warning "Contenedor open-webui existente encontrado, removiendo..."
        docker stop open-webui 2>/dev/null || true
        docker rm open-webui 2>/dev/null || true
    fi
    
    # Ejecutar OpenWebUI
    print_info "Iniciando OpenWebUI en puerto $OPENWEBUI_PORT..."
    
    docker run -d \
        --name open-webui \
        --restart always \
        -p $OPENWEBUI_PORT:8080 \
        -v open-webui:/app/backend/data \
        --add-host=host.docker.internal:host-gateway \
        ghcr.io/open-webui/open-webui:main
    
    sleep 5
    
    if docker ps | grep -q open-webui; then
        print_success "OpenWebUI instalado y corriendo en puerto $OPENWEBUI_PORT"
    else
        print_error "Fallo al iniciar OpenWebUI"
        docker logs open-webui
        exit 1
    fi
}

################################################################################
# Configuración
################################################################################

configure_firewall() {
    print_header "Configurando Firewall"
    
    if command -v ufw &> /dev/null; then
        print_info "Configurando UFW..."
        
        # Asegurar que SSH esté permitido
        ufw allow 22/tcp comment 'SSH' 2>/dev/null || true
        
        # Permitir OpenWebUI
        ufw allow $OPENWEBUI_PORT/tcp comment 'OpenWebUI' 2>/dev/null || true
        
        # Permitir HTTP/HTTPS (para Nginx después)
        ufw allow 80/tcp comment 'HTTP' 2>/dev/null || true
        ufw allow 443/tcp comment 'HTTPS' 2>/dev/null || true
        
        print_success "Firewall configurado"
    else
        print_warning "UFW no encontrado, configura firewall manualmente"
    fi
}

create_systemd_services() {
    print_header "Configurando Servicios Systemd"
    
    # Ollama ya viene con su servicio
    print_info "Habilitando servicio Ollama..."
    systemctl enable ollama
    
    print_success "Servicios systemd configurados"
}

################################################################################
# Verificación Final
################################################################################

verify_installation() {
    print_header "Verificando Instalación"
    
    # Verificar Ollama
    if systemctl is-active --quiet ollama; then
        print_success "Ollama: Activo"
    else
        print_error "Ollama: Inactivo"
    fi
    
    # Verificar modelo
    if ollama list | grep -q "$MODEL_NAME"; then
        print_success "Modelo $MODEL_NAME: Disponible"
    else
        print_error "Modelo $MODEL_NAME: No encontrado"
    fi
    
    # Verificar OpenWebUI
    if docker ps | grep -q open-webui; then
        print_success "OpenWebUI: Corriendo"
    else
        print_error "OpenWebUI: No corriendo"
    fi
    
    # Test básico del modelo
    print_info "Probando modelo con pregunta simple..."
    TEST_RESPONSE=$(ollama run $MODEL_NAME "Hola, ¿estás funcionando?" --verbose 2>&1 | head -n 5)
    
    if [[ -n "$TEST_RESPONSE" ]]; then
        print_success "Modelo responde correctamente"
    else
        print_warning "Modelo no respondió, verificar manualmente"
    fi
}

################################################################################
# Información Final
################################################################################

print_final_info() {
    print_header "Instalación Completada"
    
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║        ✓ AztecAI Instalado Exitosamente                   ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "\n${BLUE}📊 Información de Acceso:${NC}\n"
    
    SERVER_IP=$(hostname -I | awk '{print $1}')
    
    echo -e "  ${GREEN}OpenWebUI:${NC}"
    echo -e "    • URL local:   ${BLUE}http://localhost:$OPENWEBUI_PORT${NC}"
    echo -e "    • URL red:     ${BLUE}http://$SERVER_IP:$OPENWEBUI_PORT${NC}"
    echo ""
    echo -e "  ${GREEN}Ollama:${NC}"
    echo -e "    • Puerto:      ${BLUE}$OLLAMA_PORT${NC}"
    echo -e "    • Modelo:      ${BLUE}$MODEL_NAME${NC}"
    echo ""
    
    echo -e "\n${YELLOW}📋 Próximos Pasos:${NC}\n"
    echo "  1. Accede a OpenWebUI en tu navegador"
    echo "  2. Crea tu cuenta de administrador"
    echo "  3. Importa Knowledge Base:"
    echo "     • Workspace → Documents"
    echo "     • Subir: AztecAI_Complete_Knowledge_Base.md"
    echo "  4. Configura RAG:"
    echo "     • Settings → RAG"
    echo "     • Create Collection: AztecAI"
    echo "     • Top-K: 5"
    echo "  5. Prueba el modelo con:"
    echo "     '¿Qué canales tiene TV Azteca?'"
    echo ""
    
    echo -e "\n${YELLOW}🔧 Comandos Útiles:${NC}\n"
    echo "  Ver logs Ollama:      journalctl -u ollama -f"
    echo "  Ver logs OpenWebUI:   docker logs -f open-webui"
    echo "  Reiniciar Ollama:     systemctl restart ollama"
    echo "  Reiniciar OpenWebUI:  docker restart open-webui"
    echo "  Probar modelo:        ollama run $MODEL_NAME"
    echo ""
    
    echo -e "\n${YELLOW}📖 Documentación:${NC}\n"
    echo "  Ver: /opt/AztecAI_Model/01_Documentacion/"
    echo ""
    
    echo -e "${GREEN}¡Instalación completada con éxito!${NC}\n"
}

################################################################################
# Main
################################################################################

main() {
    clear
    
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║        AztecAI - Script de Despliegue en Producción       ║"
    echo "║                     Versión 2.0                            ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    print_warning "Este script instalará AztecAI en tu servidor"
    print_warning "Tiempo estimado: 30-60 minutos"
    print_warning "Se descargará ~40-50 GB de datos"
    echo ""
    read -p "¿Continuar con la instalación? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Instalación cancelada"
        exit 0
    fi
    
    # Pre-checks
    check_root
    check_os
    check_resources
    check_ports
    
    # Instalación
    install_dependencies
    install_ollama
    download_base_model
    create_custom_model
    install_openwebui
    
    # Configuración
    configure_firewall
    create_systemd_services
    
    # Verificación
    verify_installation
    
    # Info final
    print_final_info
}

# Ejecutar
main "$@"

