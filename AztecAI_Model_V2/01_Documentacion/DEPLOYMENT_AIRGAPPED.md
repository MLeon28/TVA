# Guía de Deployment para Ambientes Air-Gapped - AztecAI

**Versión:** 1.0.0  
**Fecha:** Enero 2025  
**Owner:** Inteligencia Artificial Azteca (IAA)  

---

## 📋 Resumen Ejecutivo

Esta guía proporciona instrucciones paso a paso para deployar AztecAI en servidores **completamente aislados** (air-gapped) sin acceso a internet.

---

## 🎯 Definición de Air-Gapped

### Niveles de Aislamiento

| Nivel | Descripción | Método de Deployment |
|-------|-------------|---------------------|
| **Nivel 1: Restringido** | Internet limitado, SSH disponible | Git interno + SCP |
| **Nivel 2: Aislado** | Sin internet, red interna, SSH disponible | SCP/rsync desde bastion |
| **Nivel 3: Air-Gapped Total** | Sin red externa, solo red interna | Git bundles + SCP |
| **Nivel 4: Físicamente Aislado** | Sin red alguna | USB/Media física |

Esta guía cubre **Niveles 2-4**.

---

## 📦 Componentes a Transferir

### Inventario Completo

| Componente | Tamaño | Método de Transferencia |
|------------|--------|------------------------|
| **Código AztecAI** | ~1 MB | Git bundle o tar.gz |
| **Modelo Ollama** | ~20 GB | SCP/rsync o USB |
| **Binario Ollama** | ~50 MB | SCP o USB |
| **OpenWebUI Image** | ~500 MB | Docker save + SCP |
| **Dependencias Python** | ~100 MB | pip download + tar |
| **Certificados SSL** | < 1 MB | Transferencia segura |
| **Documentación** | ~1 MB | Incluido en código |

**Total:** ~21-22 GB

---

## 🚀 Método 1: Git Bundle + SCP (Nivel 2-3)

### Descripción
Crear un "bundle" de Git que contiene todo el repositorio, transferirlo vía SCP, y clonar desde el bundle.

### Ventajas
- ✅ Mantiene historial de Git completo
- ✅ Permite versionado en servidor
- ✅ Transferencia eficiente

### Paso a Paso

#### En Workstation (con internet)

```bash
# ============================================
# PASO 1: Preparar Repositorio
# ============================================

cd /path/to/AztecAI_Model

# Inicializar Git si no existe
git init
git add .
git commit -m "AztecAI v1.0.0 - Production ready"

# ============================================
# PASO 2: Crear Git Bundle
# ============================================

# Bundle completo (incluye todo el historial)
git bundle create aztecai-v1.0.0.bundle --all

# Verificar bundle
git bundle verify aztecai-v1.0.0.bundle

# ============================================
# PASO 3: Descargar Modelo Ollama
# ============================================

# Opción A: Desde Ollama (si tienes el modelo)
# Ubicación típica: ~/.ollama/models/
cp -r ~/.ollama/models/gpt-oss:20b ./ollama_model/

# Opción B: Descargar explícitamente
ollama pull gpt-oss:20b
# Luego copiar desde ~/.ollama/models/

# ============================================
# PASO 4: Descargar Binario de Ollama
# ============================================

# Linux x86_64
curl -L https://ollama.com/download/ollama-linux-amd64 -o ollama-linux-amd64
chmod +x ollama-linux-amd64

# ============================================
# PASO 5: Descargar OpenWebUI Docker Image
# ============================================

# Pull image
docker pull ghcr.io/open-webui/open-webui:main

# Save to tar
docker save ghcr.io/open-webui/open-webui:main -o openwebui-main.tar

# Comprimir (opcional pero recomendado)
gzip openwebui-main.tar

# ============================================
# PASO 6: Descargar Dependencias Python
# ============================================

# Crear requirements.txt si no existe
cat > requirements.txt << 'EOF'
requests>=2.31.0
pyyaml>=6.0
markdown>=3.4.0
EOF

# Descargar todas las dependencias
pip download -r requirements.txt -d python_packages/

# ============================================
# PASO 7: Crear Paquete de Transferencia
# ============================================

# Crear directorio de transferencia
mkdir -p aztecai_transfer_package

# Copiar componentes
cp aztecai-v1.0.0.bundle aztecai_transfer_package/
cp -r ollama_model aztecai_transfer_package/
cp ollama-linux-amd64 aztecai_transfer_package/
cp openwebui-main.tar.gz aztecai_transfer_package/
cp -r python_packages aztecai_transfer_package/

# Crear script de instalación
cat > aztecai_transfer_package/install_airgapped.sh << 'EOFSCRIPT'
#!/bin/bash
# Script de instalación para ambiente air-gapped
# Versión: 1.0.0

set -e

echo "==================================="
echo "AztecAI Air-Gapped Installation"
echo "==================================="

# Verificar que estamos en el directorio correcto
if [ ! -f "aztecai-v1.0.0.bundle" ]; then
    echo "Error: Bundle no encontrado"
    exit 1
fi

# 1. Clonar desde bundle
echo "1. Clonando repositorio desde bundle..."
git clone aztecai-v1.0.0.bundle aztecai
cd aztecai

# 2. Instalar Ollama
echo "2. Instalando Ollama..."
sudo cp ../ollama-linux-amd64 /usr/local/bin/ollama
sudo chmod +x /usr/local/bin/ollama

# 3. Copiar modelo
echo "3. Instalando modelo Ollama..."
sudo mkdir -p /usr/share/ollama/.ollama/models
sudo cp -r ../ollama_model/* /usr/share/ollama/.ollama/models/

# 4. Cargar OpenWebUI image
echo "4. Cargando OpenWebUI Docker image..."
docker load -i ../openwebui-main.tar.gz

# 5. Instalar dependencias Python
echo "5. Instalando dependencias Python..."
pip install --no-index --find-links=../python_packages -r requirements.txt

# 6. Ejecutar deployment
echo "6. Ejecutando deployment..."
cd 04_Scripts
sudo ./deploy_production.sh

echo "==================================="
echo "Instalación completada!"
echo "==================================="
EOFSCRIPT

chmod +x aztecai_transfer_package/install_airgapped.sh

# Crear checksums para validación
cd aztecai_transfer_package
sha256sum * > checksums.sha256
cd ..

# Crear archivo comprimido
tar -czf aztecai_transfer_package.tar.gz aztecai_transfer_package/

# Mostrar tamaño
du -sh aztecai_transfer_package.tar.gz

echo "==================================="
echo "Paquete listo para transferencia:"
echo "aztecai_transfer_package.tar.gz"
echo "==================================="
```

#### Transferencia al Servidor

```bash
# ============================================
# OPCIÓN A: SCP (si SSH disponible)
# ============================================

scp aztecai_transfer_package.tar.gz user@server:/tmp/

# ============================================
# OPCIÓN B: USB/Media Física
# ============================================

# Copiar a USB
cp aztecai_transfer_package.tar.gz /media/usb/

# En servidor, copiar desde USB
cp /media/usb/aztecai_transfer_package.tar.gz /tmp/
```

#### En Servidor de Producción (air-gapped)

```bash
# ============================================
# PASO 1: Extraer Paquete
# ============================================

cd /tmp
tar -xzf aztecai_transfer_package.tar.gz
cd aztecai_transfer_package

# ============================================
# PASO 2: Validar Integridad
# ============================================

sha256sum -c checksums.sha256

# Si todo OK, continuar

# ============================================
# PASO 3: Ejecutar Instalación
# ============================================

sudo ./install_airgapped.sh

# ============================================
# PASO 4: Verificar Instalación
# ============================================

cd /opt/aztecai/04_Scripts
./verify_installation.sh

# ============================================
# PASO 5: Configurar Variables de Entorno
# ============================================

cd /opt/aztecai/05_Configuracion
cp environment_variables.env.example .env
nano .env  # Editar con valores específicos del servidor

# ============================================
# PASO 6: Iniciar Servicios
# ============================================

sudo systemctl start ollama
sudo systemctl start openwebui

# Verificar
sudo systemctl status ollama
sudo systemctl status openwebui

# ============================================
# PASO 7: Prueba Final
# ============================================

# Acceder a OpenWebUI
curl http://localhost:3000

# Probar modelo
ollama run aztecai "¿Qué canales tiene TV Azteca?"
```

---

## 🚀 Método 2: Tar.gz Completo (Nivel 3-4)

### Descripción
Empaquetar todo en un archivo tar.gz sin usar Git.

### Ventajas
- ✅ Máxima simplicidad
- ✅ No requiere Git en servidor
- ✅ Un solo archivo

### Desventajas
- ❌ Sin historial de versiones
- ❌ Sin capacidad de merge/diff

### Paso a Paso

#### En Workstation

```bash
# ============================================
# PASO 1: Preparar Directorio
# ============================================

cd /path/to/AztecAI_Model

# Limpiar archivos innecesarios
rm -rf __pycache__ *.log .DS_Store

# ============================================
# PASO 2: Crear Paquete Completo
# ============================================

cd ..
tar -czf aztecai-v1.0.0-complete.tar.gz \
    --exclude='*.log' \
    --exclude='__pycache__' \
    --exclude='.git' \
    AztecAI_Model/

# ============================================
# PASO 3: Agregar Componentes Externos
# ============================================

mkdir aztecai_complete_package
mv aztecai-v1.0.0-complete.tar.gz aztecai_complete_package/

# Copiar Ollama y OpenWebUI (como en Método 1)
cp ollama-linux-amd64 aztecai_complete_package/
cp openwebui-main.tar.gz aztecai_complete_package/
cp -r ollama_model aztecai_complete_package/

# Crear script de instalación simple
cat > aztecai_complete_package/install.sh << 'EOF'
#!/bin/bash
set -e

echo "Instalando AztecAI..."

# Extraer código
tar -xzf aztecai-v1.0.0-complete.tar.gz -C /opt/
mv /opt/AztecAI_Model /opt/aztecai

# Instalar Ollama
sudo cp ollama-linux-amd64 /usr/local/bin/ollama
sudo chmod +x /usr/local/bin/ollama

# Copiar modelo
sudo mkdir -p /usr/share/ollama/.ollama/models
sudo cp -r ollama_model/* /usr/share/ollama/.ollama/models/

# Cargar OpenWebUI
docker load -i openwebui-main.tar.gz

# Ejecutar deployment
cd /opt/aztecai/04_Scripts
sudo ./deploy_production.sh

echo "Instalación completada!"
EOF

chmod +x aztecai_complete_package/install.sh

# Empaquetar todo
tar -czf aztecai-complete-package-v1.0.0.tar.gz aztecai_complete_package/
```

#### En Servidor

```bash
# Extraer y ejecutar
tar -xzf aztecai-complete-package-v1.0.0.tar.gz
cd aztecai_complete_package
sudo ./install.sh
```

---

## 🚀 Método 3: USB/Media Física (Nivel 4)

### Para Servidores Físicamente Aislados

#### Preparación

```bash
# 1. Formatear USB (32GB+ recomendado)
sudo mkfs.ext4 /dev/sdb1

# 2. Montar
sudo mount /dev/sdb1 /mnt/usb

# 3. Copiar paquete
cp aztecai-complete-package-v1.0.0.tar.gz /mnt/usb/

# 4. Crear README
cat > /mnt/usb/README.txt << 'EOF'
AztecAI Deployment Package v1.0.0

Contenido:
- aztecai-complete-package-v1.0.0.tar.gz (21 GB)

Instalación:
1. Copiar archivo a /tmp en servidor
2. Extraer: tar -xzf aztecai-complete-package-v1.0.0.tar.gz
3. Ejecutar: cd aztecai_complete_package && sudo ./install.sh

Contacto: IAA - Inteligencia Artificial Azteca
EOF

# 5. Desmontar
sudo umount /mnt/usb
```

#### En Servidor

```bash
# 1. Montar USB
sudo mount /dev/sdb1 /mnt/usb

# 2. Copiar a disco local
cp /mnt/usb/aztecai-complete-package-v1.0.0.tar.gz /tmp/

# 3. Desmontar USB (seguridad)
sudo umount /mnt/usb

# 4. Instalar
cd /tmp
tar -xzf aztecai-complete-package-v1.0.0.tar.gz
cd aztecai_complete_package
sudo ./install.sh
```

---

## 🔄 Updates en Ambiente Air-Gapped

### Update de Código (sin cambio de modelo)

```bash
# En workstation
cd /path/to/AztecAI_Model
git add .
git commit -m "Update v1.1.0"
git bundle create aztecai-v1.1.0-update.bundle main ^v1.0.0

# Transferir bundle

# En servidor
cd /opt/aztecai
git fetch /tmp/aztecai-v1.1.0-update.bundle main:main
git checkout main
./04_Scripts/deploy_production.sh
```

### Update de Modelo

```bash
# Transferir nuevo modelo
# En servidor
sudo systemctl stop ollama
sudo cp -r /tmp/new_model/* /usr/share/ollama/.ollama/models/
sudo systemctl start ollama

# Recrear modelo custom
cd /opt/aztecai/02_Modelfiles
ollama create aztecai -f Modelfile.AztecAI.Professional
```

---

## ✅ Checklist de Validación Post-Deployment

### Verificaciones Esenciales

```bash
# 1. Verificar Ollama
ollama list
# Debe mostrar: gpt-oss:20b y aztecai

# 2. Verificar OpenWebUI
curl http://localhost:3000
# Debe responder con HTML

# 3. Verificar modelo custom
ollama run aztecai "¿Quién eres?"
# Debe responder como AztecAI

# 4. Verificar Knowledge Base
# Acceder a OpenWebUI → Workspace → Documents
# Deben estar los 3 archivos de KB

# 5. Verificar RAG
# Hacer pregunta que requiera KB
# Ejemplo: "¿Qué canales tiene TV Azteca?"

# 6. Verificar servicios
sudo systemctl status ollama
sudo systemctl status openwebui

# 7. Verificar logs
sudo journalctl -u ollama -n 50
sudo journalctl -u openwebui -n 50
```

---

## 🐛 Troubleshooting Air-Gapped

### Problema 1: Docker image no carga

```bash
# Verificar archivo
file openwebui-main.tar.gz
# Debe ser: gzip compressed data

# Descomprimir y cargar
gunzip openwebui-main.tar.gz
docker load -i openwebui-main.tar

# Verificar
docker images | grep openwebui
```

### Problema 2: Modelo no se encuentra

```bash
# Verificar ubicación
ls -la /usr/share/ollama/.ollama/models/

# Verificar permisos
sudo chown -R ollama:ollama /usr/share/ollama/.ollama/

# Reiniciar Ollama
sudo systemctl restart ollama
```

### Problema 3: Dependencias Python faltantes

```bash
# Instalar desde paquetes locales
pip install --no-index --find-links=/tmp/python_packages -r requirements.txt

# Si falta alguna, descargar en workstation y transferir
```

---

## 📊 Comparación de Métodos Air-Gapped

| Método | Complejidad | Versionado | Tamaño | Recomendado Para |
|--------|-------------|------------|--------|------------------|
| Git Bundle + SCP | Media | ✅ Sí | ~21 GB | Nivel 2-3, updates frecuentes |
| Tar.gz Completo | Baja | ❌ No | ~21 GB | Nivel 3-4, deployment único |
| USB/Media | Baja | ❌ No | ~21 GB | Nivel 4, máximo aislamiento |

---

## 📚 Recursos Adicionales

- `DEPLOYMENT_METHODS_COMPARISON.md` - Comparación completa de métodos
- `REPOSITORY_STRUCTURE.md` - Qué incluir en el paquete
- `SECURITY_BEST_PRACTICES.md` - Seguridad en transferencias

---

**Última actualización:** Enero 2025  
**Próxima revisión:** Marzo 2025

