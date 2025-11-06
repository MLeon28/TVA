#!/bin/bash

################################################################################
# AztecAI - Script de Verificación de Instalación
# 
# Descripción: Valida que todos los componentes estén funcionando correctamente
# Versión: 1.0
# Autor: IAA - Héctor Romero Pico
# Fecha: 5 de Noviembre 2025
#
# Uso: ./verify_installation.sh [--verbose]
################################################################################

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuración
MODEL_NAME="aztecai"
BASE_MODEL="gpt-oss:20b"
OPENWEBUI_PORT=3000
OLLAMA_PORT=11434

VERBOSE=false
[[ "$1" == "--verbose" ]] && VERBOSE=true

TESTS_PASSED=0
TESTS_FAILED=0

################################################################################
# Funciones
################################################################################

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

test_passed() {
    ((TESTS_PASSED++))
    echo -e "${GREEN}✓ PASS:${NC} $1"
}

test_failed() {
    ((TESTS_FAILED++))
    echo -e "${RED}✗ FAIL:${NC} $1"
    [[ "$VERBOSE" == true ]] && [[ -n "$2" ]] && echo -e "  ${YELLOW}Detalle:${NC} $2"
}

test_warning() {
    echo -e "${YELLOW}⚠ WARN:${NC} $1"
}

################################################################################
# Tests
################################################################################

test_ollama_installed() {
    if command -v ollama &> /dev/null; then
        VERSION=$(ollama --version 2>&1)
        test_passed "Ollama está instalado ($VERSION)"
        return 0
    else
        test_failed "Ollama no está instalado"
        return 1
    fi
}

test_ollama_service() {
    if systemctl is-active --quiet ollama 2>/dev/null; then
        test_passed "Servicio Ollama está activo"
        return 0
    elif pgrep -x "ollama" > /dev/null; then
        test_passed "Proceso Ollama está corriendo"
        return 0
    else
        test_failed "Servicio Ollama no está corriendo"
        return 1
    fi
}

test_ollama_port() {
    if nc -z localhost $OLLAMA_PORT 2>/dev/null; then
        test_passed "Puerto Ollama ($OLLAMA_PORT) está escuchando"
        return 0
    else
        test_failed "Puerto Ollama ($OLLAMA_PORT) no responde"
        return 1
    fi
}

test_base_model() {
    if ollama list 2>/dev/null | grep -q "$BASE_MODEL"; then
        SIZE=$(ollama list | grep "$BASE_MODEL" | awk '{print $2}')
        test_passed "Modelo base $BASE_MODEL está disponible ($SIZE)"
        return 0
    else
        test_failed "Modelo base $BASE_MODEL no encontrado"
        return 1
    fi
}

test_custom_model() {
    if ollama list 2>/dev/null | grep -q "$MODEL_NAME"; then
        SIZE=$(ollama list | grep "$MODEL_NAME" | awk '{print $2}')
        test_passed "Modelo personalizado $MODEL_NAME está disponible ($SIZE)"
        return 0
    else
        test_failed "Modelo personalizado $MODEL_NAME no encontrado"
        return 1
    fi
}

test_model_response() {
    echo -e "\n${BLUE}Probando respuesta del modelo...${NC}"
    RESPONSE=$(timeout 30s ollama run $MODEL_NAME "Hola" 2>&1)
    
    if [[ $? -eq 0 ]] && [[ -n "$RESPONSE" ]]; then
        test_passed "Modelo genera respuestas"
        [[ "$VERBOSE" == true ]] && echo -e "  ${YELLOW}Respuesta:${NC} ${RESPONSE:0:100}..."
        return 0
    else
        test_failed "Modelo no responde correctamente" "$RESPONSE"
        return 1
    fi
}

test_model_spanish() {
    echo -e "\n${BLUE}Probando idioma español...${NC}"
    RESPONSE=$(timeout 30s ollama run $MODEL_NAME "¿Hablas español?" 2>&1)
    
    if echo "$RESPONSE" | grep -qi "español\|sí\|claro"; then
        test_passed "Modelo responde en español"
        return 0
    else
        test_warning "Verificar respuestas en español manualmente"
        return 0
    fi
}

test_openwebui_container() {
    if docker ps 2>/dev/null | grep -q "open-webui"; then
        test_passed "Contenedor OpenWebUI está corriendo"
        return 0
    else
        test_failed "Contenedor OpenWebUI no está corriendo"
        return 1
    fi
}

test_openwebui_port() {
    if nc -z localhost $OPENWEBUI_PORT 2>/dev/null; then
        test_passed "Puerto OpenWebUI ($OPENWEBUI_PORT) está escuchando"
        return 0
    elif curl -s -o /dev/null -w "%{http_code}" http://localhost:$OPENWEBUI_PORT 2>/dev/null | grep -q "200\|302"; then
        test_passed "OpenWebUI responde en puerto $OPENWEBUI_PORT"
        return 0
    else
        test_failed "Puerto OpenWebUI ($OPENWEBUI_PORT) no responde"
        return 1
    fi
}

test_openwebui_logs() {
    LOGS=$(docker logs open-webui --tail 50 2>&1)
    
    if echo "$LOGS" | grep -qi "error\|fatal\|exception" && ! echo "$LOGS" | grep -qi "successfully\|started"; then
        test_warning "OpenWebUI tiene errores en logs (revisar con: docker logs open-webui)"
        [[ "$VERBOSE" == true ]] && echo "$LOGS" | grep -i "error" | head -n 3
        return 0
    else
        test_passed "Logs de OpenWebUI sin errores críticos"
        return 0
    fi
}

test_system_resources() {
    # RAM
    TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
    USED_RAM=$(free -g | awk '/^Mem:/{print $3}')
    
    if [[ $TOTAL_RAM -ge 32 ]]; then
        test_passed "RAM total: ${TOTAL_RAM}GB (usado: ${USED_RAM}GB)"
    else
        test_warning "RAM total: ${TOTAL_RAM}GB (recomendado: 32GB+)"
    fi
    
    # Storage
    AVAIL_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $AVAIL_SPACE -ge 50 ]]; then
        test_passed "Espacio disponible: ${AVAIL_SPACE}GB"
    else
        test_warning "Espacio disponible: ${AVAIL_SPACE}GB (bajo)"
    fi
    
    # CPU
    CPU_CORES=$(nproc)
    test_passed "CPU cores: $CPU_CORES"
}

test_network_ports() {
    REQUIRED_PORTS=($OPENWEBUI_PORT $OLLAMA_PORT)
    
    for port in "${REQUIRED_PORTS[@]}"; do
        if ss -tuln | grep -q ":$port "; then
            test_passed "Puerto $port está abierto"
        else
            test_failed "Puerto $port no está abierto"
        fi
    done
}

test_dependencies() {
    REQUIRED_CMDS=("curl" "docker" "python3")
    
    for cmd in "${REQUIRED_CMDS[@]}"; do
        if command -v $cmd &> /dev/null; then
            test_passed "Comando '$cmd' disponible"
        else
            test_failed "Comando '$cmd' no encontrado"
        fi
    done
}

################################################################################
# Performance Tests
################################################################################

test_performance() {
    print_header "Tests de Performance"
    
    echo -e "${BLUE}Midiendo tiempo de primera respuesta...${NC}"
    
    START_TIME=$(date +%s)
    RESPONSE=$(timeout 60s ollama run $MODEL_NAME "Di 'OK'" 2>&1)
    END_TIME=$(date +%s)
    
    DURATION=$((END_TIME - START_TIME))
    
    if [[ $DURATION -le 10 ]]; then
        test_passed "Tiempo de respuesta: ${DURATION}s (excelente)"
    elif [[ $DURATION -le 30 ]]; then
        test_warning "Tiempo de respuesta: ${DURATION}s (aceptable pero lento)"
    else
        test_failed "Tiempo de respuesta: ${DURATION}s (muy lento)" "Verificar recursos del sistema"
    fi
}

################################################################################
# Main
################################################################################

main() {
    clear
    
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║       AztecAI - Verificación de Instalación               ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
    
    # Tests de Sistema
    print_header "Tests de Sistema"
    test_system_resources
    test_dependencies
    test_network_ports
    
    # Tests de Ollama
    print_header "Tests de Ollama"
    test_ollama_installed
    test_ollama_service
    test_ollama_port
    
    # Tests de Modelos
    print_header "Tests de Modelos"
    test_base_model
    test_custom_model
    
    # Tests de Funcionalidad
    print_header "Tests de Funcionalidad"
    test_model_response
    test_model_spanish
    
    # Tests de OpenWebUI
    print_header "Tests de OpenWebUI"
    test_openwebui_container
    test_openwebui_port
    test_openwebui_logs
    
    # Tests de Performance
    if [[ "$VERBOSE" == true ]]; then
        test_performance
    fi
    
    # Resumen
    print_header "Resumen de Tests"
    
    TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
    
    echo -e "  ${GREEN}Tests exitosos:${NC} $TESTS_PASSED / $TOTAL_TESTS"
    echo -e "  ${RED}Tests fallidos:${NC}  $TESTS_FAILED / $TOTAL_TESTS"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                                                            ║${NC}"
        echo -e "${GREEN}║           ✓ TODOS LOS TESTS PASARON                       ║${NC}"
        echo -e "${GREEN}║                                                            ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${GREEN}AztecAI está listo para producción${NC}"
        echo ""
        echo -e "${YELLOW}Próximos pasos:${NC}"
        echo "  1. Importar Knowledge Base en OpenWebUI (3 archivos):"
        echo "     • AztecAI_Complete_Knowledge_Base.md"
        echo "     • TV_Azteca_Informacion_Corporativa.md"
        echo "     • Funcionamiento TV Aztec.md"
        echo "  2. Configurar RAG:"
        echo "     • Crear Collection: AztecAI"
        echo "     • Agregar los 3 documentos a la Collection"
        echo "     • Top-K: 5"
        echo "  3. Verificar embeddings generados"
        echo "  4. Probar con usuarios piloto"
        echo ""
        exit 0
    else
        echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║                                                            ║${NC}"
        echo -e "${RED}║           ✗ ALGUNOS TESTS FALLARON                        ║${NC}"
        echo -e "${RED}║                                                            ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Revisa los errores arriba y consulta:${NC}"
        echo "  • 01_Documentacion/TROUBLESHOOTING_PRODUCCION.md"
        echo "  • Logs de Ollama: journalctl -u ollama"
        echo "  • Logs de OpenWebUI: docker logs open-webui"
        echo ""
        exit 1
    fi
}

main "$@"

