# 📘 Guía Completa de Instalación desde GitHub

**Repositorio:** https://github.com/MLeon28/TVA  
**Ruta del Modelo:** `AztecAI_Model_V1/`  
**Versión:** 1.0  
**Fecha:** 6 de Noviembre 2025

---

## 🎯 Resumen Ejecutivo

Este documento describe **3 métodos** para instalar AztecAI desde GitHub en un servidor de producción:

1. **Instalación Ultra-Rápida** (1 comando) - Recomendado
2. **Instalación Rápida** (script simplificado)
3. **Instalación Manual** (control total)

---

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener:

- ✅ **Servidor con Ubuntu 22.04 LTS**
- ✅ **Acceso root o sudo**
- ✅ **32GB+ RAM** (64GB recomendado)
- ✅ **100GB+ almacenamiento libre** (500GB recomendado)
- ✅ **Conexión a internet estable**
- ✅ **Puertos 3000 y 11434 disponibles**

---

## 🚀 Método 1: Instalación Ultra-Rápida (Recomendado)

### Un solo comando para instalar todo

```bash
curl -fsSL https://raw.githubusercontent.com/MLeon28/TVA/main/AztecAI_Model_V1/install_from_github.sh | sudo bash
```

### ¿Qué hace este comando?

1. Descarga el script de instalación desde GitHub
2. Verifica requisitos del sistema
3. Clona el repositorio completo
4. Ejecuta el despliegue automatizado
5. Instala Ollama + OpenWebUI
6. Descarga y configura el modelo
7. Muestra información de acceso

**⏱️ Tiempo:** 30-60 minutos  
**📦 Descarga:** ~40-50 GB  
**🎯 Resultado:** Sistema completamente funcional

---

## ⚡ Método 2: Instalación Rápida (Script Simplificado)

Si prefieres descargar el script primero:

```bash
# Descargar script simplificado
wget https://raw.githubusercontent.com/MLeon28/TVA/main/AztecAI_Model_V1/quick_install.sh

# Dar permisos
chmod +x quick_install.sh

# Ejecutar
sudo ./quick_install.sh
```

Este método es útil si:
- Quieres revisar el script antes de ejecutarlo
- Tienes restricciones de seguridad con `curl | bash`
- Necesitas ejecutar el script múltiples veces

---

## 🔧 Método 3: Instalación Manual (Control Total)

Para máximo control sobre cada paso:

### Paso 1: Clonar el Repositorio

```bash
# Ir al directorio de instalación
cd /opt

# Clonar repositorio
sudo git clone https://github.com/MLeon28/TVA.git

# Verificar descarga
ls -la TVA/AztecAI_Model_V1/
```

### Paso 2: Verificar Estructura

```bash
cd /opt/TVA/AztecAI_Model_V1

# Verificar archivos críticos
ls -la 04_Scripts/deploy_production.sh
ls -la 02_Modelfiles/Modelfile.AztecAI.Professional
ls -la 03_Knowledge_Base/AztecAI_Complete_Knowledge_Base.md
```

### Paso 3: Dar Permisos de Ejecución

```bash
chmod +x 04_Scripts/*.sh
```

### Paso 4: Ejecutar Despliegue

```bash
cd 04_Scripts
sudo ./deploy_production.sh
```

### Paso 5: Verificar Instalación

```bash
./verify_installation.sh
```

---

## 📂 Estructura del Repositorio

Después de clonar, tendrás:

```
/opt/TVA/
└── AztecAI_Model_V1/
    ├── 01_Documentacion/
    │   ├── 00_INICIO_AQUI.md
    │   ├── GUIA_INSTALACION_SERVIDOR.md
    │   ├── ARQUITECTURA_TECNICA.md
    │   ├── TROUBLESHOOTING_PRODUCCION.md
    │   └── ...
    │
    ├── 02_Modelfiles/
    │   └── Modelfile.AztecAI.Professional    ← Configuración del modelo
    │
    ├── 03_Knowledge_Base/
    │   └── AztecAI_Complete_Knowledge_Base.md ← Base de conocimiento
    │
    ├── 04_Scripts/
    │   ├── deploy_production.sh              ← Script principal
    │   ├── verify_installation.sh            ← Verificación
    │   └── prepare_knowledge_base.py
    │
    ├── 05_Configuracion/
    │   ├── nginx.conf
    │   └── environment_variables.env
    │
    └── 06_Tests/
        └── test_*.py
```

---

## ✅ Verificación Post-Instalación

### 1. Verificar Servicios

```bash
# Verificar Ollama
systemctl status ollama
ollama list

# Verificar OpenWebUI
docker ps | grep open-webui

# Verificar puertos
ss -tuln | grep -E ':(3000|11434)'
```

### 2. Probar el Modelo

```bash
ollama run aztecai "Hola, ¿quién eres?"
```

**Respuesta esperada:** Texto en español con formato profesional

### 3. Acceder a la Interfaz Web

Abre tu navegador:
```
http://[IP_DEL_SERVIDOR]:3000
```

### 4. Ejecutar Script de Verificación

```bash
cd /opt/TVA/AztecAI_Model_V1/04_Scripts
./verify_installation.sh
```

---

## 🔧 Configuración Inicial en OpenWebUI

### 1. Crear Usuario Administrador

1. Accede a `http://[IP]:3000`
2. Crea tu primera cuenta (será admin automáticamente)
3. Configura usuario y contraseña

### 2. Importar Knowledge Base

```bash
# Ruta del archivo a importar:
/opt/TVA/AztecAI_Model_V1/03_Knowledge_Base/AztecAI_Complete_Knowledge_Base.md
```

**En OpenWebUI:**
1. Ve a **Workspace → Documents**
2. Click **"Upload Document"**
3. Selecciona el archivo de Knowledge Base
4. Espera a que se procese

### 3. Configurar RAG

1. Ve a **Workspace → Collections**
2. Crea colección: **"AztecAI"** (exactamente así)
3. Agrega el documento a la colección
4. Configura:
   - **Top-K:** 5
   - **Similarity Threshold:** 0.7

### 4. Seleccionar Modelo

1. En el chat, selecciona modelo **"aztecai"**
2. Activa colección **"AztecAI"**
3. Realiza prueba

---

## 🧪 Pruebas de Validación

### Prueba 1: Respuesta Básica
```
Pregunta: "¿Quién eres?"
✅ Esperado: Respuesta en español, formato profesional
```

### Prueba 2: RAG Funcionando
```
Pregunta: "¿Cuál es la misión de TV Azteca?"
✅ Esperado: Información del Knowledge Base
```

### Prueba 3: Formato Profesional
```
Pregunta: "Explica qué es la inteligencia artificial"
✅ Esperado: Formato "Pirámide Invertida"
```

---

## 🔄 Actualización del Sistema

### Actualizar desde GitHub

```bash
cd /opt/TVA
git pull origin main
```

### Actualizar Knowledge Base

```bash
# Editar
vim /opt/TVA/AztecAI_Model_V1/03_Knowledge_Base/AztecAI_Complete_Knowledge_Base.md

# Re-importar en OpenWebUI (sin downtime)
```

### Actualizar Modelo

```bash
cd /opt/TVA/AztecAI_Model_V1/02_Modelfiles
ollama create aztecai -f Modelfile.AztecAI.Professional
docker restart open-webui
```

---

## 🐛 Solución de Problemas Comunes

### Error: "No se puede conectar a GitHub"

```bash
# Verificar conexión
ping github.com

# Verificar DNS
nslookup github.com

# Usar HTTPS en lugar de SSH
git clone https://github.com/MLeon28/TVA.git
```

### Error: "Puerto 3000 ya está en uso"

```bash
# Ver qué usa el puerto
sudo lsof -i :3000

# Detener servicio
sudo systemctl stop [servicio]
```

### Error: "Espacio insuficiente"

```bash
# Verificar espacio
df -h

# Limpiar Docker
docker system prune -a

# Limpiar Ollama
ollama rm [modelos-no-usados]
```

### Error: "Modelo no responde"

```bash
# Reiniciar Ollama
sudo systemctl restart ollama

# Ver logs
journalctl -u ollama -f

# Recrear modelo
cd /opt/TVA/AztecAI_Model_V1/02_Modelfiles
ollama create aztecai -f Modelfile.AztecAI.Professional
```

---

## 📊 Métricas de Éxito

Después de la instalación exitosa:

| Métrica | Valor Esperado |
|---------|----------------|
| Primera respuesta | 3-7 segundos |
| Streaming start | 1-2 segundos |
| Tokens/segundo | 12-15 |
| KB retrieval | <1 segundo |
| Uso RAM | 16-18GB/sesión |

---

## 🔒 Seguridad Post-Instalación

### 1. Configurar Firewall

```bash
sudo ufw allow 3000/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 2. Configurar HTTPS

```bash
# Usar configuración de ejemplo
cp /opt/TVA/AztecAI_Model_V1/05_Configuracion/nginx.conf /etc/nginx/sites-available/aztecai
```

### 3. Backups

```bash
# Backup de configuración
cd /opt/TVA/AztecAI_Model_V1/04_Scripts
./backup_config.sh
```

---

## 📞 Recursos Adicionales

### Documentación Completa

```bash
cd /opt/TVA/AztecAI_Model_V1/01_Documentacion
ls -la
```

**Archivos importantes:**
- `00_INICIO_AQUI.md` - Guía de inicio
- `GUIA_INSTALACION_SERVIDOR.md` - Instalación detallada
- `TROUBLESHOOTING_PRODUCCION.md` - Solución de problemas
- `ARQUITECTURA_TECNICA.md` - Arquitectura del sistema

### Logs del Sistema

```bash
# Ollama
journalctl -u ollama -f

# OpenWebUI
docker logs -f open-webui

# Sistema
journalctl -xe
```

### Comandos Útiles

```bash
# Ver modelos instalados
ollama list

# Probar modelo
ollama run aztecai

# Ver contenedores Docker
docker ps

# Reiniciar servicios
sudo systemctl restart ollama
docker restart open-webui
```

---

## 📋 Checklist de Instalación Exitosa

- [ ] Repositorio clonado correctamente
- [ ] Estructura verificada
- [ ] Script de despliegue ejecutado sin errores
- [ ] Ollama instalado y corriendo
- [ ] Modelo `gpt-oss:20b` descargado
- [ ] Modelo `aztecai` creado
- [ ] OpenWebUI accesible en puerto 3000
- [ ] Usuario administrador creado
- [ ] Knowledge Base importado
- [ ] Colección "AztecAI" configurada
- [ ] RAG funcionando correctamente
- [ ] Pruebas de validación exitosas
- [ ] Formato profesional verificado

---

## 🎯 Próximos Pasos

1. **Día 1:** Validación con usuarios piloto
2. **Semana 1:** Estabilización y ajustes
3. **Semana 2-4:** Rollout progresivo
4. **Continuo:** Mantenimiento y actualizaciones

---

## 📈 Comparación de Métodos

| Característica | Ultra-Rápida | Rápida | Manual |
|----------------|--------------|--------|--------|
| **Comandos** | 1 | 3 | 10+ |
| **Tiempo** | 30-60 min | 30-60 min | 30-60 min |
| **Control** | Bajo | Medio | Alto |
| **Dificultad** | Muy Fácil | Fácil | Media |
| **Recomendado para** | Producción | Testing | Desarrollo |

---

**Última actualización:** 6 de Noviembre 2025  
**Versión:** 1.0  
**Estado:** ✅ Listo para Uso

---

*AztecAI - Powered by TV Azteca / Grupo Salinas* 🇲🇽

