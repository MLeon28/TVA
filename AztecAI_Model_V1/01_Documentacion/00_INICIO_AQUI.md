# ⭐ INICIO AQUÍ - Guía para Ingenieros

**Documento:** Roadmap de Implementación  
**Audiencia:** Ingenieros de Infraestructura y DevOps  
**Tiempo de lectura:** 10 minutos  
**Última actualización:** 5 de Noviembre 2025  

---

## 👋 Bienvenido

Has recibido este paquete porque **AztecAI está listo para producción**. Este documento te guiará en los pasos necesarios para replicar el sistema que ha sido validado en ambiente local.

---

## 🎯 ¿Qué vas a desplegar?

**AztecAI** es un asistente de IA corporativo basado en:

- **Ollama** (motor de IA local)
- **Modelo gpt-oss:20b** (20 mil millones de parámetros)
- **OpenWebUI** (interfaz web para usuarios)
- **Sistema RAG** (Knowledge Base dinámica)

**NO es:**
- ❌ Un chatbot genérico de internet
- ❌ Un servicio cloud externo (OpenAI, Claude, etc.)
- ❌ Un sistema que envía datos a terceros

**ES:**
- ✅ Un modelo de IA corriendo 100% en tu servidor
- ✅ Privado y aislado de internet
- ✅ Personalizado para TV Azteca
- ✅ Con conocimiento corporativo específico

---

## 📋 Roadmap de Implementación (4-7 horas)

### Fase 1: Preparación (1-2 horas)

**Responsable:** Infraestructura

```
┌─────────────────────────────────────────────┐
│  1. Provisionar servidor                    │
│     • Ubuntu 22.04 LTS                      │
│     • Mínimo 32GB RAM, 100GB SSD            │
│     • Acceso root/sudo                      │
│                                             │
│  2. Verificar requisitos                    │
│     • Leer: REQUISITOS_TECNICOS.md          │
│     • Puertos disponibles: 3000, 11434, 443 │
│     • Firewall configurado                  │
│                                             │
│  3. Preparar red                            │
│     • SSL/TLS certificado                   │
│     • DNS configurado (si aplica)           │
│     • Reverse proxy planeado                │
└─────────────────────────────────────────────┘
```

**Checklist:**
- [ ] Servidor con Ubuntu 22.04 LTS
- [ ] 32GB+ RAM disponible
- [ ] 100GB+ almacenamiento SSD
- [ ] Acceso root/sudo verificado
- [ ] Puertos 3000, 11434, 443 libres
- [ ] Certificado SSL preparado
- [ ] Conexión a internet estable

---

### Fase 2: Instalación Base (30-60 minutos)

**Responsable:** DevOps / Ingenieros

```
┌─────────────────────────────────────────────┐
│  OPCIÓN A: Automatizada (Recomendado)       │
│                                             │
│  1. Copiar paquete al servidor              │
│     scp -r AztecAI_Model user@server:/opt   │
│                                             │
│  2. Ejecutar script de despliegue           │
│     cd /opt/AztecAI_Model/04_Scripts        │
│     sudo ./deploy_production.sh             │
│                                             │
│  3. Esperar completación (30-60 min)        │
│     • Instala dependencias                  │
│     • Descarga modelo base (40-50 GB)       │
│     • Crea modelo personalizado             │
│     • Configura OpenWebUI                   │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  OPCIÓN B: Manual                           │
│                                             │
│  Ver documento completo:                    │
│  GUIA_INSTALACION_SERVIDOR.md               │
│                                             │
│  Recomendado solo si:                       │
│  • El script automático falla               │
│  • Tienes requisitos específicos            │
│  • Necesitas customización avanzada         │
└─────────────────────────────────────────────┘
```

**Tiempo:** 30-60 minutos (depende de velocidad de descarga)

---

### Fase 3: Configuración (1-2 horas)

**Responsable:** DevOps / Ingenieros

```
┌─────────────────────────────────────────────┐
│  1. Importar Knowledge Base                 │
│     • Abrir OpenWebUI: http://server:3000   │
│     • Workspace → Documents                 │
│     • Subir: 03_Knowledge_Base/             │
│       AztecAI_Complete_Knowledge_Base.md    │
│                                             │
│  2. Configurar RAG                          │
│     • Crear Collection "AztecAI"            │
│     • Top-K: 5                              │
│     • Activar en configuración              │
│                                             │
│  3. Configurar Nginx (Producción)           │
│     • Copiar: 05_Configuracion/nginx.conf   │
│     • SSL/TLS termination                   │
│     • Reverse proxy a puerto 3000           │
│                                             │
│  4. Configurar Systemd Services             │
│     • Ollama como servicio                  │
│     • OpenWebUI como servicio               │
│     • Auto-start en boot                    │
└─────────────────────────────────────────────┘
```

**Checklist:**
- [ ] Knowledge Base importada en OpenWebUI
- [ ] Collection "AztecAI" creada
- [ ] RAG activado con Top-K: 5
- [ ] Nginx configurado con SSL
- [ ] Servicios systemd creados
- [ ] Auto-start configurado

---

### Fase 4: Validación (1 hora)

**Responsable:** DevOps + QA

```
┌─────────────────────────────────────────────┐
│  1. Tests Automatizados                     │
│     cd /opt/AztecAI_Model/04_Scripts        │
│     ./verify_installation.sh                │
│                                             │
│  2. Tests Manuales                          │
│     Ver: CHECKLIST_VERIFICACION.md          │
│     • Test de respuesta básica              │
│     • Validar formato profesional           │
│     • Verificar RAG funcional               │
│     • Test de performance                   │
│                                             │
│  3. Tests con Ejemplos                      │
│     Ver: EJEMPLOS_USO.md                    │
│     • Casos de uso corporativos             │
│     • Respuestas esperadas                  │
│     • Validar guardrails                    │
└─────────────────────────────────────────────┘
```

**Criterios de Aceptación:**
- ✅ Script `verify_installation.sh` pasa todos los tests
- ✅ Modelo responde en formato "Pirámide Invertida"
- ✅ RAG trae información de Knowledge Base
- ✅ Respuestas consistentes en español
- ✅ Performance dentro de métricas esperadas

---

### Fase 5: Ajustes Finales (1-2 horas)

**Responsable:** Ingenieros + IAA

```
┌─────────────────────────────────────────────┐
│  1. Configurar Usuarios                     │
│     • Crear cuentas iniciales               │
│     • Configurar roles (Admin/User)         │
│     • Integrar LDAP/SSO (si aplica)         │
│                                             │
│  2. Configurar Monitoreo                    │
│     • Logs de Ollama                        │
│     • Logs de OpenWebUI                     │
│     • Métricas de uso                       │
│     • Alertas de error                      │
│                                             │
│  3. Configurar Backups                      │
│     • Backup de configuración               │
│     • Backup de Knowledge Base              │
│     • Backup de base de datos OWUI          │
│     • Schedule automático                   │
│                                             │
│  4. Documentar Accesos                      │
│     • URL de acceso                         │
│     • Credenciales de admin                 │
│     • Ubicación de logs                     │
│     • Procedimientos de mantenimiento       │
└─────────────────────────────────────────────┘
```

---

## 🗺️ Mapa de Documentación

### 📖 Lee en este orden:

```
1. ⭐ 00_INICIO_AQUI.md              ← Estás aquí
   └─→ Roadmap general

2. 🖥️ REQUISITOS_TECNICOS.md
   └─→ Hardware, software, dependencias

3. 📋 Elegir método de instalación:
   
   ┌─ OPCIÓN A: Automatizada ──────────────┐
   │  3a. 04_Scripts/deploy_production.sh  │
   │      └─→ Instalación automática       │
   │                                       │
   │  3b. CHECKLIST_VERIFICACION.md        │
   │      └─→ Validar instalación          │
   └───────────────────────────────────────┘
   
   ┌─ OPCIÓN B: Manual ────────────────────┐
   │  3a. GUIA_INSTALACION_SERVIDOR.md     │
   │      └─→ Paso a paso detallado        │
   │                                       │
   │  3b. ARQUITECTURA_TECNICA.md          │
   │      └─→ Entender componentes         │
   │                                       │
   │  3c. CHECKLIST_VERIFICACION.md        │
   │      └─→ Validar cada paso            │
   └───────────────────────────────────────┘

4. ✅ EJEMPLOS_USO.md
   └─→ Validar respuestas del sistema

5. 🔧 TROUBLESHOOTING_PRODUCCION.md
   └─→ Solo si hay problemas
```

---

## 🚀 Quick Start (Si Ya Sabes lo que Haces)

```bash
# 1. Copiar paquete al servidor
scp -r AztecAI_Model/ user@production-server:/opt/

# 2. SSH al servidor
ssh user@production-server

# 3. Ejecutar instalación automatizada
cd /opt/AztecAI_Model/04_Scripts
sudo ./deploy_production.sh

# 4. Esperar 30-60 minutos (descarga del modelo)

# 5. Verificar instalación
./verify_installation.sh

# 6. Acceder a OpenWebUI
# http://server-ip:3000

# 7. Importar Knowledge Base
# Workspace → Documents → Upload: 
# /opt/AztecAI_Model/03_Knowledge_Base/AztecAI_Complete_Knowledge_Base.md

# 8. Configurar RAG
# Settings → RAG → Create Collection "AztecAI" → Top-K: 5

# 9. Probar
# Nueva conversación → "¿Qué canales tiene TV Azteca?"
```

---

## ⚠️ Advertencias Importantes

### 🔴 CRÍTICO - No Hacer

1. **NO modificar el Modelfile sin respaldo**
   - Puede romper el modelo completamente
   - Siempre hacer backup antes de cambios

2. **NO intentar suprimir bloques `<details type="reasoning">`**
   - Es característica natural del modelo
   - Intentar suprimirlo rompe las respuestas

3. **NO exponer puerto 11434 (Ollama) a internet**
   - Solo OpenWebUI debe ser público
   - Ollama debe estar en red interna

4. **NO actualizar Ollama/OpenWebUI sin probar en staging**
   - Puede romper compatibilidad
   - Siempre tener plan de rollback

### 🟡 IMPORTANTE - Considerar

1. **Primera descarga del modelo: 40-50 GB**
   - Toma 30-60 minutos con buena conexión
   - Planificar ventana de mantenimiento

2. **RAG es obligatorio**
   - Sistema no funciona correctamente sin RAG
   - Collection debe llamarse "AztecAI"

3. **Primera carga del modelo es lenta**
   - 30-60 segundos la primera vez
   - Subsecuentes: 3-7 segundos

4. **Knowledge Base se importa en OpenWebUI, NO en Ollama**
   - Confusión común
   - KB va en Workspace → Documents

---

## 📊 Métricas Esperadas (Post-Instalación)

Después de instalar, debes obtener:

| Métrica | Valor Esperado | Cómo Validar |
|---------|----------------|--------------|
| **Primera respuesta** | 3-7 seg | Hacer pregunta simple |
| **Streaming start** | 1-2 seg | Ver cuándo empieza a escribir |
| **Tokens/segundo** | 12-15 | Contar palabras por segundo |
| **RAG retrieval** | <1 seg | Verificar fuentes citadas |
| **Uso RAM** | 16-18 GB | `htop` o `top` |
| **Uso CPU** | 60-80% | Durante generación |
| **Formato correcto** | 100% | Ver estructura respuesta |

Si no obtienes estas métricas, revisar `TROUBLESHOOTING_PRODUCCION.md`.

---

## 🔧 Comandos Útiles

```bash
# Ver estado de servicios
systemctl status ollama
systemctl status openwebui

# Ver logs en tiempo real
journalctl -u ollama -f
journalctl -u openwebui -f

# Verificar modelo instalado
ollama list | grep aztecai

# Reiniciar servicios
systemctl restart ollama
systemctl restart openwebui

# Probar modelo directamente (sin OpenWebUI)
ollama run aztecai "¿Qué canales tiene TV Azteca?"

# Ver uso de recursos
htop
nvidia-smi  # Si tienes GPU
```

---

## 🆘 ¿Problemas Durante la Instalación?

### Opción 1: Consultar Troubleshooting
Ver: `TROUBLESHOOTING_PRODUCCION.md`

Problemas comunes ya documentados:
- ❌ Modelo no aparece
- ❌ Knowledge Base no se usa
- ❌ Respuestas lentas
- ❌ Errores de memoria
- ❌ Nginx no conecta

### Opción 2: Verificar con Script
```bash
cd /opt/AztecAI_Model/04_Scripts
./verify_installation.sh --verbose
```

### Opción 3: Rollback
Si algo sale muy mal:
```bash
cd /opt/AztecAI_Model/04_Scripts
sudo ./rollback.sh
```

---

## 👥 Responsabilidades

| Quién | Qué |
|-------|-----|
| **Infraestructura** | Provisionar servidor, red, SSL |
| **DevOps/Ingenieros** | Ejecutar instalación, configurar servicios |
| **QA** | Validar tests, certificar funcionamiento |
| **IAA (Héctor Romero)** | Validar respuestas, aprobar producción |
| **Seguridad** | Revisar configuración, firewall, accesos |

---

## ✅ Señales de Éxito

Sabrás que el despliegue fue exitoso cuando:

1. ✅ Script `verify_installation.sh` pasa todos los tests
2. ✅ OpenWebUI accesible vía HTTPS
3. ✅ Modelo responde en formato "Pirámide Invertida"
4. ✅ RAG trae información corporativa de TV Azteca
5. ✅ Respuestas consistentes en español
6. ✅ Performance dentro de métricas esperadas
7. ✅ Servicios sobreviven a reinicio del servidor
8. ✅ Logs sin errores críticos
9. ✅ Usuario piloto valida funcionalidad
10. ✅ IAA aprueba go-live

---

## 📅 Timeline Sugerido

### Día 1: Preparación e Instalación
- **Mañana:** Provisionar servidor, verificar requisitos
- **Tarde:** Ejecutar instalación automatizada
- **Noche:** Configuración inicial

### Día 2: Validación y Ajustes
- **Mañana:** Tests de validación
- **Tarde:** Ajustes finos, configuración de usuarios
- **Noche:** Monitoreo y backups

### Día 3: Piloto y Go-Live
- **Mañana:** Validación con usuarios piloto
- **Tarde:** Rollout limitado
- **Noche:** Monitoreo intensivo

---

## 📝 Notas Finales

### Lo Que Ya Está Listo
- ✅ Modelo validado en ambiente local
- ✅ Knowledge Base completa y probada
- ✅ Scripts de instalación testeados
- ✅ Documentación exhaustiva
- ✅ Tests de validación preparados

### Lo Que Necesitas Agregar
- [ ] Certificados SSL corporativos
- [ ] Configuración LDAP/SSO
- [ ] Políticas de firewall específicas
- [ ] Integración con monitoreo corporativo
- [ ] Backups corporativos

### Punto de No Retorno
Una vez que el modelo base `gpt-oss:20b` esté descargado (40-50 GB), ya tienes el 70% del trabajo hecho. El resto es configuración.

---

## 🎯 Próximo Paso

**Lee ahora:** `REQUISITOS_TECNICOS.md`

Asegúrate de que tu servidor cumple todos los requisitos antes de proceder con la instalación.

---

**Documento creado:** 5 de Noviembre 2025  
**Versión:** 1.0  
**Mantenido por:** IAA - Héctor Romero Pico  

---

*"Un buen inicio es la mitad del éxito."* 🚀  
*AztecAI - De Local a Producción* 🇲🇽

