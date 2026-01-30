#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
#  AZTECAI - CREACIÓN AUTOMÁTICA DE MODELO CON DOCUMENTOS CORPORATIVOS
# ═══════════════════════════════════════════════════════════════════════════

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "═══════════════════════════════════════════════════════════════════════════"
echo "  AZTECAI - CREACIÓN AUTOMÁTICA DE MODELO CON DOCUMENTOS CORPORATIVOS"
echo "═══════════════════════════════════════════════════════════════════════════"
echo -e "${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# PASO 1: Verificar archivos necesarios
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${BLUE}[1/6] Verificando archivos necesarios...${NC}"

archivos_requeridos=(
    "Modelfile.AztecAI.optimized"
    "Funcionamiento_tv_azteca.md"
    "Empresas_del_grupo.md"
    "Capital_Humano_e_historia.md"
)

error=0
for archivo in "${archivos_requeridos[@]}"; do
    if [ -f "$archivo" ]; then
        echo -e "  ${GREEN}✓${NC} $archivo"
    else
        echo -e "  ${RED}✗${NC} $archivo ${RED}NO ENCONTRADO${NC}"
        error=1
    fi
done

if [ $error -eq 1 ]; then
    echo -e "\n${RED}ERROR: Faltan archivos necesarios${NC}"
    exit 1
fi

echo -e "  ${GREEN}✓${NC} Todos los archivos encontrados"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# PASO 2: Verificar instalación de Ollama
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${BLUE}[2/6] Verificando instalación de Ollama...${NC}"

if ! command -v ollama &> /dev/null; then
    echo -e "  ${RED}✗ Ollama no está instalado${NC}"
    echo -e "  ${YELLOW}Instalar desde: https://ollama.ai/download${NC}"
    exit 1
fi

version=$(ollama --version 2>&1)
echo -e "  ${GREEN}✓${NC} Ollama instalado: $version"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# PASO 3: Leer archivos
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${BLUE}[3/6] Leyendo archivos...${NC}"

modelfile_base=$(cat "Modelfile.AztecAI.optimized")
lineas_base=$(wc -l < "Modelfile.AztecAI.optimized")
echo -e "  ${GREEN}✓${NC} Modelfile.AztecAI.optimized ($lineas_base líneas)"

doc1=$(cat "Funcionamiento_tv_azteca.md")
lineas_doc1=$(wc -l < "Funcionamiento_tv_azteca.md")
echo -e "  ${GREEN}✓${NC} Funcionamiento_tv_azteca.md ($lineas_doc1 líneas)"

doc2=$(cat "Empresas_del_grupo.md")
lineas_doc2=$(wc -l < "Empresas_del_grupo.md")
echo -e "  ${GREEN}✓${NC} Empresas_del_grupo.md ($lineas_doc2 líneas)"

doc3=$(cat "Capital_Humano_e_historia.md")
lineas_doc3=$(wc -l < "Capital_Humano_e_historia.md")
echo -e "  ${GREEN}✓${NC} Capital_Humano_e_historia.md ($lineas_doc3 líneas)"

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# PASO 4: Construir Modelfile completo
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${BLUE}[4/6] Construyendo Modelfile completo con documentos...${NC}"

# Crear archivo temporal
cat > Modelfile.AztecAI.full << 'EOF'
EOF

# Agregar Modelfile base
echo "$modelfile_base" >> Modelfile.AztecAI.full

# Agregar documentos como MESSAGE system
echo "" >> Modelfile.AztecAI.full
echo "# ═══════════════════════════════════════════════════════════════════════════" >> Modelfile.AztecAI.full
echo "# DOCUMENTOS CORPORATIVOS CARGADOS EN CONTEXTO" >> Modelfile.AztecAI.full
echo "# ═══════════════════════════════════════════════════════════════════════════" >> Modelfile.AztecAI.full
echo "" >> Modelfile.AztecAI.full

# Documento 1
echo 'MESSAGE system """' >> Modelfile.AztecAI.full
echo "DOCUMENTO 1: FUNCIONAMIENTO DE TV AZTECA" >> Modelfile.AztecAI.full
echo "" >> Modelfile.AztecAI.full
echo "$doc1" >> Modelfile.AztecAI.full
echo '"""' >> Modelfile.AztecAI.full
echo "" >> Modelfile.AztecAI.full

# Documento 2
echo 'MESSAGE system """' >> Modelfile.AztecAI.full
echo "DOCUMENTO 2: EMPRESAS DEL GRUPO SALINAS" >> Modelfile.AztecAI.full
echo "" >> Modelfile.AztecAI.full
echo "$doc2" >> Modelfile.AztecAI.full
echo '"""' >> Modelfile.AztecAI.full
echo "" >> Modelfile.AztecAI.full

# Documento 3
echo 'MESSAGE system """' >> Modelfile.AztecAI.full
echo "DOCUMENTO 3: CAPITAL HUMANO E HISTORIA DE TV AZTECA" >> Modelfile.AztecAI.full
echo "" >> Modelfile.AztecAI.full
echo "$doc3" >> Modelfile.AztecAI.full
echo '"""' >> Modelfile.AztecAI.full

lineas_total=$(wc -l < "Modelfile.AztecAI.full")
echo -e "  ${GREEN}✓${NC} Modelfile.AztecAI.full creado ($lineas_total líneas)"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# PASO 5: Crear modelo en Ollama
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${BLUE}[5/6] Creando modelo en Ollama...${NC}"
echo -e "  ${YELLOW}Esto puede tomar varios minutos...${NC}"
echo ""

ollama create aztecai:full -f Modelfile.AztecAI.full

if [ $? -eq 0 ]; then
    echo ""
    echo -e "  ${GREEN}✓${NC} Modelo 'aztecai:full' creado exitosamente"
else
    echo ""
    echo -e "  ${RED}✗${NC} Error al crear el modelo"
    exit 1
fi

echo ""

# ═══════════════════════════════════════════════════════════════════════════
# PASO 6: Test rápido
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${BLUE}[6/6] Ejecutando test rápido...${NC}"
echo -e "  Pregunta: ¿Quién eres? Responde en máximo 3 líneas."
echo ""

respuesta=$(echo "¿Quién eres? Responde en máximo 3 líneas." | ollama run aztecai:full 2>/dev/null)

echo -e "${CYAN}┌─────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│ 🇲🇽 AztecAI                                                     │${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo "$respuesta"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# FINALIZACIÓN
# ═══════════════════════════════════════════════════════════════════════════

echo -e "${CYAN}"
echo "═══════════════════════════════════════════════════════════════════════════"
echo "  ✓ PROCESO COMPLETADO EXITOSAMENTE"
echo "═══════════════════════════════════════════════════════════════════════════"
echo -e "${NC}"
echo ""
echo -e "Modelo creado: ${GREEN}aztecai:full${NC}"
echo ""
echo "Para usar el modelo:"
echo -e "  ${YELLOW}ollama run aztecai:full${NC}"
echo ""

