# 🚀 Instalación de AztecAI desde GitHub

**Versión:** 1.0  
**Fecha:** 6 de Noviembre 2025  
**Repositorio:** https://github.com/MLeon28/TVA  
**Ruta del Modelo:** `AztecAI_Model_V1/`

---

## 📋 Descripción

Este documento explica cómo instalar AztecAI directamente desde el repositorio de GitHub en un servidor de producción.

---

## ⚡ Instalación Rápida (Método Recomendado)

### Opción 1: Instalación con un solo comando

```bash
curl -fsSL https://raw.githubusercontent.com/MLeon28/TVA/main/AztecAI_Model_V1/install_from_github.sh | sudo bash
```

Este comando:
1. ✅ Descarga el script de instalación
2. ✅ Clona el repositorio completo
3. ✅ Verifica la estructura
4. ✅ Ejecuta el despliegue automatizado
5. ✅ Configura todos los servicios

**Tiempo estimado:** 30-60 minutos  
**Descarga:** ~40-50 GB

---

### Opción 2: Instalación manual paso a paso

Si prefieres más control sobre el proceso:

```bash
# 1. Descargar el script de instalación
wget https://raw.githubusercontent.com/MLeon28/TVA/main/AztecAI_Model_V1/install_from_github.sh

# 2. Dar permisos de ejecución
chmod +x install_from_github.sh

# 3. Ejecutar el script
sudo ./install_from_github.sh
```

---

## 📦 ¿Qué hace el script de instalación?

El script `install_from_github.sh` realiza las siguientes acciones:

### 1. Verificaciones Previas
- ✅ Verifica que se ejecute como root/sudo
- ✅ Verifica el sistema operativo (Ubuntu 22.04 LTS recomendado)
- ✅ Verifica conexión a internet
- ✅ Verifica espacio en disco (mínimo 100GB)

### 2. Instalación de Dependencias
- ✅ Instala Git si no está presente
- ✅ Actualiza repositorios del sistema

### 3. Descarga del Repositorio
- ✅ Clona el repositorio desde GitHub
- ✅ Ubicación: `/opt/TVA/`
- ✅ Verifica la estructura del proyecto
- ✅ Valida archivos críticos

### 4. Ejecución del Despliegue
- ✅ Ejecuta `deploy_production.sh` automáticamente
- ✅ Instala Ollama
- ✅ Descarga modelo base `gpt-oss:20b`
- ✅ Crea modelo personalizado `aztecai`
- ✅ Instala OpenWebUI con Docker
- ✅ Configura servicios systemd

### 5. Verificación Final
- ✅ Muestra información de acceso
- ✅ Proporciona comandos útiles
- ✅ Indica próximos pasos

---

## 🖥️ Requisitos del Servidor

### Hardware Mínimo
| Componente | Mínimo | Recomendado |
|------------|---------|-------------|
| **CPU** | 8 cores | 16+ cores |
| **RAM** | 32 GB | 64 GB |
| **Almacenamiento** | 100 GB SSD | 500 GB NVMe |
| **GPU** | Opcional | NVIDIA 16GB+ |

### Software
- **Sistema Operativo:** Ubuntu 22.04 LTS (recomendado)
- **Acceso:** root o sudo
- **Conexión:** Internet estable (solo durante instalación)

### Puertos Requeridos
- **3000** - OpenWebUI (interfaz web)
- **11434** - Ollama (API del modelo)
- **443** - HTTPS (producción, opcional)

---

## 📂 Estructura Después de la Instalación

```
/opt/TVA/
└── AztecAI_Model_V1/
    ├── 01_Documentacion/          # Documentación completa
    ├── 02_Modelfiles/             # Configuración del modelo
    │   └── Modelfile.AztecAI.Professional
    ├── 03_Knowledge_Base/         # Base de conocimiento
    │   └── AztecAI_Complete_Knowledge_Base.md
    ├── 04_Scripts/                # Scripts de instalación
    │   ├── deploy_production.sh   # Script principal
    │   └── verify_installation.sh # Verificación
    ├── 05_Configuracion/          # Configuraciones
    └── 06_Tests/                  # Tests de validación
```

---

## ✅ Verificación de la Instalación

Después de que el script termine, verifica que todo funcione correctamente:

### 1. Ejecutar Script de Verificación

```bash
cd /opt/TVA/AztecAI_Model_V1/04_Scripts
./verify_installation.sh
```

### 2. Verificar Servicios Manualmente

```bash
# Verificar Ollama
systemctl status ollama
ollama list

# Verificar OpenWebUI
docker ps | grep open-webui

# Probar el modelo
ollama run aztecai "Hola, ¿quién eres?"
```

### 3. Acceder a la Interfaz Web

Abre tu navegador y accede a:
```
http://[IP_DEL_SERVIDOR]:3000
```

---

## 🔧 Configuración Post-Instalación

### 1. Crear Usuario Administrador en OpenWebUI

1. Accede a `http://[IP_DEL_SERVIDOR]:3000`
2. Crea la primera cuenta (será administrador automáticamente)
3. Configura nombre de usuario y contraseña

### 2. Importar Knowledge Base

1. En OpenWebUI, ve a **Workspace → Documents**
2. Click en **"Upload Document"**
3. Selecciona: `/opt/TVA/AztecAI_Model_V1/03_Knowledge_Base/AztecAI_Complete_Knowledge_Base.md`
4. Espera a que se procese el documento

### 3. Configurar RAG (Retrieval-Augmented Generation)

1. Ve a **Workspace → Collections**
2. Crea una nueva colección llamada **"AztecAI"** (exactamente así)
3. Agrega el documento de Knowledge Base a la colección
4. Configura:
   - **Top-K:** 5
   - **Similarity Threshold:** 0.7

### 4. Seleccionar el Modelo

1. En el chat, selecciona el modelo **"aztecai"**
2. Activa la colección **"AztecAI"** para usar RAG
3. Realiza una pregunta de prueba

---

## 🧪 Pruebas de Validación

### Prueba 1: Respuesta Básica
```
Pregunta: "¿Quién eres?"
Esperado: Respuesta en español, formato profesional
```

### Prueba 2: Información Corporativa (RAG)
```
Pregunta: "¿Cuál es la misión de TV Azteca?"
Esperado: Información extraída del Knowledge Base
```

### Prueba 3: Formato Profesional
```
Pregunta: "Explica qué es la inteligencia artificial"
Esperado: Formato "Pirámide Invertida" con secciones claras
```

---

## 🔄 Actualización del Sistema

### Actualizar Knowledge Base (Sin Downtime)

```bash
# 1. Editar el archivo
vim /opt/TVA/AztecAI_Model_V1/03_Knowledge_Base/AztecAI_Complete_Knowledge_Base.md

# 2. Re-importar en OpenWebUI
# Interface → Workspace → Documents → Replace
```

### Actualizar Modelo (Downtime 2-5 min)

```bash
# 1. Editar Modelfile
vim /opt/TVA/AztecAI_Model_V1/02_Modelfiles/Modelfile.AztecAI.Professional

# 2. Recrear modelo
cd /opt/TVA/AztecAI_Model_V1/02_Modelfiles
ollama create aztecai -f Modelfile.AztecAI.Professional

# 3. Reiniciar OpenWebUI
docker restart open-webui
```

### Actualizar desde GitHub

```bash
# 1. Ir al directorio del repositorio
cd /opt/TVA

# 2. Hacer pull de los últimos cambios
git pull origin main

# 3. Re-ejecutar despliegue si es necesario
cd AztecAI_Model_V1/04_Scripts
sudo ./deploy_production.sh
```

---

## 🐛 Troubleshooting

### Problema: "Error al clonar el repositorio"

**Solución:**
```bash
# Verificar conexión a GitHub
ping github.com

# Verificar que Git esté instalado
git --version

# Clonar manualmente
cd /opt
git clone https://github.com/MLeon28/TVA.git
```

### Problema: "Puerto 3000 ya está en uso"

**Solución:**
```bash
# Ver qué está usando el puerto
sudo lsof -i :3000

# Detener el servicio conflictivo
sudo systemctl stop [servicio]

# O cambiar el puerto en el script
```

### Problema: "Modelo no responde"

**Solución:**
```bash
# Verificar que Ollama esté corriendo
systemctl status ollama

# Reiniciar Ollama
sudo systemctl restart ollama

# Verificar logs
journalctl -u ollama -f
```

### Problema: "OpenWebUI no inicia"

**Solución:**
```bash
# Ver logs del contenedor
docker logs open-webui

# Reiniciar contenedor
docker restart open-webui

# Recrear contenedor
docker stop open-webui
docker rm open-webui
cd /opt/TVA/AztecAI_Model_V1/04_Scripts
sudo ./deploy_production.sh
```

---

## 📞 Soporte

### Documentación Completa
Consulta la documentación detallada en:
```
/opt/TVA/AztecAI_Model_V1/01_Documentacion/
```

Archivos importantes:
- **00_INICIO_AQUI.md** - Guía de inicio
- **GUIA_INSTALACION_SERVIDOR.md** - Instalación manual
- **TROUBLESHOOTING_PRODUCCION.md** - Solución de problemas
- **ARQUITECTURA_TECNICA.md** - Arquitectura del sistema

### Logs del Sistema
```bash
# Logs de Ollama
journalctl -u ollama -f

# Logs de OpenWebUI
docker logs -f open-webui

# Logs del sistema
journalctl -xe
```

---

## 🎯 Checklist de Instalación Exitosa

- [ ] Script de instalación ejecutado sin errores
- [ ] Ollama instalado y corriendo
- [ ] Modelo `gpt-oss:20b` descargado
- [ ] Modelo `aztecai` creado
- [ ] OpenWebUI accesible en puerto 3000
- [ ] Usuario administrador creado
- [ ] Knowledge Base importado
- [ ] Colección "AztecAI" configurada con RAG
- [ ] Pruebas de validación exitosas
- [ ] Formato profesional funcionando
- [ ] RAG recuperando información correctamente

---

## 📊 Métricas Esperadas

Después de la instalación, deberías ver:

- **Primera respuesta:** 3-7 segundos
- **Streaming start:** 1-2 segundos
- **Tokens/segundo:** 12-15
- **KB retrieval:** <1 segundo
- **Uso RAM:** 16-18GB por sesión

---

## 🔒 Seguridad

### Recomendaciones Post-Instalación

1. **Configurar Firewall**
   ```bash
   sudo ufw allow 3000/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

2. **Configurar HTTPS con Nginx**
   - Ver: `/opt/TVA/AztecAI_Model_V1/05_Configuracion/nginx.conf`

3. **Configurar Autenticación Corporativa**
   - Integrar con LDAP/SSO de TV Azteca

4. **Backups Automáticos**
   ```bash
   # Backup de configuración
   cd /opt/TVA/AztecAI_Model_V1/04_Scripts
   ./backup_config.sh
   ```

---

## ✨ Próximos Pasos

Una vez instalado:

1. **Día 1:** Validación inicial con usuarios piloto
2. **Semana 1:** Estabilización y ajustes
3. **Semana 2-4:** Rollout progresivo
4. **Continuo:** Mantenimiento y actualizaciones

---

**Última actualización:** 6 de Noviembre 2025  
**Versión:** 1.0  
**Estado:** ✅ Listo para Uso

---

*AztecAI - Powered by TV Azteca / Grupo Salinas* 🇲🇽

