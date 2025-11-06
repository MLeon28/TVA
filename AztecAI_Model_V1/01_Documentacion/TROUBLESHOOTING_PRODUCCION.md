# 🔧 Troubleshooting en Producción

**Documento:** Solución de Problemas Comunes  
**Audiencia:** Ingenieros de Soporte  
**Última actualización:** 5 de Noviembre 2025  

---

## 🎯 Uso de Este Documento

Busca tu problema en el índice y sigue la solución propuesta.

---

## 📑 Índice de Problemas

1. [Ollama no inicia](#problema-1-ollama-no-inicia)
2. [Modelo no aparece](#problema-2-modelo-no-aparece)
3. [OpenWebUI no accesible](#problema-3-openwebui-no-accesible)
4. [Knowledge Base no se usa (RAG no funciona)](#problema-4-knowledge-base-no-se-usa)
5. [Respuestas muy lentas](#problema-5-respuestas-muy-lentas)
6. [Errores de memoria (OOM)](#problema-6-errores-de-memoria-oom)
7. [Respuestas en inglés](#problema-7-respuestas-en-inglés)
8. [Formato profesional no aparece](#problema-8-formato-profesional-no-aparece)
9. [Sistema no sobrevive reinicio](#problema-9-sistema-no-sobrevive-reinicio)
10. [Nginx no conecta](#problema-10-nginx-no-conecta)

---

## Problema 1: Ollama No Inicia

### Síntomas
```
systemctl status ollama
● ollama.service - Ollama Service
   Loaded: loaded
   Active: failed
```

### Diagnóstico
```bash
# Ver logs
journalctl -u ollama -n 100

# Errores comunes:
# - "bind: address already in use" → Puerto ocupado
# - "permission denied" → Permisos incorrectos
# - "out of memory" → RAM insuficiente
```

### Soluciones

**Solución 1: Puerto Ocupado**
```bash
# Ver qué usa el puerto 11434
lsof -i :11434

# Matar proceso
kill -9 [PID]

# Reiniciar Ollama
systemctl restart ollama
```

**Solución 2: Permisos**
```bash
# Verificar ownership
ls -la /usr/local/bin/ollama

# Reinstalar Ollama
curl -fsSL https://ollama.ai/install.sh | sh
```

**Solución 3: Memoria Insuficiente**
```bash
# Ver RAM disponible
free -h

# Si <20GB libres, liberar memoria:
sync
echo 3 > /proc/sys/vm/drop_caches
```

---

## Problema 2: Modelo No Aparece

### Síntomas
```bash
ollama list
# aztecai no aparece en la lista
```

### Diagnóstico
```bash
# Ver si modelo base existe
ollama list | grep "gpt-oss"

# Ver ubicación de modelos
ls -lh ~/.ollama/models/
# o
ls -lh /usr/share/ollama/.ollama/models/
```

### Soluciones

**Solución 1: Recrear Modelo**
```bash
cd /opt/AztecAI_Model/02_Modelfiles

# Verificar Modelfile existe
ls -lh Modelfile.AztecAI.Professional

# Recrear
ollama create aztecai -f Modelfile.AztecAI.Professional

# Verificar
ollama list | grep aztecai
```

**Solución 2: Modelo Base Faltante**
```bash
# Descargar modelo base
ollama pull gpt-oss:20b

# Esperar 30-60 minutos

# Luego recrear aztecai
ollama create aztecai -f Modelfile.AztecAI.Professional
```

---

## Problema 3: OpenWebUI No Accesible

### Síntomas
```
http://server:3000 → Connection refused
```

### Diagnóstico
```bash
# Ver contenedor
docker ps -a | grep open-webui

# Ver logs
docker logs open-webui --tail 50

# Ver puertos
ss -tulpn | grep 3000
```

### Soluciones

**Solución 1: Contenedor Detenido**
```bash
# Iniciar contenedor
docker start open-webui

# Verificar
docker ps | grep open-webui
```

**Solución 2: Puerto Ocupado**
```bash
# Ver qué usa puerto 3000
lsof -i :3000

# Detener conflicto o cambiar puerto de OpenWebUI
docker stop open-webui
docker rm open-webui

# Recrear en puerto diferente
docker run -d --name open-webui -p 3001:8080 \
    -v open-webui:/app/backend/data \
    --add-host=host.docker.internal:host-gateway \
    ghcr.io/open-webui/open-webui:main
```

**Solución 3: Reinstalar OpenWebUI**
```bash
# Backup de datos
docker cp open-webui:/app/backend/data ./backup_openwebui

# Remover contenedor
docker stop open-webui
docker rm open-webui

# Recrear
docker run -d --name open-webui --restart always \
    -p 3000:8080 \
    -v open-webui:/app/backend/data \
    --add-host=host.docker.internal:host-gateway \
    ghcr.io/open-webui/open-webui:main
```

---

## Problema 4: Knowledge Base No Se Usa

### Síntomas
- Pregunta: "¿Qué canales tiene TV Azteca?"
- Respuesta: No menciona los 4 canales o información incorrecta
- No cita fuentes

### Diagnóstico
```
1. ¿Knowledge Base importada en OpenWebUI?
   → Workspace → Documents → Verificar

2. ¿RAG activado?
   → Settings → RAG → Toggle ON

3. ¿Collection creada?
   → Settings → RAG → Collections → "AztecAI"

4. ¿Conversación nueva?
   → RAG solo funciona en conversaciones nuevas
```

### Soluciones

**Solución 1: Reimportar Knowledge Base**
```
1. OpenWebUI → Workspace → Documents
2. Delete documento existente (si hay)
3. Upload nuevo:
   /opt/AztecAI_Model/03_Knowledge_Base/AztecAI_Complete_Knowledge_Base.md
4. Esperar procesamiento (2-5 minutos)
```

**Solución 2: Reconfigurar RAG**
```
1. Settings → RAG
2. RAG: ON
3. Collections → Delete "AztecAI" (si existe)
4. Create Collection → Nombre: "AztecAI"
5. Select documents → AztecAI_Complete_Knowledge_Base.md
6. Top-K: 5
7. Save
8. IMPORTANTE: Nueva conversación
```

**Solución 3: Verificar con Query Directa**
```bash
# Terminal
ollama run aztecai "¿Qué canales tiene TV Azteca?"

# Si funciona en terminal pero no en OpenWebUI:
# → Problema es de OpenWebUI RAG, no del modelo
```

---

## Problema 5: Respuestas Muy Lentas

### Síntomas
- Respuestas toman >30 segundos
- Timeout frecuentes

### Diagnóstico
```bash
# Ver uso de recursos
htop

# CPU al 100%?
# RAM full?
# Swap usage?

# Ver qué proceso consume
top -o %CPU
top -o %MEM

# Ver performance del modelo
time ollama run aztecai "Di OK"
```

### Soluciones

**Solución 1: Reducir Context Window**
```bash
# Editar Modelfile
cd /opt/AztecAI_Model/02_Modelfiles
vim Modelfile.AztecAI.Professional

# Cambiar:
PARAMETER num_ctx 8192
# Por:
PARAMETER num_ctx 4096

# Recrear modelo
ollama create aztecai -f Modelfile.AztecAI.Professional
```

**Solución 2: Liberar RAM**
```bash
# Ver RAM
free -h

# Limpiar cache
sync
echo 3 > /proc/sys/vm/drop_caches

# Reiniciar Ollama
systemctl restart ollama
```

**Solución 3: Reducir Top-K**
```
OpenWebUI → Settings → RAG
Top-K: 5 → Cambiar a 3
Save
```

**Solución 4: Cerrar Modelos No Usados**
```bash
# Listar modelos cargados
ollama ps

# Si hay múltiples modelos, solo usar aztecai
```

---

## Problema 6: Errores de Memoria (OOM)

### Síntomas
```bash
journalctl -u ollama | grep "out of memory"
# o
dmesg | grep "Out of memory"
```

### Diagnóstico
```bash
# RAM total
free -h

# Modelo requiere ~40GB
# Sistema necesita ~4GB
# OpenWebUI necesita ~2GB
# Mínimo: 50GB total

# Ver si hay swap
swapon -s
```

### Soluciones

**Solución 1: Añadir Swap (Temporal)**
```bash
# Crear 32GB swap
fallocate -l 32G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Permanente
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

**Solución 2: Usar Modelo Más Pequeño**
```bash
# Alternativa con menos RAM
# En lugar de gpt-oss:20b, usar:
ollama pull gpt-oss:13b  # Solo 26GB RAM

# Editar Modelfile
FROM gpt-oss:13b

# Recrear
ollama create aztecai -f Modelfile
```

**Solución 3: Upgrade de Servidor**
```
RAM actual < 32GB → No viable para producción
Necesario: 64GB+ RAM
```

---

## Problema 7: Respuestas en Inglés

### Síntomas
- Modelo responde en inglés a preguntas en español

### Diagnóstico
```bash
# Probar directamente
ollama run aztecai "Hola"

# ¿Responde en español?
# SI → Problema en OpenWebUI
# NO → Problema en Modelfile
```

### Soluciones

**Solución 1: Verificar System Prompt**
```bash
cd /opt/AztecAI_Model/02_Modelfiles
grep -i "español" Modelfile.AztecAI.Professional

# Debe contener instrucciones de idioma
```

**Solución 2: Recrear Modelo**
```bash
# Usar Modelfile original del paquete
cd /opt/AztecAI_Model/02_Modelfiles
ollama create aztecai -f Modelfile.AztecAI.Professional

# Probar
ollama run aztecai "¿Hablas español?"
```

**Solución 3: Nueva Conversación**
```
OpenWebUI → Nueva conversación
(Conversaciones antiguas pueden tener contexto en inglés)
```

---

## Problema 8: Formato Profesional No Aparece

### Síntomas
- Respuestas sin estructura "Pirámide Invertida"
- Sin iconos (⚡📊🎯📎)
- Sin separadores (━━━)

### Diagnóstico
```bash
# Probar en terminal
ollama run aztecai "¿Qué canales tiene TV Azteca?"

# ¿Tiene formato?
# SI → Problema de OpenWebUI rendering
# NO → Problema de Modelfile
```

### Soluciones

**Solución 1: Verificar Modelfile Correcto**
```bash
cd /opt/AztecAI_Model/02_Modelfiles

# Ver si es el Professional
head -n 20 Modelfile.AztecAI.Professional

# Debe decir:
# "Formato Profesional Distintivo"
# "Pirámide Invertida"

# Recrear
ollama create aztecai -f Modelfile.AztecAI.Professional
```

**Solución 2: Nueva Conversación**
```
OpenWebUI → Nueva conversación
Importante: Nueva, no continuar existente
```

---

## Problema 9: Sistema No Sobrevive Reinicio

### Síntomas
```bash
sudo reboot
# Después de reinicio:
# - Ollama no corre
# - OpenWebUI no corre
```

### Diagnóstico
```bash
# Verificar auto-start
systemctl is-enabled ollama
docker inspect open-webui | grep -i restart
```

### Soluciones

**Solución 1: Habilitar Ollama Auto-Start**
```bash
systemctl enable ollama
systemctl start ollama
```

**Solución 2: OpenWebUI Restart Policy**
```bash
# Recrear con --restart always
docker stop open-webui
docker rm open-webui

docker run -d --name open-webui \
    --restart always \
    -p 3000:8080 \
    -v open-webui:/app/backend/data \
    --add-host=host.docker.internal:host-gateway \
    ghcr.io/open-webui/open-webui:main
```

**Solución 3: Verificar Docker Auto-Start**
```bash
systemctl enable docker
systemctl start docker
```

---

## Problema 10: Nginx No Conecta

### Síntomas
```
https://domain.com → 502 Bad Gateway
```

### Diagnóstico
```bash
# Verificar Nginx
systemctl status nginx

# Verificar config
nginx -t

# Ver logs
tail -f /var/log/nginx/error.log
```

### Soluciones

**Solución 1: OpenWebUI No Corre**
```bash
# Verificar OpenWebUI primero
docker ps | grep open-webui

# Si no corre, iniciar
docker start open-webui

# Reiniciar Nginx
systemctl restart nginx
```

**Solución 2: Config Incorrecta**
```bash
# Verificar proxy_pass
cat /etc/nginx/sites-enabled/aztecai

# Debe tener:
proxy_pass http://localhost:3000;

# Test config
nginx -t

# Si OK, recargar
systemctl reload nginx
```

**Solución 3: SSL**
```bash
# Renovar certificado
certbot renew

# Reiniciar Nginx
systemctl restart nginx
```

---

## 🆘 Comandos de Diagnóstico Rápido

```bash
# Check completo
echo "=== OLLAMA ==="
systemctl status ollama
ollama list

echo "=== OPENWEBUI ==="
docker ps | grep open-webui

echo "=== PUERTOS ==="
ss -tulpn | grep -E "3000|11434"

echo "=== RECURSOS ==="
free -h
df -h /

echo "=== LOGS ==="
journalctl -u ollama -n 10 --no-pager
docker logs open-webui --tail 10
```

---

## 📞 Escalar Problema

Si ninguna solución funciona:

1. **Ejecutar script de verificación:**
```bash
cd /opt/AztecAI_Model/04_Scripts
./verify_installation.sh --verbose > diagnostico.txt
```

2. **Recopilar información:**
```bash
# Crear reporte
{
    echo "=== SISTEMA ==="
    uname -a
    free -h
    df -h
    
    echo "=== OLLAMA ==="
    systemctl status ollama
    ollama list
    journalctl -u ollama -n 100 --no-pager
    
    echo "=== OPENWEBUI ==="
    docker ps -a
    docker logs open-webui --tail 100
    
} > reporte_completo.txt
```

3. **Contactar Soporte:**
- Enviar `diagnostico.txt` y `reporte_completo.txt`
- Incluir descripción del problema
- Pasos para reproducir

---

**Documento creado:** 5 de Noviembre 2025  
**Versión:** 1.0  
**Mantenido por:** IAA - Héctor Romero Pico  

---

*"Cada problema tiene solución."* 🔧  
*AztecAI - Troubleshooting* 🇲🇽

