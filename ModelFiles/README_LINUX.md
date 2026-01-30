# 🐧 AZTECAI - INSTALACIÓN EN LINUX

**Guía rápida para Ubuntu Server / Linux**

---

## ⚡ INICIO RÁPIDO (3 COMANDOS)

```bash
# 1. Dar permisos de ejecución
chmod +x crear_modelo_completo.sh test_modelo.sh

# 2. Crear modelo
./crear_modelo_completo.sh

# 3. Validar
./test_modelo.sh
```

**Tiempo total:** 30-60 minutos (primera vez)

---

## 📋 REQUISITOS PREVIOS

### 1. Ollama instalado

```bash
# Verificar si está instalado
ollama --version

# Si no está instalado:
curl -fsSL https://ollama.ai/install.sh | sh
```

### 2. Modelo base descargado

```bash
# Descargar qwen2.5:32b (recomendado)
ollama pull qwen2.5:32b

# O alternativa más ligera (si tienes menos de 16GB VRAM):
ollama pull llama3.2:latest
```

### 3. Archivos necesarios

Verifica que tengas estos archivos en el directorio:

```bash
ls -1
```

Debes ver:
- ✅ `Modelfile.AztecAI.optimized`
- ✅ `Funcionamiento_tv_azteca.md`
- ✅ `Empresas_del_grupo.md`
- ✅ `Capital_Humano_e_historia.md`
- ✅ `crear_modelo_completo.sh`
- ✅ `test_modelo.sh`

---

## 🚀 INSTALACIÓN PASO A PASO

### Paso 1: Dar permisos de ejecución

```bash
chmod +x crear_modelo_completo.sh test_modelo.sh
```

### Paso 2: Ejecutar script de creación

```bash
./crear_modelo_completo.sh
```

**Salida esperada:**

```
═══════════════════════════════════════════════════════════════════════════
  AZTECAI - CREACIÓN AUTOMÁTICA DE MODELO CON DOCUMENTOS CORPORATIVOS
═══════════════════════════════════════════════════════════════════════════

[1/6] Verificando archivos necesarios...
  ✓ Modelfile.AztecAI.optimized
  ✓ Funcionamiento_tv_azteca.md
  ✓ Empresas_del_grupo.md
  ✓ Capital_Humano_e_historia.md
  ✓ Todos los archivos encontrados

[2/6] Verificando instalación de Ollama...
  ✓ Ollama instalado: ollama version 0.x.x

[3/6] Leyendo archivos...
  ✓ Modelfile.AztecAI.optimized (282 líneas)
  ✓ Funcionamiento_tv_azteca.md (581 líneas)
  ✓ Empresas_del_grupo.md (141 líneas)
  ✓ Capital_Humano_e_historia.md (128 líneas)

[4/6] Construyendo Modelfile completo con documentos...
  ✓ Modelfile.AztecAI.full creado (1200+ líneas)

[5/6] Creando modelo en Ollama...
  Esto puede tomar varios minutos...

transferring model data
using existing layer sha256:xxxxx
creating new layer sha256:xxxxx
writing manifest
success

  ✓ Modelo 'aztecai:full' creado exitosamente

[6/6] Ejecutando test rápido...
  Pregunta: ¿Quién eres? Responde en máximo 3 líneas.

┌─────────────────────────────────────────────────────────────────┐
│ 🇲🇽 AztecAI                                                     │
└─────────────────────────────────────────────────────────────────┘

⚡ Soy AztecAI, la inteligencia artificial oficial de TV Azteca...

═══════════════════════════════════════════════════════════════════════════
  ✓ PROCESO COMPLETADO EXITOSAMENTE
═══════════════════════════════════════════════════════════════════════════

Modelo creado: aztecai:full

Para usar el modelo:
  ollama run aztecai:full
```

### Paso 3: Ejecutar tests de validación

```bash
./test_modelo.sh
```

**Salida esperada:**

```
═══════════════════════════════════════════════════════════════════════════
  SUITE DE TESTS - AZTECAI
═══════════════════════════════════════════════════════════════════════════

Modelo a probar: aztecai:full

Verificando que el modelo existe...
✓ Modelo encontrado

───────────────────────────────────────────────────────────────────────────
TEST: 1. Identidad y Desarrollador
───────────────────────────────────────────────────────────────────────────

[... tests ejecutándose ...]

═══════════════════════════════════════════════════════════════════════════
  RESUMEN DE TESTS
═══════════════════════════════════════════════════════════════════════════

Tests ejecutados: 3
Tests pasados: 3
Tests fallidos: 0

Tasa de éxito: 100%

✓ TODOS LOS TESTS PASARON - MODELO LISTO PARA PRODUCCIÓN
```

---

## 🎯 USAR EL MODELO

### Modo interactivo

```bash
ollama run aztecai:full
```

Luego puedes hacer preguntas:
- "¿Quién eres?"
- "¿Cuáles son los canales de TV Azteca?"
- "¿Qué es el Azteca IA Hub?"
- "¿Cuántas empresas tiene Grupo Salinas?"

Para salir: `/bye` o `Ctrl+D`

### Pregunta directa

```bash
echo "¿Qué es el Azteca IA Hub?" | ollama run aztecai:full
```

---

## 🔧 TROUBLESHOOTING

### Error: "Permission denied"

```bash
# Dar permisos de ejecución
chmod +x crear_modelo_completo.sh test_modelo.sh
```

### Error: "Ollama not found"

```bash
# Instalar Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Verificar instalación
ollama --version
```

### Error: "Model not found"

```bash
# Descargar modelo base
ollama pull qwen2.5:32b
```

### Error: "Out of memory"

**Opción 1:** Usar modelo más pequeño

```bash
# Editar Modelfile.AztecAI.optimized
nano Modelfile.AztecAI.optimized

# Cambiar línea 20:
# FROM llama3.2:latest

# Descargar modelo
ollama pull llama3.2:latest

# Recrear modelo
./crear_modelo_completo.sh
```

**Opción 2:** Reducir context window

```bash
# Editar Modelfile.AztecAI.optimized
nano Modelfile.AztecAI.optimized

# Cambiar línea ~47:
# PARAMETER num_ctx 16384
```

---

## 📊 ARCHIVOS GENERADOS

Después de ejecutar el script, se creará:

- `Modelfile.AztecAI.full` - Modelfile completo con documentos integrados

---

## 🗑️ DESINSTALAR

```bash
# Eliminar modelo
ollama rm aztecai:full

# Eliminar archivo temporal
rm Modelfile.AztecAI.full
```

---

## 📚 MÁS INFORMACIÓN

- **LEEME_PRIMERO.md** - Guía general del proyecto
- **RESUMEN_EJECUTIVO.md** - Overview completo
- **GUIA_IMPLEMENTACION.md** - Guía técnica detallada
- **COMPARACION_MODELOS.md** - Análisis de modelos base

---

## 💡 COMANDOS ÚTILES

```bash
# Listar modelos instalados
ollama list

# Ver información del modelo
ollama show aztecai:full

# Eliminar modelo
ollama rm aztecai:full

# Ver logs de Ollama
journalctl -u ollama -f
```

---

**CAIO:** Héctor Romero Pico  
**Área:** Inteligencia Artificial Azteca (IAA)  
**Organización:** TV Azteca / Grupo Salinas

**Versión:** 1.0.0  
**Fecha:** 2026-01-27

