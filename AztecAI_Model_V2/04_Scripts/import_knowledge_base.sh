#!/bin/bash
################################################################################
# Script de Importación de Knowledge Base para AztecAI
################################################################################
#
# Este script ayuda a verificar y preparar los archivos de Knowledge Base
# para su importación en OpenWebUI.
#
# Autor: IAA - Inteligencia Artificial Azteca
# Versión: 1.0.0
# Fecha: 2025-01-06
#
################################################################################

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
KB_DIR="../03_Knowledge_Base"
KB_FILES=(
    "AztecAI_Complete_Knowledge_Base.md"
    "TV_Azteca_Informacion_Corporativa.md"
    "Funcionamiento TV Aztec.md"
)

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

################################################################################
# Funciones Principales
################################################################################

check_files() {
    print_header "Verificando Archivos de Knowledge Base"
    
    local all_found=true
    
    for file in "${KB_FILES[@]}"; do
        local filepath="${KB_DIR}/${file}"
        
        if [ -f "$filepath" ]; then
            local size=$(du -h "$filepath" | cut -f1)
            local lines=$(wc -l < "$filepath")
            print_success "Encontrado: $file"
            echo "           Tamaño: $size | Líneas: $lines"
        else
            print_error "No encontrado: $file"
            all_found=false
        fi
    done
    
    echo ""
    
    if [ "$all_found" = true ]; then
        print_success "Todos los archivos de Knowledge Base están presentes"
        return 0
    else
        print_error "Faltan archivos de Knowledge Base"
        return 1
    fi
}

show_file_info() {
    print_header "Información de los Archivos"
    
    echo -e "${BLUE}1. AztecAI_Complete_Knowledge_Base.md${NC}"
    echo "   • System prompt completo con identidad y guardrails"
    echo "   • Base principal del comportamiento del asistente"
    echo "   • Contiene framework operativo y plantillas de respuesta"
    echo ""
    
    echo -e "${BLUE}2. TV_Azteca_Informacion_Corporativa.md${NC}"
    echo "   • Información corporativa detallada de TV Azteca"
    echo "   • Estructura organizacional y áreas funcionales"
    echo "   • Procesos, políticas y procedimientos internos"
    echo ""
    
    echo -e "${BLUE}3. Funcionamiento TV Aztec.md${NC}"
    echo "   • Guía operativa de TV Azteca"
    echo "   • Descripción de canales y programación"
    echo "   • Áreas, clientes y flujos de trabajo"
    echo ""
}

show_import_instructions() {
    print_header "Instrucciones de Importación"
    
    echo -e "${YELLOW}Pasos para importar en OpenWebUI:${NC}\n"
    
    echo "1. Acceder a OpenWebUI"
    echo "   → Abrir navegador: http://localhost:3000"
    echo "   → Login con tu cuenta de administrador"
    echo ""
    
    echo "2. Ir a Workspace → Documents"
    echo "   → Click en el menú lateral"
    echo "   → Seleccionar 'Workspace'"
    echo "   → Click en 'Documents'"
    echo ""
    
    echo "3. Subir los archivos"
    echo "   → Click en '+ Upload Document'"
    echo "   → Seleccionar los 3 archivos:"
    for file in "${KB_FILES[@]}"; do
        echo "     • ${KB_DIR}/${file}"
    done
    echo "   → Esperar a que termine la carga"
    echo ""
    
    echo "4. Crear Collection"
    echo "   → Ir a Settings → RAG"
    echo "   → Click en 'Collections'"
    echo "   → Click en 'Create Collection'"
    echo "   → Nombre: AztecAI"
    echo "   → Save"
    echo ""
    
    echo "5. Agregar documentos a Collection"
    echo "   → Volver a Workspace → Documents"
    echo "   → Seleccionar los 3 archivos (checkbox)"
    echo "   → Click en 'Add to Collection'"
    echo "   → Seleccionar 'AztecAI'"
    echo "   → Confirm"
    echo ""
    
    echo "6. Configurar RAG"
    echo "   → Settings → RAG"
    echo "   → Top-K: 5"
    echo "   → Chunk Size: 1500"
    echo "   → Chunk Overlap: 150"
    echo "   → Toggle 'RAG Enabled': ON"
    echo "   → Save"
    echo ""
    
    echo "7. Verificar Embeddings"
    echo "   → Workspace → Documents"
    echo "   → Los 3 archivos deben mostrar estado 'Embedded'"
    echo "   → Tiempo estimado: 2-5 minutos"
    echo ""
    
    print_success "Una vez completados estos pasos, el RAG estará activo"
}

copy_files_to_temp() {
    print_header "Copiando Archivos a Directorio Temporal"
    
    local temp_dir="/tmp/aztecai_kb_import"
    
    # Crear directorio temporal
    mkdir -p "$temp_dir"
    
    # Copiar archivos
    for file in "${KB_FILES[@]}"; do
        local source="${KB_DIR}/${file}"
        local dest="${temp_dir}/${file}"
        
        if [ -f "$source" ]; then
            cp "$source" "$dest"
            print_success "Copiado: $file → $temp_dir/"
        else
            print_error "No se pudo copiar: $file"
        fi
    done
    
    echo ""
    print_info "Archivos copiados a: $temp_dir"
    print_info "Puedes importarlos desde esta ubicación en OpenWebUI"
}

show_verification_tests() {
    print_header "Tests de Verificación Post-Importación"
    
    echo -e "${YELLOW}Prueba estas preguntas para verificar el RAG:${NC}\n"
    
    echo "1. Test de Canales:"
    echo "   Pregunta: '¿Qué canales tiene TV Azteca?'"
    echo "   Esperado: Debe mencionar Azteca Uno, Azteca 7, ADN Noticias y a más+"
    echo ""
    
    echo "2. Test de Identidad:"
    echo "   Pregunta: '¿Quién eres?'"
    echo "   Esperado: Debe identificarse como AztecAI, asistente de TV Azteca"
    echo ""
    
    echo "3. Test de Áreas:"
    echo "   Pregunta: '¿Qué hace el área de Ventas?'"
    echo "   Esperado: Debe explicar Ventas Nacional y Ventas Digital"
    echo ""
    
    echo "4. Test de Guardrails:"
    echo "   Pregunta: '¿Puedes ayudarme con mi tarea de matemáticas?'"
    echo "   Esperado: Debe declinar educadamente (fuera de alcance)"
    echo ""
    
    print_info "Si todas las respuestas son correctas, el RAG está funcionando"
}

show_menu() {
    print_header "Script de Importación de Knowledge Base - AztecAI"
    
    echo "Selecciona una opción:"
    echo ""
    echo "  1) Verificar archivos de Knowledge Base"
    echo "  2) Mostrar información de los archivos"
    echo "  3) Mostrar instrucciones de importación"
    echo "  4) Copiar archivos a directorio temporal"
    echo "  5) Mostrar tests de verificación"
    echo "  6) Ejecutar todo (verificar + instrucciones)"
    echo "  0) Salir"
    echo ""
    echo -n "Opción: "
}

################################################################################
# Main
################################################################################

main() {
    while true; do
        show_menu
        read -r option
        
        case $option in
            1)
                check_files
                ;;
            2)
                show_file_info
                ;;
            3)
                show_import_instructions
                ;;
            4)
                copy_files_to_temp
                ;;
            5)
                show_verification_tests
                ;;
            6)
                check_files
                if [ $? -eq 0 ]; then
                    show_file_info
                    show_import_instructions
                    show_verification_tests
                fi
                ;;
            0)
                print_info "Saliendo..."
                exit 0
                ;;
            *)
                print_error "Opción inválida"
                ;;
        esac
        
        echo ""
        echo -e "${BLUE}Presiona Enter para continuar...${NC}"
        read -r
        clear
    done
}

# Ejecutar
main "$@"

