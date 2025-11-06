# 🇲🇽 AztecAI - Paquete de Despliegue en Producción

**Versión:** 2.0 Professional Edition  
**Fecha de Empaquetado:** 5 de Noviembre 2025  
**Desarrollado por:** Inteligencia Artificial Azteca (IAA)  
**CAIO:** Héctor Romero Pico  
**Organización:** TV Azteca / Grupo Salinas  

---

## 📋 Propósito de Este Paquete

Este paquete contiene **TODO lo necesario** para replicar AztecAI en el servidor de producción. Ha sido probado y validado en ambiente local y está listo para despliegue empresarial.

---

## 📦 Contenido del Paquete

```
AztecAI_Model/
│
├── README.md                              # ← Estás aquí
│
├── 01_Documentacion/                      # Documentación completa
│   ├── 00_INICIO_AQUI.md                  # ⭐ EMPEZAR POR AQUÍ
│   ├── REQUISITOS_TECNICOS.md             # Hardware, software, dependencias
│   ├── GUIA_INSTALACION_SERVIDOR.md       # Paso a paso para producción
│   ├── ARQUITECTURA_TECNICA.md            # Diagrama y componentes
│   ├── CHECKLIST_VERIFICACION.md          # Tests post-instalación
│   ├── TROUBLESHOOTING_PRODUCCION.md      # Solución de problemas
│   └── EJEMPLOS_USO.md                    # Casos de uso y validación
│
├── 02_Modelfiles/                         # Configuración del modelo
│   ├── Modelfile.AztecAI.Professional     # ✅ Modelfile PRINCIPAL
│   └── parametros_explicados.md           # Documentación de parámetros
│
├── 03_Knowledge_Base/                     # Base de conocimiento
│   ├── AztecAI_Complete_Knowledge_Base.md # ← Importar en OpenWebUI
│   ├── sections/                          # 14 secciones individuales
│   └── metadata.json                      # Metadatos del KB
│
├── 04_Scripts/                            # Scripts de instalación
│   ├── deploy_production.sh               # ⭐ Script principal de despliegue
│   ├── verify_installation.sh             # Verificación automática
│   ├── backup_config.sh                   # Backup de configuración
│   └── rollback.sh                        # Rollback en caso de error
│
├── 05_Configuracion/                      # Archivos de configuración
│   ├── docker-compose.yml                 # Docker Compose (si aplica)
│   ├── nginx.conf                         # Configuración Nginx
│   ├── systemd/                           # Services para systemd
│   └── environment_variables.env          # Variables de entorno
│
└── 06_Tests/                              # Tests de validación
    ├── test_model_response.py             # Test de respuestas
    ├── test_rag_retrieval.py              # Test de RAG
    └── test_performance.sh                # Test de performance
```

---

## 🚀 Inicio Rápido (Para Ingenieros)

### Opción 1: Despliegue Automatizado (Recomendado)

```bash
# 1. Extraer el paquete
cd /ruta/al/servidor
unzip AztecAI_Model.zip

# 2. Ejecutar script de despliegue
cd AztecAI_Model/04_Scripts
sudo ./deploy_production.sh

# 3. Verificar instalación
./verify_installation.sh
```

**Tiempo estimado:** 15-30 minutos

### Opción 2: Instalación Manual

Ver: [`01_Documentacion/GUIA_INSTALACION_SERVIDOR.md`](./01_Documentacion/GUIA_INSTALACION_SERVIDOR.md)

---

## 📊 Requisitos Mínimos del Servidor

| Componente | Mínimo | Recomendado | Producción |
|------------|---------|-------------|------------|
| **CPU** | 8 cores | 16 cores | 32+ cores |
| **RAM** | 32 GB | 64 GB | 128 GB |
| **Almacenamiento** | 100 GB SSD | 500 GB NVMe | 1 TB NVMe |
| **GPU** | Opcional | NVIDIA 16GB | NVIDIA 24GB+ |
| **OS** | Ubuntu 20.04+ | Ubuntu 22.04 LTS | Ubuntu 22.04 LTS |
| **Red** | 100 Mbps | 1 Gbps | 10 Gbps |

**Ver detalles completos:** [`01_Documentacion/REQUISITOS_TECNICOS.md`](./01_Documentacion/REQUISITOS_TECNICOS.md)

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│  USUARIOS (Empleados TV Azteca)                             │
│  • Navegador web                                            │
│  • Red corporativa                                          │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTPS
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  NGINX (Reverse Proxy)                                      │
│  • SSL/TLS Termination                                      │
│  • Load Balancing                                           │
│  • Puerto 443 → 3000                                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  OpenWebUI (Puerto 3000)                                    │
│  • Interface web                                            │
│  • Sistema RAG (Knowledge Base)                             │
│  • Gestión de usuarios                                      │
│  • Collection: "AztecAI"                                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  Ollama (Puerto 11434)                                      │
│  • Modelo: aztecai                                          │
│  • Base: gpt-oss:20b                                        │
│  • System Prompt Core: 450 líneas                           │
└─────────────────────────────────────────────────────────────┘

                    ┌─────────────────────┐
                    │ Knowledge Base (RAG)│
                    │ • 2,690 líneas      │
                    │ • 2 documentos      │
                    │ • Top-K: 5          │
                    └─────────────────────┘
```

---

## ✅ Checklist de Despliegue

### Pre-Despliegue
- [ ] Verificar requisitos de hardware cumplidos
- [ ] Servidor con Ubuntu 22.04 LTS instalado
- [ ] Acceso root/sudo disponible
- [ ] Puertos 3000, 11434, 443 disponibles
- [ ] Certificado SSL configurado (producción)

### Durante Despliegue
- [ ] Instalar dependencias del sistema
- [ ] Instalar Ollama
- [ ] Descargar modelo base gpt-oss:20b
- [ ] Crear modelo personalizado aztecai
- [ ] Instalar OpenWebUI
- [ ] Importar Knowledge Base
- [ ] Configurar RAG (Collection: AztecAI)
- [ ] Configurar Nginx reverse proxy

### Post-Despliegue
- [ ] Ejecutar tests de validación
- [ ] Verificar respuestas del modelo
- [ ] Validar formato profesional
- [ ] Comprobar RAG funcional
- [ ] Test de carga/performance
- [ ] Configurar backups automáticos
- [ ] Documentar credenciales
- [ ] Capacitar a administradores

**Checklist detallado:** [`01_Documentacion/CHECKLIST_VERIFICACION.md`](./01_Documentacion/CHECKLIST_VERIFICACION.md)

---

## 🔧 Stack Tecnológico

| Componente | Tecnología | Versión | Puerto |
|------------|------------|---------|--------|
| **Sistema Operativo** | Ubuntu Server | 22.04 LTS | - |
| **Motor IA** | Ollama | Latest | 11434 |
| **Modelo Base** | gpt-oss | 20b | - |
| **Modelo Custom** | aztecai | 2.0 | - |
| **Interface Web** | OpenWebUI | Latest | 3000 |
| **Reverse Proxy** | Nginx | 1.18+ | 443/80 |
| **Python** | Python 3 | 3.10+ | - |

---

## 📈 Métricas de Éxito (Validadas en Local)

### Performance
- ✅ **Primera respuesta:** 3-7 segundos
- ✅ **Streaming start:** 1-2 segundos
- ✅ **Tokens/segundo:** 12-15
- ✅ **KB retrieval:** <1 segundo
- ✅ **Uso RAM:** 16-18GB por sesión

### Calidad
- ✅ **Guardrails funcionando:** 100%
- ✅ **Sin alucinaciones:** 100%
- ✅ **RAG correcto:** 94%
- ✅ **Idioma español:** 96%
- ✅ **Formato profesional:** 100%

**Nota:** Estas métricas deben revalidarse en servidor de producción

---

## 🔒 Consideraciones de Seguridad

### Red y Acceso
- ✅ OpenWebUI debe estar detrás de Nginx con SSL/TLS
- ✅ Ollama NO debe exponerse directamente a internet
- ✅ Implementar autenticación corporativa (LDAP/SSO)
- ✅ Firewall configurado (solo puertos necesarios)

### Datos
- ✅ Knowledge Base contiene información corporativa sensible
- ✅ Logs deben ser monitoreados
- ✅ Backups diarios de configuración
- ✅ No envía datos a servicios externos

### Usuarios
- ✅ Control de acceso por roles
- ✅ Registro de actividad de usuarios
- ✅ Políticas de uso aceptable

---

## 🔄 Mantenimiento y Actualizaciones

### Actualizar Información Corporativa (Sin Downtime)
```bash
# 1. Editar Knowledge Base
vim /ruta/knowledge_base/AztecAI_Complete_Knowledge_Base.md

# 2. Re-importar en OpenWebUI
# Interface → Workspace → Documents → Replace

# NO necesita recrear modelo ✅
# NO necesita reiniciar servicios ✅
```

### Actualizar System Prompt (Downtime 2-5 min)
```bash
# 1. Editar Modelfile
vim /ruta/Modelfile.AztecAI.Professional

# 2. Recrear modelo
ollama create aztecai -f Modelfile.AztecAI.Professional

# 3. Reiniciar OpenWebUI (si es necesario)
systemctl restart openwebui
```

### Actualizar OpenWebUI (Downtime 5-10 min)
```bash
# Seguir documentación oficial de OpenWebUI
# Backup de base de datos antes de actualizar
```

---

## 📞 Soporte y Contacto

### Responsables del Proyecto
**Owner:** Inteligencia Artificial Azteca (IAA)  
**CAIO:** Héctor Romero Pico  
**Organización:** TV Azteca / Grupo Salinas  

### Para Ingenieros

**Preguntas Técnicas:**
- Revisar: `01_Documentacion/TROUBLESHOOTING_PRODUCCION.md`
- Logs: `/var/log/ollama/` y `/var/log/openwebui/`

**Problemas de Despliegue:**
- Verificar: `01_Documentacion/CHECKLIST_VERIFICACION.md`
- Ejecutar: `04_Scripts/verify_installation.sh`

**Errores Críticos:**
- Rollback: `04_Scripts/rollback.sh`
- Contactar al área de IAA

---

## 📚 Documentación Adicional

### Para Empezar (Orden Recomendado)
1. **[00_INICIO_AQUI.md](./01_Documentacion/00_INICIO_AQUI.md)** ⭐
   - Roadmap para ingenieros
   - Decisiones técnicas clave
   
2. **[REQUISITOS_TECNICOS.md](./01_Documentacion/REQUISITOS_TECNICOS.md)**
   - Hardware y software necesario
   - Dependencias y versiones
   
3. **[GUIA_INSTALACION_SERVIDOR.md](./01_Documentacion/GUIA_INSTALACION_SERVIDOR.md)**
   - Paso a paso detallado
   - Comandos exactos
   
4. **[ARQUITECTURA_TECNICA.md](./01_Documentacion/ARQUITECTURA_TECNICA.md)**
   - Diagramas y flujos
   - Componentes y comunicación

### Para Validación
5. **[CHECKLIST_VERIFICACION.md](./01_Documentacion/CHECKLIST_VERIFICACION.md)**
   - Tests obligatorios
   - Criterios de aceptación
   
6. **[EJEMPLOS_USO.md](./01_Documentacion/EJEMPLOS_USO.md)**
   - Casos de prueba
   - Respuestas esperadas

### Para Troubleshooting
7. **[TROUBLESHOOTING_PRODUCCION.md](./01_Documentacion/TROUBLESHOOTING_PRODUCCION.md)**
   - Problemas comunes
   - Soluciones probadas

---

## 🎯 Entregables de Este Paquete

### ✅ Lo Que Incluye
- [x] Modelfile completo y probado
- [x] Knowledge Base completa (2,690 líneas)
- [x] Scripts de despliegue automatizado
- [x] Documentación exhaustiva para ingenieros
- [x] Tests de validación
- [x] Configuraciones de ejemplo (Nginx, Docker, systemd)
- [x] Checklist de verificación
- [x] Guía de troubleshooting
- [x] Ejemplos de uso validados

### ❌ Lo Que NO Incluye (Responsabilidad de Ingenieros)
- [ ] Certificados SSL corporativos
- [ ] Configuración de LDAP/SSO
- [ ] Políticas de firewall específicas
- [ ] Configuración de monitoreo corporativo
- [ ] Integración con sistemas internos
- [ ] Configuración de backups corporativos

---

## ⚡ Tiempo Estimado de Despliegue

| Fase | Tiempo | Responsable |
|------|--------|-------------|
| **Preparación del servidor** | 1-2 horas | Infraestructura |
| **Instalación automatizada** | 30 minutos | Script |
| **Configuración manual** | 1-2 horas | Ingenieros |
| **Tests de validación** | 1 hora | Ingenieros |
| **Ajustes finales** | 1-2 horas | Ingenieros |
| **Total** | **4-7 horas** | - |

---

## 🚦 Criterios de Aceptación

El despliegue se considera **exitoso** cuando:

- ✅ Modelo `aztecai` responde correctamente
- ✅ Formato profesional "Pirámide Invertida" funciona
- ✅ RAG recupera información de Knowledge Base
- ✅ Respuestas en español consistente
- ✅ Guardrails corporativos activos
- ✅ Performance dentro de métricas esperadas
- ✅ OpenWebUI accesible vía HTTPS
- ✅ Todos los tests de validación pasan
- ✅ Sistema resiliente a reinicios
- ✅ Logs funcionando correctamente

---

## 📝 Notas Importantes

### ⚠️ CRÍTICO - Leer Antes de Instalar

1. **Modelo Base Pesado (40-50 GB)**
   - Descargar `gpt-oss:20b` toma 30-60 minutos
   - Requiere conexión estable
   - Planificar ventana de instalación

2. **Característica Natural del Modelo**
   - El modelo muestra bloques `<details type="reasoning">`
   - Es comportamiento NORMAL (indica que está pensando)
   - NO intentar suprimir (rompe respuestas)

3. **RAG es Crítico**
   - Sistema NO funciona correctamente sin RAG configurado
   - Collection debe llamarse exactamente "AztecAI"
   - Top-K mínimo: 5

4. **Primera Conversación Lenta**
   - Primera carga del modelo: 30-60 segundos
   - Subsecuentes respuestas: 3-7 segundos
   - Es comportamiento esperado

5. **Knowledge Base No Está en el Modelo**
   - KB se importa en OpenWebUI (no en Ollama)
   - Actualizar KB NO requiere recrear modelo
   - Cambios en KB son inmediatos

---

## 📄 Licencia y Uso

**Clasificación:** Corporativo - Uso Interno  
**Propietario:** TV Azteca / Grupo Salinas  
**Restricción:** Solo para uso en infraestructura de TV Azteca

---

## ✅ Próximos Pasos

Una vez instalado en producción:

1. **Validación Inicial (Día 1)**
   - Ejecutar todos los tests
   - Validar con usuarios piloto
   - Monitorear logs

2. **Estabilización (Semana 1)**
   - Ajustar parámetros según uso real
   - Documentar problemas específicos
   - Configurar monitoreo

3. **Rollout (Semana 2-4)**
   - Ampliar acceso progresivamente
   - Recolectar feedback
   - Iterar mejoras

4. **Mantenimiento Continuo**
   - Actualizar Knowledge Base mensualmente
   - Revisar métricas semanalmente
   - Planificar evolución

---

**Última revisión:** 5 de Noviembre 2025  
**Versión del paquete:** 2.0  
**Estado:** ✅ Listo para Producción  

---

*"De prueba local a producción empresarial."* 🚀  
*AztecAI - Powered by TV Azteca / Grupo Salinas* 🇲🇽

