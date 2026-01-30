# 🚀 LÉEME PRIMERO - PROYECTO AZTECAI

**¡Bienvenido al proyecto AztecAI optimizado!**

Este documento te guiará en 2 minutos para que puedas empezar.

---

## ⚡ INICIO RÁPIDO (30 SEGUNDOS)

### ¿Qué es esto?

Un **Modelfile optimizado** para crear AztecAI, la IA corporativa de TV Azteca, con:
- ✅ Todos los errores críticos corregidos
- ✅ Código optimizado en 71%
- ✅ Scripts automatizados para instalación
- ✅ Tests de validación incluidos
- ✅ Documentación completa

### ¿Qué necesito?

1. **Ollama instalado** → [Descargar aquí](https://ollama.ai/download)
2. **GPU con 16GB+ VRAM** (o usar modelo más pequeño)
3. **30-60 minutos** para la primera instalación

---

## 🎯 EMPEZAR AHORA (3 PASOS)

### Paso 1: Descargar Modelo Base

```powershell
ollama pull qwen2.5:32b
```

⏱️ **Tiempo:** 10-30 minutos (solo primera vez)

---

### Paso 2: Crear Modelo AztecAI

```powershell
.\crear_modelo_completo.ps1
```

⏱️ **Tiempo:** 2-5 minutos

**Qué hace:**
- ✅ Verifica archivos
- ✅ Lee documentos corporativos
- ✅ Construye Modelfile completo
- ✅ Crea modelo en Ollama
- ✅ Ejecuta test rápido

---

### Paso 3: Validar Modelo

```powershell
.\test_modelo.ps1
```

⏱️ **Tiempo:** 5-10 minutos

**Qué hace:**
- ✅ Test de identidad
- ✅ Test de conocimiento
- ✅ Test de protecciones
- ✅ Test de políticas
- ✅ Reporte de resultados

---

## ✅ ¡LISTO! Ahora puedes usar el modelo

```powershell
ollama run aztecai:full
```

**Prueba con:**
- "¿Quién eres?"
- "¿Cuáles son los canales de TV Azteca?"
- "¿Qué es el Azteca IA Hub?"

---

## 📚 ¿QUIERES SABER MÁS?

### Documentación Disponible

| Archivo | Para qué sirve | Cuándo leerlo |
|---------|----------------|---------------|
| **RESUMEN_EJECUTIVO.md** | Overview completo del proyecto | Para entender todo el proyecto |
| **README_SCRIPTS.md** | Instrucciones de scripts | Antes de ejecutar scripts |
| **GUIA_IMPLEMENTACION.md** | Guía técnica detallada | Si tienes problemas o necesitas detalles |
| **COMPARACION_MODELOS.md** | Análisis de modelos base | Si quieres cambiar modelo base |

---

## 🔧 ¿PROBLEMAS?

### Error: "Ollama no encontrado"
**Solución:** Instalar Ollama desde https://ollama.ai/download

### Error: "Out of memory"
**Solución:** Usar modelo más pequeño
```powershell
# Editar Modelfile.AztecAI.optimized línea 20
# Cambiar a: FROM llama3.2:latest
ollama pull llama3.2:latest
.\crear_modelo_completo.ps1
```

### Error: "Modelo base no encontrado"
**Solución:**
```powershell
ollama pull qwen2.5:32b
```

### Más problemas
**Consultar:** `GUIA_IMPLEMENTACION.md` sección "Troubleshooting"

---

## 📊 ¿QUÉ SE OPTIMIZÓ?

| Componente | Antes | Después | Mejora |
|------------|-------|---------|--------|
| **Modelfile** | 993 líneas | 282 líneas | **-71%** |
| **Docs totales** | 1,589 líneas | 850 líneas | **-46%** |
| **Errores críticos** | 4 | 0 | **-100%** |
| **Context window** | 8K | 32K | **+300%** |

---

## 🎯 ARCHIVOS DEL PROYECTO

```
📁 ModelFiles/
│
├── 📖 DOCUMENTACIÓN
│   ├── LEEME_PRIMERO.md              ← Estás aquí - Inicio rápido
│   ├── RESUMEN_EJECUTIVO.md          ← Overview del proyecto
│   ├── README_SCRIPTS.md             ← Instrucciones de scripts
│   ├── GUIA_IMPLEMENTACION.md        ← Guía técnica detallada
│   └── COMPARACION_MODELOS.md        ← Análisis de modelos base
│
├── 🔧 SCRIPTS
│   ├── crear_modelo_completo.ps1     ← Script principal ⭐
│   └── test_modelo.ps1               ← Tests de validación
│
├── 🤖 MODELFILES
│   ├── Modelfile.AztecAI             ← Original (referencia)
│   └── Modelfile.AztecAI.optimized   ← Optimizado ⭐
│
└── 📚 BASE DE CONOCIMIENTO
    ├── Funcionamiento_tv_azteca.md   ← 581 líneas
    ├── Empresas_del_grupo.md         ← 141 líneas
    └── Capital_Humano_e_historia.md  ← 128 líneas
```

---

## 💡 CONSEJOS

### ✅ Recomendaciones

1. **Usa los scripts automatizados** - Ahorran tiempo y evitan errores
2. **Ejecuta los tests** - Aseguran que todo funciona correctamente
3. **Lee el RESUMEN_EJECUTIVO.md** - Entenderás todo el proyecto
4. **Guarda el Modelfile.AztecAI.full** - Es tu modelo completo

### ⚠️ Evita

1. ❌ Editar manualmente los archivos .md (usa los optimizados)
2. ❌ Saltarte los tests (pueden detectar problemas)
3. ❌ Usar modelos no recomendados sin leer COMPARACION_MODELOS.md

---

## 🎓 FLUJO RECOMENDADO

```
1. Leer LEEME_PRIMERO.md (este archivo)        ← 2 min
   ↓
2. Ejecutar crear_modelo_completo.ps1          ← 20-40 min
   ↓
3. Ejecutar test_modelo.ps1                    ← 5-10 min
   ↓
4. ¡Usar AztecAI en producción!                ← ∞
   ollama run aztecai:full
```

**Tiempo total:** ~30-60 minutos (primera vez)

---

## 📞 SOPORTE

**CAIO:** Héctor Romero Pico  
**Área:** Inteligencia Artificial Azteca (IAA)  
**Organización:** TV Azteca / Grupo Salinas

---

## ✨ PRÓXIMOS PASOS

Después de crear el modelo:

1. ✅ Integrar con Azteca IA Hub
2. ✅ Configurar accesos y permisos
3. ✅ Capacitar usuarios clave
4. ✅ Monitorear uso y feedback
5. ✅ Iterar y mejorar

---

**¡Éxito con tu implementación de AztecAI! 🚀**

---

**Versión:** 1.0.0  
**Fecha:** 2026-01-27

