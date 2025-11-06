#!/bin/bash

################################################################################
# AztecAI - Script de Instalación desde GitHub
# 
# Descripción: Descarga el repositorio de GitHub y despliega AztecAI
# Versión: 1.0
# Autor: IAA - Héctor Romero Pico
# Fecha: 6 de Noviembre 2025
#
# Uso: 
#   curl -fsSL https://raw.githubusercontent.com/MLeon28/TVA/main/AztecAI_Model_V1/install_from_github.sh | sudo bash
#   
#   O descargarlo y ejecutarlo:
#   wget https://raw.githubusercontent.com/MLeon28/TVA/main/AztecAI_Model_V1/install_from_github.sh
#   chmod +x install_from_github.sh
#   sudo ./install_from_github.sh
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
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuración
GITHUB_REPO="https://github.com/MLeon28/TVA.git"
GITHUB_BRANCH="main"
INSTALL_BASE_DIR="/opt"
PROJECT_DIR="$INSTALL_BASE_DIR/TVA"
MODEL_DIR="$PROJECT_DIR/AztecAI_Model_V1"
TEMP_DIR="/tmp/aztecai_install"

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
    echo -e "${CYAN}ℹ $1${NC}"
}

################################################################################
# Verificaciones Previas
################################################################################

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Este script debe ejecutarse como root o con sudo"
        exit 1
    fi
    print_success "Ejecutando como root"
}

check_os() {
    print_header "Verificando Sistema Operativo"
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        print_info "OS: $NAME $VERSION"
        
        if [[ "$ID" != "ubuntu" ]]; then
            print_warning "Este script está optimizado para Ubuntu"
            print_warning "Puede funcionar en otras distribuciones Debian-based"
            read -p "¿Continuar de todos modos? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 0
            fi
        fi
    else
        print_warning "No se pudo detectar el sistema operativo"
    fi
}

check_internet() {
    print_header "Verificando Conexión a Internet"
    
    if ping -c 1 github.com &> /dev/null; then
        print_success "Conexión a internet disponible"
    else
        print_error "No hay conexión a internet"
        print_error "Se requiere conexión para descargar el repositorio y dependencias"
        exit 1
    fi
}

check_disk_space() {
    print_header "Verificando Espacio en Disco"
    
    AVAILABLE_GB=$(df -BG "$INSTALL_BASE_DIR" | awk 'NR==2 {print $4}' | sed 's/G//')
    REQUIRED_GB=100
    
    if [[ $AVAILABLE_GB -lt $REQUIRED_GB ]]; then
        print_error "Espacio insuficiente: ${AVAILABLE_GB}GB disponible, ${REQUIRED_GB}GB requerido"
        exit 1
    else
        print_success "Espacio en disco: ${AVAILABLE_GB}GB disponible"
    fi
}

################################################################################
# Instalación de Dependencias Básicas
################################################################################

install_git() {
    print_header "Instalando Git"
    
    if command -v git &> /dev/null; then
        print_success "Git ya está instalado ($(git --version))"
    else
        print_info "Instalando Git..."
        apt update -qq
        apt install -y git > /dev/null 2>&1
        print_success "Git instalado correctamente"
    fi
}

################################################################################
# Descarga del Repositorio
################################################################################

clone_repository() {
    print_header "Descargando Repositorio desde GitHub"
    
    # Limpiar instalación previa si existe
    if [[ -d "$PROJECT_DIR" ]]; then
        print_warning "Directorio $PROJECT_DIR ya existe"
        read -p "¿Deseas eliminarlo y descargar de nuevo? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Eliminando directorio anterior..."
            rm -rf "$PROJECT_DIR"
            print_success "Directorio eliminado"
        else
            print_info "Usando directorio existente"
            return 0
        fi
    fi
    
    # Clonar repositorio
    print_info "Clonando repositorio desde GitHub..."
    print_info "Repositorio: $GITHUB_REPO"
    print_info "Rama: $GITHUB_BRANCH"
    
    cd "$INSTALL_BASE_DIR"
    
    if git clone -b "$GITHUB_BRANCH" "$GITHUB_REPO" TVA; then
        print_success "Repositorio clonado exitosamente"
    else
        print_error "Error al clonar el repositorio"
        exit 1
    fi
    
    # Verificar que existe el directorio del modelo
    if [[ ! -d "$MODEL_DIR" ]]; then
        print_error "No se encontró el directorio AztecAI_Model_V1 en el repositorio"
        print_error "Estructura esperada: TVA/AztecAI_Model_V1/"
        exit 1
    fi
    
    print_success "Directorio del modelo encontrado: $MODEL_DIR"
}

verify_repository_structure() {
    print_header "Verificando Estructura del Repositorio"
    
    REQUIRED_DIRS=(
        "$MODEL_DIR/01_Documentacion"
        "$MODEL_DIR/02_Modelfiles"
        "$MODEL_DIR/03_Knowledge_Base"
        "$MODEL_DIR/04_Scripts"
        "$MODEL_DIR/05_Configuracion"
    )
    
    REQUIRED_FILES=(
        "$MODEL_DIR/04_Scripts/deploy_production.sh"
        "$MODEL_DIR/02_Modelfiles/Modelfile.AztecAI.Professional"
        "$MODEL_DIR/03_Knowledge_Base/AztecAI_Complete_Knowledge_Base.md"
    )
    
    ALL_OK=true
    
    # Verificar directorios
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            print_success "Directorio encontrado: $(basename $dir)"
        else
            print_error "Directorio faltante: $(basename $dir)"
            ALL_OK=false
        fi
    done
    
    # Verificar archivos críticos
    for file in "${REQUIRED_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            print_success "Archivo encontrado: $(basename $file)"
        else
            print_error "Archivo faltante: $(basename $file)"
            ALL_OK=false
        fi
    done
    
    if [[ "$ALL_OK" == false ]]; then
        print_error "Estructura del repositorio incompleta"
        exit 1
    fi
    
    print_success "Estructura del repositorio verificada correctamente"
}

################################################################################
# Ejecución del Script de Despliegue
################################################################################

run_deployment_script() {
    print_header "Ejecutando Script de Despliegue"
    
    DEPLOY_SCRIPT="$MODEL_DIR/04_Scripts/deploy_production.sh"
    
    # Dar permisos de ejecución
    chmod +x "$DEPLOY_SCRIPT"
    
    print_info "Iniciando despliegue automatizado..."
    print_warning "Este proceso puede tomar 30-60 minutos"
    print_warning "Se descargarán aproximadamente 40-50 GB"
    echo ""
    
    # Cambiar al directorio del modelo
    cd "$MODEL_DIR"
    
    # Ejecutar script de despliegue
    if bash "$DEPLOY_SCRIPT"; then
        print_success "Despliegue completado exitosamente"
        return 0
    else
        print_error "Error durante el despliegue"
        print_info "Revisa los logs arriba para más detalles"
        return 1
    fi
}

################################################################################
# Información Final
################################################################################

print_final_info() {
    print_header "Instalación Completada"
    
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}║  ✅ AztecAI instalado correctamente desde GitHub          ║${NC}"
    echo -e "${GREEN}║                                                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}📂 Ubicación de archivos:${NC}"
    echo -e "   Repositorio: $PROJECT_DIR"
    echo -e "   Modelo: $MODEL_DIR"
    echo ""
    
    echo -e "${CYAN}🌐 Acceso al sistema:${NC}"
    echo -e "   OpenWebUI: http://$(hostname -I | awk '{print $1}'):3000"
    echo -e "   Ollama API: http://localhost:11434"
    echo ""
    
    echo -e "${CYAN}🔧 Comandos útiles:${NC}"
    echo -e "   Ver modelos: ${YELLOW}ollama list${NC}"
    echo -e "   Probar modelo: ${YELLOW}ollama run aztecai${NC}"
    echo -e "   Ver logs Ollama: ${YELLOW}journalctl -u ollama -f${NC}"
    echo -e "   Ver logs OpenWebUI: ${YELLOW}docker logs -f open-webui${NC}"
    echo ""
    
    echo -e "${CYAN}📋 Verificación:${NC}"
    echo -e "   Ejecuta: ${YELLOW}cd $MODEL_DIR/04_Scripts && ./verify_installation.sh${NC}"
    echo ""
    
    echo -e "${CYAN}📚 Documentación:${NC}"
    echo -e "   $MODEL_DIR/01_Documentacion/"
    echo ""
    
    echo -e "${YELLOW}⚠️  Próximos pasos:${NC}"
    echo -e "   1. Ejecutar script de verificación"
    echo -e "   2. Acceder a OpenWebUI y crear usuario admin"
    echo -e "   3. Importar Knowledge Base en OpenWebUI"
    echo -e "   4. Configurar Collection 'AztecAI' con RAG"
    echo -e "   5. Realizar pruebas de validación"
    echo ""
    
    echo -e "${GREEN}✨ ¡Instalación exitosa! ✨${NC}"
    echo ""
}

print_error_info() {
    print_header "Error en la Instalación"
    
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                            ║${NC}"
    echo -e "${RED}║  ❌ La instalación no se completó correctamente           ║${NC}"
    echo -e "${RED}║                                                            ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}🔍 Pasos para troubleshooting:${NC}"
    echo ""
    echo -e "1. Revisa los logs arriba para identificar el error"
    echo -e "2. Verifica los requisitos del sistema:"
    echo -e "   - Ubuntu 22.04 LTS"
    echo -e "   - 32GB+ RAM"
    echo -e "   - 100GB+ almacenamiento libre"
    echo -e "   - Conexión a internet estable"
    echo ""
    echo -e "3. Consulta la documentación de troubleshooting:"
    echo -e "   ${CYAN}$MODEL_DIR/01_Documentacion/TROUBLESHOOTING_PRODUCCION.md${NC}"
    echo ""
    echo -e "4. Intenta ejecutar el script de despliegue manualmente:"
    echo -e "   ${CYAN}cd $MODEL_DIR/04_Scripts${NC}"
    echo -e "   ${CYAN}sudo ./deploy_production.sh${NC}"
    echo ""
    echo -e "5. Si el problema persiste, revisa los logs del sistema:"
    echo -e "   ${CYAN}journalctl -xe${NC}"
    echo ""
}

################################################################################
# Función Principal
################################################################################

main() {
    clear
    
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║     AztecAI - Instalación Automatizada desde GitHub       ║"
    echo "║                     Versión 1.0                            ║"
    echo "║                                                            ║"
    echo "║              TV Azteca / Grupo Salinas                     ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    print_info "Este script descargará e instalará AztecAI desde GitHub"
    print_info "Repositorio: $GITHUB_REPO"
    echo ""
    print_warning "Tiempo estimado: 30-60 minutos"
    print_warning "Descarga: ~40-50 GB de datos"
    print_warning "Requiere: Ubuntu 22.04 LTS, 32GB+ RAM, 100GB+ almacenamiento"
    echo ""
    
    read -p "¿Continuar con la instalación? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Instalación cancelada por el usuario"
        exit 0
    fi
    
    echo ""
    
    # Verificaciones previas
    check_root
    check_os
    check_internet
    check_disk_space
    
    # Instalar dependencias básicas
    install_git
    
    # Descargar repositorio
    clone_repository
    verify_repository_structure
    
    # Ejecutar despliegue
    if run_deployment_script; then
        print_final_info
        exit 0
    else
        print_error_info
        exit 1
    fi
}

# Ejecutar
main "$@"

