# 🎯 COMPARACIÓN DE MODELOS BASE PARA AZTECAI

## 📊 TABLA COMPARATIVA RÁPIDA

| Modelo | Tamaño | Context | VRAM | Español | Razonamiento | Velocidad | Recomendación |
|--------|--------|---------|------|---------|--------------|-----------|---------------|
| **qwen2.5:32b** ⭐ | 19 GB | 32K | 16 GB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | **MEJOR OPCIÓN** |
| llama3.3:70b | 40 GB | 128K | 40 GB | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Máximo rendimiento |
| mistral-large | 80 GB | 128K | 48 GB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | Contexto extenso |
| llama3.2:latest | 7 GB | 128K | 8 GB | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Recursos limitados |
| qwen2.5:14b | 9 GB | 32K | 10 GB | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Alternativa ligera |

---

## 🏆 OPCIÓN 1: QWEN2.5:32B (RECOMENDADO) ⭐

### ✅ Ventajas

**1. Excelente en Español**
- Entrenado específicamente con corpus en español de alta calidad
- Comprende modismos mexicanos y lenguaje corporativo
- Genera texto natural sin anglicismos

**2. Razonamiento Superior**
- Arquitectura optimizada para tareas analíticas
- Excelente en seguimiento de instrucciones complejas
- Manejo robusto de reglas y restricciones (ideal para las 10 reglas inmutables)

**3. Context Window Adecuado**
- 32K tokens nativos (suficiente para los 3 documentos .md optimizados)
- No requiere técnicas de compresión
- Mantiene coherencia en conversaciones largas

**4. Recursos Razonables**
- 19 GB de almacenamiento
- 16 GB VRAM mínima (accesible en GPUs modernas)
- Velocidad de inferencia aceptable

**5. Licencia Permisiva**
- Apache 2.0
- Uso comercial permitido
- Sin restricciones para uso corporativo

### ❌ Desventajas

- Context window menor que Llama 3.3 (32K vs 128K)
- Menos conocido que modelos de Meta/Mistral
- Requiere GPU dedicada para rendimiento óptimo

### 🎯 Casos de Uso Ideales

- ✅ Respuestas corporativas en español
- ✅ Análisis de datos y reportes
- ✅ Generación de contenido comercial
- ✅ Asistencia operativa diaria
- ✅ Seguimiento estricto de políticas

### 📝 Comando de Instalación

```bash
ollama pull qwen2.5:32b
ollama create aztecai:full -f Modelfile.AztecAI.optimized
```

---

## 🚀 OPCIÓN 2: LLAMA 3.3:70B (MÁXIMO RENDIMIENTO)

### ✅ Ventajas

**1. Mejor Modelo Open-Source Disponible**
- Rendimiento comparable a GPT-4 en muchas tareas
- Arquitectura probada y optimizada
- Amplio soporte de la comunidad

**2. Context Window Masivo**
- 128K tokens (4x más que Qwen)
- Permite incluir documentación extensa sin optimizar
- Ideal para análisis de documentos largos

**3. Razonamiento de Clase Mundial**
- Excelente en tareas complejas
- Capacidad de seguir cadenas de razonamiento largas
- Manejo superior de ambigüedades

**4. Multilingüe Robusto**
- Buen desempeño en español (aunque no especializado)
- Capacidad de traducción integrada
- Comprensión contextual profunda

### ❌ Desventajas

- **Requiere 40+ GB VRAM** (GPU de gama alta o múltiples GPUs)
- 40 GB de almacenamiento
- Inferencia más lenta que modelos pequeños
- Mayor consumo energético

### 🎯 Casos de Uso Ideales

- ✅ Análisis estratégico complejo
- ✅ Generación de reportes ejecutivos extensos
- ✅ Investigación y síntesis de información
- ✅ Tareas que requieren razonamiento profundo
- ✅ Cuando el hardware no es limitante

### 📝 Comando de Instalación

```bash
ollama pull llama3.3:70b

# Editar Modelfile.AztecAI.optimized línea 20:
# FROM llama3.3:70b

# Opcional: aumentar context window
# PARAMETER num_ctx 131072  # 128K
```

---

## 🌐 OPCIÓN 3: MISTRAL-LARGE (EQUILIBRIO)

### ✅ Ventajas

**1. Excelente en Español**
- Desarrollado por empresa europea (Mistral AI)
- Fuerte énfasis en idiomas europeos y español
- Generación de texto muy natural

**2. Context Window Extenso**
- 128K tokens
- Manejo eficiente de contexto largo
- Buena retención de información

**3. Licencia Comercial Clara**
- Diseñado para uso empresarial
- Soporte oficial disponible
- Actualizaciones regulares

### ❌ Desventajas

- **80+ GB de almacenamiento** (el más grande)
- Requiere 48+ GB VRAM
- Inferencia lenta
- Menos optimizado para hardware consumer

### 🎯 Casos de Uso Ideales

- ✅ Cuando el español es crítico
- ✅ Documentación muy extensa
- ✅ Entorno enterprise con hardware dedicado
- ✅ Necesidad de soporte oficial

### 📝 Comando de Instalación

```bash
ollama pull mistral-large:latest

# Editar Modelfile.AztecAI.optimized línea 20:
# FROM mistral-large:latest
```

---

## 💡 OPCIÓN 4: LLAMA3.2:LATEST (RECURSOS LIMITADOS)

### ✅ Ventajas

**1. Muy Ligero**
- Solo 7 GB de almacenamiento
- 8 GB VRAM suficiente
- Puede correr en laptops modernas

**2. Rápido**
- Inferencia muy veloz
- Baja latencia
- Ideal para respuestas inmediatas

**3. Context Window Grande**
- 128K tokens (sorprendente para su tamaño)
- Buena relación tamaño/capacidad

### ❌ Desventajas

- Capacidades limitadas vs modelos grandes
- Español menos robusto
- Razonamiento más básico
- Puede "alucinar" más frecuentemente

### 🎯 Casos de Uso Ideales

- ✅ Prototipado rápido
- ✅ Testing del Modelfile
- ✅ Hardware limitado
- ✅ Respuestas simples y directas

### 📝 Comando de Instalación

```bash
ollama pull llama3.2:latest

# Editar Modelfile.AztecAI.optimized línea 20:
# FROM llama3.2:latest

# Reducir parámetros:
# PARAMETER num_ctx 8192
# PARAMETER num_predict 2048
```

---

## 🎯 RECOMENDACIÓN FINAL

### Para TV Azteca (Producción): **QWEN2.5:32B** ⭐

**Razones:**

1. **Español nativo de calidad** → Crítico para comunicación corporativa
2. **Recursos razonables** → Deployable en hardware estándar enterprise
3. **Razonamiento robusto** → Maneja las 10 reglas inmutables perfectamente
4. **Context adecuado** → 32K suficiente con documentos optimizados
5. **Velocidad aceptable** → Respuestas en tiempo razonable

### Para Testing/Desarrollo: **LLAMA3.2:LATEST**

- Rápido para iterar
- Bajo costo de recursos
- Fácil de desplegar

### Para Casos Especiales: **LLAMA3.3:70B**

- Análisis estratégico complejo
- Reportes ejecutivos extensos
- Cuando se dispone de GPU de gama alta

---

## 📊 MATRIZ DE DECISIÓN

```
┌─────────────────────────────────────────────────────────────┐
│ SI TIENES...              │ USA...                          │
├─────────────────────────────────────────────────────────────┤
│ GPU 16GB+ y necesitas     │ qwen2.5:32b ⭐                  │
│ español de calidad        │                                 │
├─────────────────────────────────────────────────────────────┤
│ GPU 40GB+ y necesitas     │ llama3.3:70b                    │
│ máximo rendimiento        │                                 │
├─────────────────────────────────────────────────────────────┤
│ Énfasis en español y      │ mistral-large                   │
│ hardware enterprise       │                                 │
├─────────────────────────────────────────────────────────────┤
│ GPU 8GB o menos           │ llama3.2:latest                 │
│ (testing/desarrollo)      │                                 │
└─────────────────────────────────────────────────────────────┘
```

---

**Versión:** 1.0.0  
**Fecha:** Enero 2026  
**Autor:** Área de Inteligencia Artificial Azteca

