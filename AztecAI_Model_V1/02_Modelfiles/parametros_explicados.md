# 📖 Explicación de Parámetros del Modelfile

**Documento:** Guía de Parámetros de Configuración  
**Audiencia:** Ingenieros que necesitan ajustar el modelo  
**Última actualización:** 5 de Noviembre 2025  

---

## 📄 Archivo Principal

El archivo `Modelfile.AztecAI.Professional` contiene toda la configuración del modelo personalizado AztecAI.

---

## 🏗️ Estructura del Modelfile

```dockerfile
FROM gpt-oss:20b

# System Prompt (núcleo del comportamiento)
SYSTEM """
[450 líneas de instrucciones]
"""

# Parámetros de generación
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER top_k 40
PARAMETER num_ctx 8192
PARAMETER num_predict 2048
PARAMETER repeat_penalty 1.1
PARAMETER seed -1
```

---

## 📊 Explicación de Cada Parámetro

### 1. FROM

```dockerfile
FROM gpt-oss:20b
```

**Qué hace:** Define el modelo base sobre el cual se construye AztecAI.

**Valor actual:** `gpt-oss:20b`
- Modelo de 20 mil millones de parámetros
- 40-50 GB de tamaño
- Equilibrio entre calidad y velocidad

**NO cambiar** a menos que:
- Tengas un modelo base diferente validado
- Hayas probado en staging primero

---

### 2. SYSTEM

```dockerfile
SYSTEM """
[System Prompt Core de 450 líneas]
"""
```

**Qué hace:** Define la "personalidad" y comportamiento del modelo.

**Contenido:**
- Identidad de AztecAI
- Formato profesional "Pirámide Invertida"
- Guardrails corporativos
- Instrucciones de RAG
- Tono de voz

**Editar solo si:**
- Cambias el comportamiento core del modelo
- Ajustas el formato de respuestas
- Modificas guardrails

**⚠️ CRÍTICO:** Siempre hacer backup antes de modificar.

---

### 3. PARAMETER temperature

```dockerfile
PARAMETER temperature 0.7
```

**Qué hace:** Controla la "creatividad" del modelo.

**Rango:** 0.0 a 2.0
- **0.0-0.3:** Muy determinista, respuestas repetitivas
- **0.4-0.7:** Balanceado (RECOMENDADO)
- **0.8-1.2:** Más creativo, menos predecible
- **1.3-2.0:** Muy aleatorio, puede incoherentar

**Valor actual:** 0.7 (balanceado)

**Cuándo ajustar:**
- Subir (0.8-0.9): Para tareas creativas (brainstorming, copy marketing)
- Bajar (0.4-0.6): Para tareas técnicas (código, números, datos)

**Efecto en AztecAI:**
- 0.7 permite respuestas profesionales pero no robóticas
- Suficiente variedad sin perder consistencia
- Ideal para asistente corporativo

---

### 4. PARAMETER top_p

```dockerfile
PARAMETER top_p 0.9
```

**Qué hace:** Límite de probabilidad acumulada (nucleus sampling).

**Rango:** 0.0 a 1.0
- **0.5:** Muy conservador
- **0.9:** Balanceado (RECOMENDADO)
- **1.0:** Considera todas las opciones

**Valor actual:** 0.9

**Relación con temperature:**
- `top_p` y `temperature` trabajan juntos
- `top_p 0.9` + `temperature 0.7` = balance óptimo

**Cuándo ajustar:**
- Bajar (0.7-0.8): Si respuestas muy repetitivas
- Subir (0.95): Si necesitas más variedad

---

### 5. PARAMETER top_k

```dockerfile
PARAMETER top_k 40
```

**Qué hace:** Número de tokens candidatos a considerar.

**Rango:** 1 a 100
- **10-20:** Muy limitado
- **40:** Balanceado (RECOMENDADO)
- **80-100:** Muy amplio

**Valor actual:** 40

**Efecto:**
- Limita vocabulario activo en cada paso
- 40 es suficiente para español corporativo
- Reduce probabilidad de tokens raros/incorrectos

**Cuándo ajustar:**
- Subir (60-80): Si respuestas muy genéricas
- Bajar (20-30): Si muchos errores o palabras raras

---

### 6. PARAMETER num_ctx

```dockerfile
PARAMETER num_ctx 8192
```

**Qué hace:** Tamaño de la ventana de contexto (tokens).

**Rango:** 512 a 32768 (depende del modelo)
- **2048:** Conversaciones cortas
- **8192:** Balanceado (RECOMENDADO)
- **16384:** Conversaciones muy largas

**Valor actual:** 8192 tokens (≈ 6,000-7,000 palabras)

**Impacto:**
- **Mayor contexto:**
  - ✅ Recuerda más de la conversación
  - ✅ Mejor coherencia en respuestas largas
  - ❌ Más lento
  - ❌ Más uso de RAM

- **Menor contexto:**
  - ✅ Más rápido
  - ✅ Menos RAM
  - ❌ Olvida conversación anterior
  - ❌ Pierde coherencia

**Cuándo ajustar:**
- Subir (16384): Si conversaciones muy técnicas/largas
- Bajar (4096): Si performance es problema

---

### 7. PARAMETER num_predict

```dockerfile
PARAMETER num_predict 2048
```

**Qué hace:** Máximo de tokens a generar por respuesta.

**Rango:** 128 a 4096
- **256:** Respuestas muy cortas
- **2048:** Balanceado (RECOMENDADO)
- **4096:** Respuestas muy extensas

**Valor actual:** 2048 tokens (≈ 1,500-1,800 palabras)

**Efecto:**
- Límite superior de longitud de respuesta
- No obliga a generar 2048, es el máximo
- 2048 es suficiente para formato "Pirámide Invertida"

**Cuándo ajustar:**
- Subir (3072-4096): Si respuestas se cortan frecuentemente
- Bajar (1024): Si respuestas demasiado largas

---

### 8. PARAMETER repeat_penalty

```dockerfile
PARAMETER repeat_penalty 1.1
```

**Qué hace:** Penaliza repetición de tokens.

**Rango:** 0.5 a 2.0
- **0.8-1.0:** Permite repetición
- **1.1:** Penalización ligera (RECOMENDADO)
- **1.3-2.0:** Penalización fuerte

**Valor actual:** 1.1

**Efecto:**
- 1.1 reduce repeticiones sin forzar vocabulario artificial
- Evita frases como "y además, además, además..."
- Mantiene naturalidad del lenguaje

**Cuándo ajustar:**
- Subir (1.2-1.3): Si respuestas muy repetitivas
- Bajar (1.0): Si vocabulario muy forzado/raro

---

### 9. PARAMETER seed

```dockerfile
PARAMETER seed -1
```

**Qué hace:** Semilla para generación aleatoria.

**Valores:**
- **-1:** Aleatorio cada vez (RECOMENDADO)
- **Número fijo:** Respuestas reproducibles

**Valor actual:** -1 (aleatorio)

**Uso:**
- Producción: -1 (variedad en respuestas)
- Testing: Número fijo (reproducibilidad)

**Ejemplo:**
```dockerfile
# Producción
PARAMETER seed -1

# Testing (respuestas idénticas)
PARAMETER seed 42
```

---

## 🎯 Configuraciones Preestablecidas

### Configuración Actual (Balanceada)

```dockerfile
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER top_k 40
PARAMETER num_ctx 8192
PARAMETER num_predict 2048
PARAMETER repeat_penalty 1.1
```

**Ideal para:** Asistente corporativo general

---

### Configuración Creativa (Marketing/Contenido)

```dockerfile
PARAMETER temperature 0.8
PARAMETER top_p 0.95
PARAMETER top_k 60
PARAMETER num_ctx 8192
PARAMETER num_predict 2048
PARAMETER repeat_penalty 1.0
```

**Ideal para:** Copywriting, brainstorming, ideas creativas

---

### Configuración Técnica (Código/Datos)

```dockerfile
PARAMETER temperature 0.4
PARAMETER top_p 0.8
PARAMETER top_k 30
PARAMETER num_ctx 8192
PARAMETER num_predict 2048
PARAMETER repeat_penalty 1.2
```

**Ideal para:** Código, análisis técnico, precisión

---

### Configuración Alta Performance (Velocidad)

```dockerfile
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER top_k 40
PARAMETER num_ctx 4096    # ← Reducido
PARAMETER num_predict 1024 # ← Reducido
PARAMETER repeat_penalty 1.1
```

**Ideal para:** Muchos usuarios concurrentes, respuestas cortas

---

## 🔄 Cómo Cambiar Parámetros

### Opción 1: Editar Modelfile (Cambio Permanente)

```bash
# 1. Backup del Modelfile actual
cp Modelfile.AztecAI.Professional Modelfile.AztecAI.Professional.backup

# 2. Editar
vim Modelfile.AztecAI.Professional

# 3. Recrear modelo
ollama create aztecai -f Modelfile.AztecAI.Professional

# 4. Probar
ollama run aztecai "¿Qué canales tiene TV Azteca?"

# 5. Si funciona, hacer commit
# Si no funciona, restaurar backup
```

---

### Opción 2: Override en OpenWebUI (Temporal)

```
1. Abrir OpenWebUI
2. Settings → Models
3. Seleccionar "aztecai"
4. Advanced Parameters
5. Modificar temporalmente
6. Probar en nueva conversación

NO persiste entre reinicios
```

---

## ⚠️ Precauciones

### NO Hacer

❌ Cambiar múltiples parámetros a la vez
- Difícil saber qué causó el cambio

❌ Valores extremos sin probar
- `temperature 0.0` o `2.0` causan problemas

❌ Modificar sin backup
- Siempre respaldar antes de cambiar

❌ Cambiar en producción directamente
- Probar en staging primero

### SÍ Hacer

✅ Cambiar un parámetro a la vez
✅ Documentar cambios realizados
✅ Probar exhaustivamente
✅ Tener plan de rollback
✅ Validar con usuarios piloto

---

## 🧪 Proceso de Prueba

```bash
# 1. Backup
cp Modelfile.AztecAI.Professional Modelfile.backup

# 2. Modificar UN parámetro
vim Modelfile.AztecAI.Professional

# 3. Recrear modelo
ollama create aztecai -f Modelfile.AztecAI.Professional

# 4. Probar con 10 preguntas diferentes
ollama run aztecai "Pregunta 1"
ollama run aztecai "Pregunta 2"
# ...

# 5. Evaluar:
# - ¿Formato correcto?
# - ¿Velocidad aceptable?
# - ¿Calidad de respuestas?

# 6. Decidir:
# SI funciona mejor → Commit y deploy
# NO funciona mejor → Restaurar backup
```

---

## 📊 Tabla de Troubleshooting

| Problema | Parámetro | Ajuste |
|----------|-----------|--------|
| Respuestas muy lentas | num_ctx | Bajar a 4096 |
| Se cortan las respuestas | num_predict | Subir a 3072 |
| Respuestas repetitivas | repeat_penalty | Subir a 1.2-1.3 |
| Respuestas muy robóticas | temperature | Subir a 0.8 |
| Respuestas incoherentes | temperature | Bajar a 0.5-0.6 |
| Vocabulario muy raro | top_k | Bajar a 30 |
| Muy genérico | top_k | Subir a 60 |
| Usa mucha RAM | num_ctx | Bajar a 4096 |

---

## 🎓 Conceptos Clave

### Temperature vs Top_p vs Top_k

```
Todos controlan "aleatoriedad" pero diferente:

Temperature:
└─ Ajusta distribución de probabilidades
   Valores altos = más aleatorio

Top_p:
└─ Corta probabilidad acumulada
   Solo considera tokens hasta sumar 0.9 prob

Top_k:
└─ Límite absoluto de candidatos
   Solo considera los 40 tokens más probables

Mejor práctica:
Usar los 3 juntos para control fino
```

### Context Window vs Predict Length

```
num_ctx (Context Window):
└─ Cuánto "recuerda" de la conversación
   8192 tokens = toda la charla hasta ahora

num_predict (Predict Length):
└─ Cuánto puede "escribir" en una respuesta
   2048 tokens = una respuesta larga

Analogía:
num_ctx = tamaño de tu libreta de notas
num_predict = cuánto puedes escribir en una página
```

---

## 📝 Log de Cambios Recomendado

```markdown
# Historial de Cambios en Parámetros

## 2025-11-05 - Configuración Inicial
- temperature: 0.7
- top_p: 0.9
- top_k: 40
- num_ctx: 8192
- num_predict: 2048
- repeat_penalty: 1.1
- Razón: Configuración balanceada validada en local

## [Futuro] 2025-11-XX - Optimización Performance
- num_ctx: 8192 → 4096
- Razón: Reducir latencia para 50+ usuarios
- Resultado: [Pendiente]
```

---

**Documento creado:** 5 de Noviembre 2025  
**Versión:** 1.0  
**Mantenido por:** IAA - Héctor Romero Pico  

---

*"Entender los parámetros es entender el modelo."* 🎛️  
*AztecAI - Documentación Técnica* 🇲🇽

