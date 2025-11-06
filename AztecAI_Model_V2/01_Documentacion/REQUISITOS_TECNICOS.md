# 🖥️ Requisitos Técnicos - AztecAI Producción

**Documento:** Especificaciones de Hardware y Software  
**Audiencia:** Ingenieros de Infraestructura  
**Última actualización:** 5 de Noviembre 2025  

---

## 📊 Resumen Ejecutivo

AztecAI requiere un servidor con **recursos generosos** debido al tamaño del modelo de IA (20 mil millones de parámetros). Este documento detalla los requisitos mínimos, recomendados y óptimos.

---

## 🖥️ Requisitos de Hardware

### Servidor de Producción

| Componente | Mínimo | Recomendado | Óptimo | Notas |
|------------|---------|-------------|---------|-------|
| **CPU** | 8 cores | 16 cores | 32+ cores | x86_64, Intel Xeon o AMD EPYC |
| **RAM** | 32 GB | 64 GB | 128 GB | DDR4 3200MHz+ |
| **Almacenamiento** | 100 GB SSD | 500 GB NVMe | 1 TB NVMe | Para modelo + logs + backups |
| **GPU** | Opcional | NVIDIA 16GB | NVIDIA 24GB+ | RTX 4090, A100, H100 |
| **Red** | 100 Mbps | 1 Gbps | 10 Gbps | Ethernet dedicado |
| **IOPS** | 3,000 | 10,000 | 50,000+ | Para operaciones I/O del modelo |

### Desglose de Uso de Recursos

#### CPU
```
Uso durante inferencia: 60-80%
Uso en idle: 5-10%
Cores recomendados: 16+
Razón: Procesamiento paralelo de tokens
```

#### RAM
```
Modelo base: 40 GB (gpt-oss:20b en memoria)
OpenWebUI: 2-4 GB
Sistema operativo: 4-6 GB
Buffer/Cache: 8-10 GB
Total: 54-60 GB en uso activo

Por eso recomendamos 64 GB mínimo en producción
```

#### Almacenamiento
```
Modelo base gpt-oss:20b: 40-50 GB
Modelo customizado aztecai: 45-55 GB
OpenWebUI + DB: 2-5 GB
Knowledge Base: 50 MB
Logs (30 días): 5-10 GB
Backups: 20-30 GB
Sistema operativo: 10-20 GB

Total: 122-170 GB
Por eso recomendamos 500 GB
```

#### GPU (Opcional pero Recomendado)

```
Con GPU:
- Inferencia 3-5x más rápida
- Libera CPU para otros procesos
- Mejor experiencia de usuario

Recomendaciones:
- NVIDIA RTX 4090 (24GB VRAM)
- NVIDIA A100 (40GB/80GB VRAM)
- NVIDIA H100 (80GB VRAM)

Mínimo: 16GB VRAM
Drivers: NVIDIA 525.60+, CUDA 12.0+
```

---

## 💿 Requisitos de Software

### Sistema Operativo

| OS | Versión | Estado | Notas |
|----|---------|--------|-------|
| **Ubuntu Server** | 22.04 LTS | ✅ Recomendado | Soporte hasta 2027 |
| **Ubuntu Server** | 20.04 LTS | ✅ Soportado | Soporte hasta 2025 |
| **Debian** | 11/12 | ✅ Soportado | Estable |
| **CentOS/RHEL** | 8/9 | ⚠️ Compatible | Requiere ajustes |
| **Windows Server** | 2019+ | ❌ No recomendado | Problemas con Ollama |
| **macOS** | Cualquiera | ❌ No para prod | Solo desarrollo |

**Recomendación oficial:** Ubuntu Server 22.04 LTS

---

### Stack Tecnológico

#### Componente Principal: Ollama

```yaml
Nombre: Ollama
Versión: Latest (≥ 0.1.0)
Propósito: Motor de inferencia para LLMs
Puerto: 11434
Instalación: curl https://ollama.ai/install.sh | sh
Requisitos:
  - Linux x86_64 o ARM64
  - GLIBC 2.31+
  - GPU: NVIDIA CUDA 11.0+ (opcional)
```

#### Componente UI: OpenWebUI

```yaml
Nombre: Open WebUI (anteriormente Ollama WebUI)
Versión: Latest (≥ 0.1.0)
Propósito: Interfaz web para usuarios finales
Puerto: 3000
Instalación: Docker o Python
Base de datos: SQLite (incluida)
Requisitos:
  - Python 3.10+ (si no Docker)
  - Node.js 18+ (si builds custom)
  - Docker 20.10+ (método recomendado)
```

#### Modelo Base

```yaml
Nombre: gpt-oss
Versión: 20b (20 mil millones de parámetros)
Tamaño: 40-50 GB
Formato: GGUF
Cuantización: Q4_K_M (balanceado calidad/velocidad)
Descarga: ollama pull gpt-oss:20b
Tiempo descarga: 30-60 minutos (conexión rápida)
```

---

### Dependencias del Sistema

#### Ubuntu 22.04 LTS

```bash
# Actualizaciones del sistema
apt update && apt upgrade -y

# Dependencias básicas
apt install -y \
    curl \
    wget \
    git \
    build-essential \
    python3 \
    python3-pip \
    nginx \
    certbot \
    htop \
    tmux \
    vim

# Docker (si usas método Docker)
apt install -y \
    docker.io \
    docker-compose

# NVIDIA drivers (si tienes GPU)
apt install -y \
    nvidia-driver-525 \
    nvidia-cuda-toolkit
```

#### Python Packages (si instalas sin Docker)

```bash
pip3 install \
    requests \
    pyyaml \
    python-dotenv
```

---

## 🌐 Requisitos de Red

### Puertos Necesarios

| Puerto | Servicio | Interno/Externo | Notas |
|--------|----------|-----------------|-------|
| **3000** | OpenWebUI | Externo (vía Nginx) | Interface web principal |
| **11434** | Ollama | Interno SOLO | NO exponer a internet |
| **443** | Nginx (HTTPS) | Externo | Acceso público |
| **80** | Nginx (HTTP) | Externo | Redirect a 443 |

### Firewall (UFW Ejemplo)

```bash
# Permitir SSH
ufw allow 22/tcp

# Permitir HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# OpenWebUI (si no usas Nginx)
# ufw allow 3000/tcp

# Ollama: NO PERMITIR desde internet
# Solo acceso local/interno

# Activar firewall
ufw enable
```

### Requisitos de Conectividad

```
Durante instalación:
- ✅ Acceso a internet (descargar modelo 40-50 GB)
- ✅ DNS funcional
- ✅ Sin proxy restrictivo

Durante operación:
- ❌ NO requiere internet (100% offline)
- ✅ Red interna corporativa
- ✅ Acceso desde browsers corporativos
```

---

## 🔒 Requisitos de Seguridad

### SSL/TLS

```
Obligatorio en producción:
- ✅ Certificado SSL válido
- ✅ TLS 1.2 o superior
- ✅ Nginx como reverse proxy con SSL termination

Opciones:
1. Certificado corporativo (recomendado)
2. Let's Encrypt (si aplica)
3. Self-signed (solo staging/dev)
```

### Autenticación

```
OpenWebUI soporta:
- ✅ Usuarios locales (SQLite)
- ✅ LDAP (recomendado corporativo)
- ✅ OAuth 2.0 / OIDC
- ✅ SSO corporativo

Recomendación: Integrar con LDAP/AD de TV Azteca
```

### Segregación de Red

```
┌─────────────────────────────────────┐
│  Internet                           │
│  (Empleados remotos)                │
└──────────┬──────────────────────────┘
           │ HTTPS (443)
           ▼
┌─────────────────────────────────────┐
│  DMZ / Edge                         │
│  • Nginx Reverse Proxy              │
│  • SSL Termination                  │
│  • WAF (opcional)                   │
└──────────┬──────────────────────────┘
           │ HTTP (3000)
           ▼
┌─────────────────────────────────────┐
│  Internal Network                   │
│  • OpenWebUI (puerto 3000)          │
│  • Ollama (puerto 11434)            │
│  • Solo acceso interno              │
└─────────────────────────────────────┘
```

---

## 📦 Requisitos de Almacenamiento

### Layout Recomendado de Discos

```
/dev/sda1 - Sistema operativo (50 GB)
/dev/sdb1 - Modelos de Ollama (200 GB SSD/NVMe)
/dev/sdc1 - Logs y backups (100 GB)
```

### Estructura de Directorios

```
/opt/
├── ollama/
│   ├── models/              # 100-150 GB
│   │   ├── gpt-oss:20b      # 40-50 GB
│   │   └── aztecai          # 45-55 GB
│   └── logs/                # 5-10 GB
│
├── openwebui/
│   ├── backend/
│   ├── database/            # 1-5 GB (SQLite)
│   └── documents/           # 100 MB (Knowledge Base)
│
└── AztecAI_Model/          # Este paquete
    └── ...

/var/log/
├── ollama/                  # 2-5 GB (30 días)
└── openwebui/               # 1-2 GB (30 días)

/var/backups/
└── aztecai/                 # 20-30 GB
    ├── config/
    ├── knowledge_base/
    └── database/
```

---

## ⚡ Requisitos de Performance

### Benchmarks Esperados

| Métrica | Valor Esperado | Cómo Medir |
|---------|----------------|------------|
| **Primera respuesta** | 3-7 segundos | Tiempo desde submit hasta primera palabra |
| **Streaming start** | 1-2 segundos | Tiempo hasta ver cursor escribiendo |
| **Tokens/segundo** | 12-15 (CPU) / 40-60 (GPU) | Palabras generadas por segundo |
| **RAG retrieval** | < 1 segundo | Búsqueda en Knowledge Base |
| **Latencia red** | < 100ms | Ping desde cliente a servidor |
| **Uptime** | > 99.5% | Disponibilidad mensual |

### Carga Esperada

```
Usuarios concurrentes:
- Mínimo: 1-10 usuarios
- Recomendado: 10-50 usuarios
- Máximo probado: 100 usuarios*

*Con 100 usuarios, considerar:
- Load balancer
- Múltiples instancias de OpenWebUI
- Instancia dedicada de Ollama
- GPU obligatoria
```

---

## 🔄 Requisitos de Backup

### Qué Respaldar

| Item | Frecuencia | Tamaño | Criticidad |
|------|-----------|--------|------------|
| **Modelfile** | Semanal | 5 KB | 🔴 CRÍTICO |
| **Knowledge Base** | Diario | 50 MB | 🔴 CRÍTICO |
| **OpenWebUI DB** | Diario | 1-5 GB | 🟡 IMPORTANTE |
| **Configuraciones** | Semanal | 100 KB | 🟡 IMPORTANTE |
| **Logs** | Mensual | 5-10 GB | 🟢 OPCIONAL |
| **Modelo aztecai** | Mensual | 45 GB | 🟢 OPCIONAL* |

*Opcional porque se puede recrear desde Modelfile + modelo base

### Estrategia de Backup

```bash
# Backup diario automatizado
/var/backups/aztecai/
├── 2025-11-05/
│   ├── modelfile
│   ├── knowledge_base.md
│   ├── openwebui.db
│   └── configs/
├── 2025-11-04/
└── ...

Retención: 30 días
Rotación: Automática
Destino: Storage corporativo + Offsite
```

---

## 🛠️ Herramientas de Monitoreo

### Obligatorias

```bash
# Monitoreo de recursos
htop              # CPU, RAM en tiempo real
iostat            # I/O de disco
nvidia-smi        # GPU (si aplica)

# Monitoreo de servicios
systemctl status  # Estado de servicios
journalctl        # Logs de systemd

# Monitoreo de red
netstat -tulpn    # Puertos abiertos
ss -tulpn         # Conexiones activas
```

### Recomendadas

```
Prometheus + Grafana
- Métricas históricas
- Dashboards visuales
- Alertas automáticas

ELK Stack
- Agregación de logs
- Búsqueda avanzada
- Análisis de errores

Uptime monitoring
- Pingdom
- StatusCake
- Nagios
```

---

## 🧪 Requisitos para Ambientes

### Desarrollo (Local)

```
CPU: 8 cores
RAM: 16 GB
Storage: 100 GB
OS: macOS, Ubuntu, Windows
Propósito: Pruebas de Modelfile y KB
```

### Staging (Pre-Producción)

```
CPU: 16 cores
RAM: 32 GB
Storage: 200 GB
OS: Ubuntu 22.04 LTS
Propósito: Validación antes de prod
```

### Producción

```
CPU: 32 cores
RAM: 64 GB
Storage: 500 GB NVMe
GPU: NVIDIA 24GB (recomendado)
OS: Ubuntu 22.04 LTS
Propósito: Ambiente principal
```

---

## ✅ Checklist de Verificación

Antes de proceder con la instalación, verificar:

### Hardware
- [ ] CPU: 16+ cores disponibles
- [ ] RAM: 64+ GB instalada
- [ ] Almacenamiento: 500+ GB SSD/NVMe
- [ ] GPU: NVIDIA 16GB+ (opcional)
- [ ] Red: 1 Gbps+ ethernet

### Software
- [ ] Ubuntu 22.04 LTS instalado
- [ ] Sistema actualizado (`apt update && apt upgrade`)
- [ ] Acceso root/sudo funcional
- [ ] Python 3.10+ disponible
- [ ] Docker instalado (si usas método Docker)

### Red
- [ ] Puertos 3000, 11434, 443 libres
- [ ] Firewall configurado
- [ ] DNS funcional
- [ ] Certificado SSL preparado
- [ ] Conectividad a internet (para instalación)

### Seguridad
- [ ] Plan de acceso de usuarios definido
- [ ] Integración LDAP/SSO planeada
- [ ] Políticas de backup configuradas
- [ ] Monitoreo de logs habilitado

---

## 📊 Tabla Comparativa de Configuraciones

| Escenario | CPU | RAM | Storage | GPU | Costo Relativo | Usuarios Concurrentes |
|-----------|-----|-----|---------|-----|----------------|---------------------|
| **Mínimo** | 8 cores | 32 GB | 100 GB SSD | No | $ | 1-10 |
| **Recomendado** | 16 cores | 64 GB | 500 GB NVMe | Sí (16GB) | $$ | 10-50 |
| **Óptimo** | 32 cores | 128 GB | 1 TB NVMe | Sí (24GB+) | $$$ | 50-100+ |

---

## 🎯 Recomendación Final

Para TV Azteca en producción, recomendamos:

```yaml
Configuración Recomendada para Producción:

CPU: 16-32 cores (Intel Xeon o AMD EPYC)
RAM: 64 GB DDR4 3200MHz
Storage: 500 GB NVMe SSD
GPU: NVIDIA RTX 4090 24GB (altamente recomendado)
OS: Ubuntu Server 22.04 LTS
Red: 1 Gbps ethernet dedicado
SSL: Certificado corporativo
Auth: Integración con LDAP/AD

Justificación:
- Balance óptimo costo/performance
- Soporta 10-50 usuarios concurrentes
- Experiencia de usuario fluida (3-7 seg)
- Escalable a 100+ usuarios con ajustes
```

---

## 📝 Notas Adicionales

### Sobre GPU

```
¿Es obligatoria la GPU?
- NO para funcionar
- SÍ para experiencia óptima

Con GPU:
✅ 3-5x más rápido
✅ Libera CPU
✅ Mejor experiencia usuario
✅ Soporta más usuarios concurrentes

Sin GPU:
⚠️ 12-15 tokens/seg (aceptable)
⚠️ CPU al 80% durante inferencia
⚠️ Menos usuarios concurrentes
```

### Sobre Almacenamiento

```
¿Por qué 500 GB si el modelo pesa 50 GB?

Breakdown real:
- Modelo base: 40-50 GB
- Modelo custom: 45-55 GB
- OpenWebUI: 5-10 GB
- Logs (90 días): 15-30 GB
- Backups (30 días): 100-150 GB
- Buffer para crecimiento: 200 GB

Total: ~500 GB
```

### Sobre RAM

```
¿Por qué 64 GB si el modelo usa 40 GB?

Modelo en memoria: 40 GB
Sistema operativo: 4-6 GB
OpenWebUI: 2-4 GB
Buffer/Cache: 8-10 GB
Overhead: 5-10 GB

Total activo: 59-70 GB
Por eso 64 GB es el mínimo cómodo
```

---

## 🚀 Próximo Paso

Una vez verificados todos los requisitos:

**Lee:** `GUIA_INSTALACION_SERVIDOR.md`

O ejecuta el script automatizado:

```bash
cd AztecAI_Model/04_Scripts
sudo ./deploy_production.sh
```

---

**Documento creado:** 5 de Noviembre 2025  
**Versión:** 1.0  
**Validado en:** Ubuntu 22.04 LTS, 64GB RAM, 16 cores  
**Mantenido por:** IAA - Héctor Romero Pico  

---

*"La infraestructura adecuada es la base del éxito."* 🖥️  
*AztecAI - Requisitos Técnicos* 🇲🇽

