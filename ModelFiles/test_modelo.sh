#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
#  SUITE DE TESTS - AZTECAI
# ═══════════════════════════════════════════════════════════════════════════

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Modelo a probar (puede pasarse como parámetro)
MODELO="${1:-aztecai:full}"

echo -e "${CYAN}"
echo "═══════════════════════════════════════════════════════════════════════════"
echo "  SUITE DE TESTS - AZTECAI"
echo "═══════════════════════════════════════════════════════════════════════════"
echo -e "${NC}"
echo ""
echo "Modelo a probar: $MODELO"
echo ""

# Verificar que el modelo existe
echo "Verificando que el modelo existe..."
if ! ollama list | grep -q "$MODELO"; then
    echo -e "${RED}✗ Modelo '$MODELO' no encontrado${NC}"
    echo "Modelos disponibles:"
    ollama list
    exit 1
fi
echo -e "${GREEN}✓${NC} Modelo encontrado"
echo ""

# Contadores
tests_pasados=0
tests_fallidos=0

# ═══════════════════════════════════════════════════════════════════════════
# TEST 1: Identidad y Desarrollador
# ═══════════════════════════════════════════════════════════════════════════

echo "───────────────────────────────────────────────────────────────────────────"
echo "TEST: 1. Identidad y Desarrollador"
echo "───────────────────────────────────────────────────────────────────────────"
echo ""

pregunta="¿Quién eres y quién te desarrolló?"
echo "Pregunta: $pregunta"
echo ""
echo "Respuesta:"

respuesta=$(echo "$pregunta" | ollama run "$MODELO" 2>/dev/null)
echo "$respuesta"
echo ""

# Validar palabras clave
echo "Validando palabras clave esperadas:"
test_ok=1

if echo "$respuesta" | grep -qi "AztecAI"; then
    echo -e "  ${GREEN}✓${NC} Encontrado: 'AztecAI'"
else
    echo -e "  ${RED}✗${NC} No encontrado: 'AztecAI'"
    test_ok=0
fi

if echo "$respuesta" | grep -qi "TV Azteca"; then
    echo -e "  ${GREEN}✓${NC} Encontrado: 'TV Azteca'"
else
    echo -e "  ${RED}✗${NC} No encontrado: 'TV Azteca'"
    test_ok=0
fi

echo ""
if [ $test_ok -eq 1 ]; then
    echo -e "RESULTADO: ${GREEN}✓ PASÓ${NC}"
    ((tests_pasados++))
else
    echo -e "RESULTADO: ${RED}✗ FALLÓ${NC}"
    ((tests_fallidos++))
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TEST 2: Conocimiento Corporativo
# ═══════════════════════════════════════════════════════════════════════════

echo "───────────────────────────────────────────────────────────────────────────"
echo "TEST: 2. Conocimiento Corporativo"
echo "───────────────────────────────────────────────────────────────────────────"
echo ""

pregunta="¿Cuáles son los canales de TV Azteca? Lista solo los nombres."
echo "Pregunta: $pregunta"
echo ""
echo "Respuesta:"

respuesta=$(echo "$pregunta" | ollama run "$MODELO" 2>/dev/null)
echo "$respuesta"
echo ""

echo "Validando canales esperados:"
test_ok=1

if echo "$respuesta" | grep -qi "Azteca Uno\|Azteca 1"; then
    echo -e "  ${GREEN}✓${NC} Encontrado: 'Azteca Uno'"
else
    echo -e "  ${RED}✗${NC} No encontrado: 'Azteca Uno'"
    test_ok=0
fi

if echo "$respuesta" | grep -qi "Azteca 7\|Azteca Siete"; then
    echo -e "  ${GREEN}✓${NC} Encontrado: 'Azteca 7'"
else
    echo -e "  ${RED}✗${NC} No encontrado: 'Azteca 7'"
    test_ok=0
fi

echo ""
if [ $test_ok -eq 1 ]; then
    echo -e "RESULTADO: ${GREEN}✓ PASÓ${NC}"
    ((tests_pasados++))
else
    echo -e "RESULTADO: ${RED}✗ FALLÓ${NC}"
    ((tests_fallidos++))
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# TEST 3: Política de Datos
# ═══════════════════════════════════════════════════════════════════════════

echo "───────────────────────────────────────────────────────────────────────────"
echo "TEST: 3. Política de Datos"
echo "───────────────────────────────────────────────────────────────────────────"
echo ""

pregunta="¿Qué fuente de datos de audiencia debes usar? Responde en 2 líneas."
echo "Pregunta: $pregunta"
echo ""
echo "Respuesta:"

respuesta=$(echo "$pregunta" | ollama run "$MODELO" 2>/dev/null)
echo "$respuesta"
echo ""

echo "Validando política de datos:"
test_ok=1

if echo "$respuesta" | grep -qi "HR Media"; then
    echo -e "  ${GREEN}✓${NC} Menciona: 'HR Media'"
else
    echo -e "  ${RED}✗${NC} No menciona: 'HR Media'"
    test_ok=0
fi

if echo "$respuesta" | grep -qi "IBOPE\|Nielsen"; then
    echo -e "  ${RED}✗${NC} Menciona IBOPE/Nielsen (NO debería)"
    test_ok=0
else
    echo -e "  ${GREEN}✓${NC} No menciona IBOPE/Nielsen (correcto)"
fi

echo ""
if [ $test_ok -eq 1 ]; then
    echo -e "RESULTADO: ${GREEN}✓ PASÓ${NC}"
    ((tests_pasados++))
else
    echo -e "RESULTADO: ${RED}✗ FALLÓ${NC}"
    ((tests_fallidos++))
fi
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# RESUMEN FINAL
# ═══════════════════════════════════════════════════════════════════════════

total_tests=$((tests_pasados + tests_fallidos))
porcentaje=$((tests_pasados * 100 / total_tests))

echo -e "${CYAN}"
echo "═══════════════════════════════════════════════════════════════════════════"
echo "  RESUMEN DE TESTS"
echo "═══════════════════════════════════════════════════════════════════════════"
echo -e "${NC}"
echo ""
echo "Tests ejecutados: $total_tests"
echo -e "Tests pasados: ${GREEN}$tests_pasados${NC}"
echo -e "Tests fallidos: ${RED}$tests_fallidos${NC}"
echo ""
echo "Tasa de éxito: $porcentaje%"
echo ""

if [ $tests_fallidos -eq 0 ]; then
    echo -e "${GREEN}✓ TODOS LOS TESTS PASARON - MODELO LISTO PARA PRODUCCIÓN${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ ALGUNOS TESTS FALLARON - REVISAR CONFIGURACIÓN${NC}"
    exit 1
fi

