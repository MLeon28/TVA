# 📖 Guía de Instalación en Servidor - Método Manual

**Documento:** Instalación Paso a Paso  
**Audiencia:** Ingenieros DevOps  
**Tiempo estimado:** 2-3 horas  
**Última actualización:** 5 de Noviembre 2025  

---

## ⚠️ Nota Importante

**Método recomendado:** Usar el script automatizado `deploy_production.sh`

Esta guía manual es para:
- Troubleshooting del script automatizado
- Ambientes con requisitos especiales
- Comprensión profunda del proceso

---

## 📋 Pre-Requisitos

- Ubuntu 22.04 LTS
- Acceso root/sudo
- 64GB+ RAM
- 500GB+ almacenamiento
- Conexión a internet estable

---

## 🔧 Paso 1: Preparación del Sistema

### 1.1 Actualizar Sistema

```bash
sudo apt update
sudo apt upgrade -y
```

### 1.2 Instalar Dependencias

```bash
sudo apt install -y \
    curl \
    wget \
    git \
    build-essential \
    python3 \
    python3-pip \
    htop \
    vim \
    jq
```

---

## 🤖 Paso 2: Instalar Ollama

### 2.1 Descargar e Instalar

```bash
curl -fsSL https://ollama.ai/install.sh | sh
```

### 2.2 Verificar Instalación

```bash
ollama --version
systemctl status ollama
```

**Salida esperada:** Servicio activo y corriendo

### 2.3 Habilitar Auto-Start

```bash
sudo systemctl enable ollama
```

---

## 📥 Paso 3: Descargar Modelo Base

### 3.1 Descargar gpt-oss:20b

```bash
ollama pull gpt-oss:20b
```

⚠️ **Advertencia:** Descarga 40-50 GB, toma 30-60 minutos

### 3.2 Verificar Descarga

```bash
ollama list
```

**Salida esperada:**
```
NAME            ID              SIZE
gpt-oss:20b     [hash]         48 GB
```

---

## 🎨 Paso 4: Crear Modelo Personalizado

### 4.1 Ubicar Modelfile

```bash
cd /opt/AztecAI_Model/02_Modelfiles
ls -lh Modelfile.AztecAI.Professional
```

### 4.2 Crear Modelo

```bash
ollama create aztecai -f Modelfile.AztecAI.Professional
```

**Tiempo:** 2-5 minutos

### 4.3 Verificar Modelo

```bash
ollama list | grep aztecai
```

### 4.4 Probar Modelo

```bash
ollama run aztecai "Hola, ¿estás funcionando?"
```

**Respuesta esperada:** Texto coherente en español con formato profesional

---

## 🌐 Paso 5: Instalar OpenWebUI

### 5.1 Instalar Docker (si no está instalado)

```bash
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
```

### 5.2 Ejecutar OpenWebUI

```bash
docker run -d \
    --name open-webui \
    --restart always \
    -p 3000:8080 \
    -v open-webui:/app/backend/data \
    --add-host=host.docker.internal:host-gateway \
    ghcr.io/open-webui/open-webui:main
```

### 5.3 Verificar Contenedor

```bash
docker ps | grep open-webui
```

### 5.4 Acceder a Interface

Abrir navegador: `http://server-ip:3000`

**Primera vez:** Crear cuenta de administrador

---

## 📚 Paso 6: Importar Knowledge Base

### 6.1 Acceder a OpenWebUI

1. Login en `http://server-ip:3000`
2. Ir a **Workspace** → **Documents**
3. Click en **+ Upload Document**

### 6.2 Subir Knowledge Base

Ubicación del archivo:
```
/opt/AztecAI_Model/03_Knowledge_Base/AztecAI_Complete_Knowledge_Base.md
```

Subir este archivo en OpenWebUI

### 6.3 Verificar Importación

- Documento aparece en lista
- Tamaño: ~50 MB
- Sin errores

---

## 🔍 Paso 7: Configurar RAG

### 7.1 Acceder a Configuración

OpenWebUI → **Settings** → **RAG**

### 7.2 Crear Collection

1. Click en **Collections**
2. **Create Collection**
3. Nombre: `AztecAI`
4. **Save**

### 7.3 Configurar Parámetros

```
Top-K: 5
Chunk Size: 1500
Chunk Overlap: 150
```

### 7.4 Activar RAG

- Toggle **RAG Enabled**: ON
- Select Collection: **AztecAI**
- **Save**

---

## 🔒 Paso 8: Configurar Firewall

### 8.1 Instalar UFW (si no está)

```bash
sudo apt install -y ufw
```

### 8.2 Configurar Reglas

```bash
# SSH
sudo ufw allow 22/tcp

# OpenWebUI
sudo ufw allow 3000/tcp

# HTTP/HTTPS (para Nginx después)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Activar
sudo ufw enable
```

### 8.3 Verificar Firewall

```bash
sudo ufw status
```

---

## 🔐 Paso 9: Configurar Nginx + SSL (Producción)

### 9.1 Instalar Nginx

```bash
sudo apt install -y nginx certbot python3-certbot-nginx
```

### 9.2 Configurar Reverse Proxy

Crear archivo: `/etc/nginx/sites-available/aztecai`

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### 9.3 Activar Configuración

```bash
sudo ln -s /etc/nginx/sites-available/aztecai /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 9.4 Configurar SSL con Certbot

```bash
sudo certbot --nginx -d your-domain.com
```

---

## ✅ Paso 10: Verificación

### 10.1 Ejecutar Script de Verificación

```bash
cd /opt/AztecAI_Model/04_Scripts
./verify_installation.sh
```

### 10.2 Tests Manuales

**Test 1: Ollama**
```bash
systemctl status ollama
ollama list
```

**Test 2: Modelo**
```bash
ollama run aztecai "¿Qué canales tiene TV Azteca?"
```

**Test 3: OpenWebUI**
- Acceder a URL
- Login
- Nueva conversación
- Preguntar: "¿Qué es TV Azteca?"
- Verificar formato profesional

**Test 4: RAG**
- Respuesta debe incluir información de Knowledge Base
- Citar fuentes al final

---

## 🔄 Paso 11: Configurar Backups

### 11.1 Crear Script de Backup

Crear archivo: `/opt/backup_aztecai.sh`

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/aztecai"
DATE=$(date +%Y-%m-%d)

mkdir -p "$BACKUP_DIR/$DATE"

# Backup Modelfile
cp /opt/AztecAI_Model/02_Modelfiles/Modelfile.AztecAI.Professional \
   "$BACKUP_DIR/$DATE/"

# Backup Knowledge Base
cp /opt/AztecAI_Model/03_Knowledge_Base/*.md \
   "$BACKUP_DIR/$DATE/"

# Backup OpenWebUI DB
docker exec open-webui \
    cp /app/backend/data/webui.db /tmp/
docker cp open-webui:/tmp/webui.db \
    "$BACKUP_DIR/$DATE/"

# Comprimir
cd "$BACKUP_DIR"
tar -czf "$DATE.tar.gz" "$DATE"
rm -rf "$DATE"

echo "Backup completado: $BACKUP_DIR/$DATE.tar.gz"
```

### 11.2 Dar Permisos

```bash
chmod +x /opt/backup_aztecai.sh
```

### 11.3 Programar Cron

```bash
sudo crontab -e
```

Agregar línea:
```
0 2 * * * /opt/backup_aztecai.sh
```

(Backup diario a las 2 AM)

---

## 📊 Paso 12: Configurar Monitoreo

### 12.1 Logs de Ollama

```bash
# Ver logs en tiempo real
journalctl -u ollama -f

# Últimos 100 logs
journalctl -u ollama -n 100

# Logs de hoy
journalctl -u ollama --since today
```

### 12.2 Logs de OpenWebUI

```bash
# Ver logs en tiempo real
docker logs -f open-webui

# Últimos 100 logs
docker logs --tail 100 open-webui

# Buscar errores
docker logs open-webui 2>&1 | grep -i error
```

---

## ✅ Resumen de Comandos Clave

```bash
# Estado de servicios
systemctl status ollama
docker ps

# Reiniciar servicios
systemctl restart ollama
docker restart open-webui

# Ver modelos
ollama list

# Probar modelo
ollama run aztecai "Hola"

# Ver logs
journalctl -u ollama -f
docker logs -f open-webui

# Verificar puertos
ss -tulpn | grep -E "3000|11434"

# Ver uso de recursos
htop
```

---

## 🆘 Troubleshooting Común

### Problema: Ollama no inicia

**Solución:**
```bash
sudo systemctl restart ollama
journalctl -u ollama -n 50
```

### Problema: Modelo no aparece

**Solución:**
```bash
ollama list
ollama create aztecai -f /path/to/Modelfile
```

### Problema: OpenWebUI no accesible

**Solución:**
```bash
docker ps -a
docker start open-webui
docker logs open-webui
```

### Problema: RAG no funciona

**Solución:**
1. Verificar Knowledge Base importada
2. Recrear Collection "AztecAI"
3. Iniciar conversación NUEVA
4. Top-K mínimo: 5

---

## 📝 Checklist Final

- [ ] Ollama instalado y activo
- [ ] Modelo gpt-oss:20b descargado
- [ ] Modelo aztecai creado
- [ ] OpenWebUI corriendo
- [ ] Knowledge Base importada
- [ ] RAG configurado (Collection: AztecAI)
- [ ] Firewall configurado
- [ ] Nginx + SSL configurado (producción)
- [ ] Backups programados
- [ ] Monitoreo configurado
- [ ] Script verify_installation.sh pasa
- [ ] Tests manuales exitosos

---

## 🎯 Siguiente Paso

Ver: `CHECKLIST_VERIFICACION.md` para validación completa

---

**Documento creado:** 5 de Noviembre 2025  
**Versión:** 1.0  
**Mantenido por:** IAA - Héctor Romero Pico  

---

*"Paso a paso, sin prisas pero sin pausas."* 📖  
*AztecAI - Guía de Instalación* 🇲🇽

