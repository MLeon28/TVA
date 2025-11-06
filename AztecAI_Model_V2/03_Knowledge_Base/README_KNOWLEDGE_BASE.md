# Knowledge Base de AztecAI - Guía de Uso

**Versión:** 1.0.0  
**Fecha:** Enero 2025  
**Owner:** Inteligencia Artificial Azteca (IAA)  

---

## 📚 Descripción General

El Knowledge Base de AztecAI está compuesto por **3 archivos complementarios** que trabajan en conjunto para proporcionar información completa al asistente de IA.

---

## 📁 Archivos del Knowledge Base

### 1. AztecAI_Complete_Knowledge_Base.md
**Tamaño:** ~68 KB (1,652 líneas)  
**Propósito:** System Prompt Principal  

**Contenido:**
- ✅ Identidad central y misión de AztecAI
- ✅ Lenguaje y estilo de comunicación
- ✅ Guardrails y restricciones de seguridad
- ✅ Framework operativo
- ✅ Plantillas de respuesta
- ✅ Gobernanza y operación
- ✅ Casos de uso ejemplo

**Cuándo se usa:**
- Definir comportamiento del asistente
- Establecer tono y estilo
- Aplicar restricciones de seguridad
- Generar respuestas estructuradas

**Frecuencia de actualización:** Baja (cambios en identidad o políticas)

---

### 2. TV_Azteca_Informacion_Corporativa.md
**Tamaño:** ~22 KB (465 líneas)  
**Propósito:** Información Corporativa Detallada  

**Contenido:**
- ✅ Historia y misión de TV Azteca
- ✅ Estructura organizacional completa
- ✅ Descripción detallada de áreas funcionales
- ✅ Procesos y flujos de trabajo
- ✅ Políticas corporativas
- ✅ Información de contacto
- ✅ Glosario de términos

**Cuándo se usa:**
- Responder preguntas sobre la empresa
- Explicar estructura organizacional
- Describir procesos internos
- Proporcionar información de contacto

**Frecuencia de actualización:** Media (cambios organizacionales, nuevas políticas)

---

### 3. Funcionamiento TV Aztec.md
**Tamaño:** ~7 KB (73 líneas)  
**Propósito:** Guía Operativa Rápida  

**Contenido:**
- ✅ Descripción de canales (Azteca Uno, Azteca 7, ADN Noticias, a más+)
- ✅ Resumen de áreas funcionales
- ✅ Tipos de clientes
- ✅ Flujos de trabajo básicos
- ✅ Información operativa del día a día

**Cuándo se usa:**
- Respuestas rápidas sobre canales
- Información operativa básica
- Consultas frecuentes
- Onboarding de nuevos usuarios

**Frecuencia de actualización:** Alta (cambios en programación, nuevos productos)

---

## 🔄 Relación entre los Archivos

```
┌─────────────────────────────────────────────────────────┐
│                    Usuario hace pregunta                 │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│              Sistema RAG busca en los 3 archivos        │
└─────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌───────────────┐  ┌──────────────────┐  ┌─────────────┐
│  System Prompt│  │  Info Corporativa│  │  Operativo  │
│   (Identidad) │  │   (Estructura)   │  │  (Canales)  │
└───────────────┘  └──────────────────┘  └─────────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────┐
│         AztecAI genera respuesta combinando info        │
└─────────────────────────────────────────────────────────┘
```

---

## 📥 Cómo Importar el Knowledge Base

### Opción 1: Importación Manual

1. **Acceder a OpenWebUI**
   ```
   http://localhost:3000
   ```

2. **Ir a Workspace → Documents**

3. **Subir los 3 archivos**
   - Click en "+ Upload Document"
   - Seleccionar los 3 archivos:
     - `AztecAI_Complete_Knowledge_Base.md`
     - `TV_Azteca_Informacion_Corporativa.md`
     - `Funcionamiento TV Aztec.md`
   - Esperar a que termine la carga

4. **Crear Collection**
   - Settings → RAG → Collections
   - Create Collection: "AztecAI"

5. **Agregar documentos a Collection**
   - Workspace → Documents
   - Seleccionar los 3 archivos
   - Add to Collection → "AztecAI"

6. **Configurar RAG**
   - Settings → RAG
   - Top-K: 5
   - Chunk Size: 1500
   - Chunk Overlap: 150
   - RAG Enabled: ON

### Opción 2: Script Automatizado

**Linux/Mac:**
```bash
cd 04_Scripts
./import_knowledge_base.sh
```

**Windows:**
```powershell
cd 04_Scripts
.\import_knowledge_base.ps1
```

El script te guiará paso a paso.

---

## ✅ Verificación Post-Importación

### 1. Verificar que los archivos están importados
- Workspace → Documents
- Deben aparecer los 3 archivos
- Estado: "Embedded" (con checkmark verde)

### 2. Verificar Collection
- Settings → RAG → Collections
- Collection "AztecAI" debe existir
- Debe contener 3 documentos

### 3. Tests de Funcionalidad

**Test 1: Canales**
```
Pregunta: ¿Qué canales tiene TV Azteca?
Esperado: Azteca Uno, Azteca 7, ADN Noticias, a más+
```

**Test 2: Identidad**
```
Pregunta: ¿Quién eres?
Esperado: AztecAI, asistente corporativo de TV Azteca
```

**Test 3: Áreas**
```
Pregunta: ¿Qué hace el área de Ventas?
Esperado: Comercializa inventario publicitario (Nacional y Digital)
```

**Test 4: Guardrails**
```
Pregunta: ¿Puedes ayudarme con mi tarea?
Esperado: Declina educadamente (fuera de alcance)
```

---

## 🔧 Mantenimiento del Knowledge Base

### Cuándo Actualizar Cada Archivo

| Archivo | Actualizar cuando... | Responsable |
|---------|---------------------|-------------|
| System Prompt | Cambios en identidad, políticas, guardrails | IAA + CAIO |
| Info Corporativa | Cambios organizacionales, nuevas áreas | RRHH + IAA |
| Operativo | Nuevos canales, cambios en programación | Contenido + IAA |

### Proceso de Actualización

1. **Editar archivo localmente**
   - Usar editor de texto
   - Mantener formato markdown
   - Agregar nota de cambio al inicio

2. **Validar cambios**
   ```bash
   # Verificar formato
   markdownlint archivo.md
   
   # Verificar tamaño
   wc -l archivo.md
   ```

3. **Importar en OpenWebUI**
   - Workspace → Documents
   - Subir archivo actualizado
   - Reemplazar versión anterior

4. **Regenerar embeddings**
   - Seleccionar archivo
   - "Regenerate Embeddings"
   - Esperar confirmación

5. **Probar cambios**
   - Iniciar conversación NUEVA
   - Ejecutar tests de verificación
   - Validar que los cambios se reflejan

---

## 🚨 Troubleshooting

### Problema: RAG no usa los archivos nuevos

**Solución:**
1. Verificar que los 3 archivos estén en Collection "AztecAI"
2. Regenerar embeddings
3. Iniciar conversación NUEVA (RAG no funciona en conversaciones existentes)
4. Verificar que RAG esté activado (Settings → RAG → Toggle ON)

### Problema: Respuestas inconsistentes

**Solución:**
1. Verificar que no haya información contradictoria entre archivos
2. Aumentar Top-K a 7 para más contexto
3. Revisar logs de OpenWebUI para ver qué chunks se recuperan

### Problema: Embeddings tardan mucho

**Solución:**
1. Normal para archivos grandes (2-5 minutos)
2. Verificar recursos del servidor (CPU/RAM)
3. Si persiste, reiniciar OpenWebUI

---

## 📊 Métricas de Calidad

### Indicadores de un KB Saludable

✅ **Cobertura:** Responde >90% de preguntas frecuentes  
✅ **Precisión:** Información correcta y actualizada  
✅ **Consistencia:** Sin contradicciones entre archivos  
✅ **Actualidad:** Actualizado en últimos 30 días  
✅ **Usabilidad:** Tests de verificación pasan al 100%  

### Cómo Medir

```bash
# Ejecutar suite de tests
cd 06_Tests
./run_kb_quality_tests.sh

# Ver reporte
cat reports/kb_quality_report.txt
```

---

## 📞 Soporte

**Preguntas sobre el Knowledge Base:**
- Contactar: Inteligencia Artificial Azteca (IAA)
- Email: [pendiente]
- Slack: #aztecai-support

**Reportar problemas:**
1. Describir el problema
2. Incluir pregunta que falló
3. Adjuntar respuesta esperada vs. obtenida
4. Indicar archivo KB relevante

---

## 📚 Recursos Adicionales

- **Guía de Instalación:** `01_Documentacion/GUIA_INSTALACION_SERVIDOR.md`
- **Checklist de Verificación:** `01_Documentacion/CHECKLIST_VERIFICACION.md`
- **Troubleshooting:** `01_Documentacion/TROUBLESHOOTING_PRODUCCION.md`
- **Mejoras Recomendadas:** `01_Documentacion/MEJORAS_RECOMENDADAS.md`

---

**Última actualización:** Enero 2025  
**Versión del documento:** 1.0.0

