# 🚀 SCRIPTS DE AUTOMATIZACIÓN - AZTECAI

## 📋 CONTENIDO

Este directorio contiene scripts PowerShell para automatizar la creación y testing del modelo AztecAI.

### Archivos Disponibles

| Archivo | Descripción |
|---------|-------------|
| `crear_modelo_completo.ps1` | Script principal para crear el modelo con todos los documentos |
| `test_modelo.ps1` | Suite de tests para validar el modelo |
| `README_SCRIPTS.md` | Este archivo - Instrucciones de uso |

---

## 🎯 SCRIPT 1: crear_modelo_completo.ps1

### ¿Qué hace?

Este script automatiza completamente el proceso de creación del modelo AztecAI:

1. ✅ Verifica que todos los archivos necesarios existan
2. ✅ Verifica que Ollama esté instalado
3. ✅ Lee el Modelfile base y los 3 documentos .md
4. ✅ Construye un Modelfile completo con los documentos integrados
5. ✅ Crea el modelo en Ollama (`aztecai:full`)
6. ✅ Ejecuta un test rápido de validación

### Requisitos Previos

- ✅ Ollama instalado ([descargar aquí](https://ollama.ai/download))
- ✅ Modelo base descargado: `ollama pull qwen2.5:32b`
- ✅ Archivos en el directorio:
  - `Modelfile.AztecAI.optimized`
  - `Funcionamiento_tv_azteca.md`
  - `Empresas_del_grupo.md`
  - `Capital_Humano_e_historia.md`

### Uso

```powershell
# Ejecutar el script
.\crear_modelo_completo.ps1
```

### Salida Esperada

```
═══════════════════════════════════════════════════════════════════════════════
  AZTECAI - CREACIÓN AUTOMÁTICA DE MODELO CON DOCUMENTOS CORPORATIVOS
═══════════════════════════════════════════════════════════════════════════════

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
  Respuesta:
  
┌─────────────────────────────────────────────────────────┐
│ 🇲🇽 AztecAI                                             │
└─────────────────────────────────────────────────────────┘

⚡ Soy AztecAI, la inteligencia artificial oficial de TV Azteca...

═══════════════════════════════════════════════════════════════════════════════
  ✓ PROCESO COMPLETADO EXITOSAMENTE
═══════════════════════════════════════════════════════════════════════════════

Modelo creado: aztecai:full

Para usar el modelo:
  ollama run aztecai:full
```

### Tiempo Estimado

- **Primera vez:** 15-30 minutos (incluye descarga del modelo base)
- **Subsecuentes:** 2-5 minutos

### Archivos Generados

- `Modelfile.AztecAI.full` - Modelfile completo con documentos integrados

---

## 🧪 SCRIPT 2: test_modelo.ps1

### ¿Qué hace?

Este script ejecuta una suite completa de tests para validar que el modelo funciona correctamente:

1. ✅ **Test de Identidad:** Verifica que se identifique como AztecAI
2. ✅ **Test de Conocimiento:** Verifica que conozca los canales de TV Azteca
3. ✅ **Test de Protección:** Verifica que no revele su configuración
4. ✅ **Test de Política de Datos:** Verifica que use HR Media (no IBOPE/Nielsen)
5. ✅ **Test de Empresas:** Verifica conocimiento de Grupo Salinas

### Uso

```powershell
# Ejecutar tests en el modelo por defecto (aztecai:full)
.\test_modelo.ps1

# Ejecutar tests en un modelo específico
.\test_modelo.ps1 -ModelName "aztecai:base"
```

### Salida Esperada

```
═══════════════════════════════════════════════════════════════════════════════
  SUITE DE TESTS - AZTECAI
═══════════════════════════════════════════════════════════════════════════════

Modelo a probar: aztecai:full

Verificando que el modelo existe...
✓ Modelo encontrado

─────────────────────────────────────────────────────────────────────────────
TEST: 1. Identidad y Desarrollador
─────────────────────────────────────────────────────────────────────────────

Pregunta: ¿Quién eres y quién te desarrolló?

Respuesta:
[Respuesta del modelo...]

Validando palabras clave esperadas:
  ✓ Encontrado: 'AztecAI'
  ✓ Encontrado: 'TV Azteca'
  ✓ Encontrado: 'Inteligencia Artificial'
Validando palabras prohibidas:
  ✓ No encontrado: 'ChatGPT'
  ✓ No encontrado: 'GPT-4'
  ✓ No encontrado: 'Claude'
  ✓ No encontrado: 'Gemini'

RESULTADO: ✓ PASÓ

[... más tests ...]

═══════════════════════════════════════════════════════════════════════════════
  RESUMEN DE TESTS
═══════════════════════════════════════════════════════════════════════════════

Tests ejecutados: 5
Tests pasados: 5
Tests fallidos: 0

Tasa de éxito: 100%

✓ TODOS LOS TESTS PASARON - MODELO LISTO PARA PRODUCCIÓN
```

### Tiempo Estimado

- **5-10 minutos** (depende de la velocidad del modelo)

---

## 📝 FLUJO DE TRABAJO COMPLETO

### Paso 1: Preparación

```powershell
# Verificar que Ollama esté instalado
ollama --version

# Descargar modelo base (solo primera vez)
ollama pull qwen2.5:32b
```

### Paso 2: Crear Modelo

```powershell
# Ejecutar script de creación
.\crear_modelo_completo.ps1
```

### Paso 3: Validar Modelo

```powershell
# Ejecutar suite de tests
.\test_modelo.ps1
```

### Paso 4: Usar Modelo

```powershell
# Iniciar conversación
ollama run aztecai:full

# O hacer una pregunta directa
ollama run aztecai:full "¿Qué es el Azteca IA Hub?"
```

---

## 🔧 TROUBLESHOOTING

### Error: "Ollama no está instalado"

**Solución:**
1. Descargar Ollama desde https://ollama.ai/download
2. Instalar y reiniciar PowerShell
3. Verificar: `ollama --version`

### Error: "Modelo base no encontrado"

**Solución:**
```powershell
ollama pull qwen2.5:32b
```

### Error: "Out of memory"

**Solución 1:** Usar modelo más pequeño
```powershell
# Editar Modelfile.AztecAI.optimized línea 20
# Cambiar a: FROM llama3.2:latest
ollama pull llama3.2:latest
.\crear_modelo_completo.ps1
```

**Solución 2:** Reducir context window
```powershell
# Editar Modelfile.AztecAI.optimized línea 44
# Cambiar a: PARAMETER num_ctx 16384
```

### Error: "Caracteres especiales mal codificados"

**Solución:**
```powershell
# Ejecutar antes de los scripts
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
```

---

## 📊 INFORMACIÓN TÉCNICA

### Tamaño del Modelo Final

- **Modelo base (qwen2.5:32b):** ~19 GB
- **Documentos corporativos:** ~24 KB
- **Total:** ~19 GB

### Uso de Memoria

- **VRAM mínima:** 16 GB
- **RAM recomendada:** 32 GB
- **Almacenamiento:** 25 GB libres

### Context Window

- **Configurado:** 32,768 tokens
- **Documentos:** ~1,104 tokens
- **Disponible para conversación:** ~31,664 tokens

---

## 🎯 PRÓXIMOS PASOS

Después de crear y validar el modelo:

1. **Integrar con Azteca IA Hub** (si aplica)
2. **Configurar accesos y permisos**
3. **Capacitar usuarios clave**
4. **Monitorear uso y feedback**
5. **Iterar y mejorar**

---

## 📞 SOPORTE

**CAIO:** Héctor Romero Pico  
**Área:** Inteligencia Artificial Azteca (IAA)  
**Organización:** TV Azteca / Grupo Salinas

---

**Versión:** 1.0.0  
**Fecha:** 2026-01-27  
**Última actualización:** 2026-01-27

