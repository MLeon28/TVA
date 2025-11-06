# Mejores Prácticas de Seguridad para Deployment - AztecAI

**Versión:** 1.0.0  
**Fecha:** Noviembre 2025  
**Owner:** Inteligencia Artificial Azteca (IAA)  
**Clasificación:** Corporativo - Uso Interno  

---

## 📋 Resumen Ejecutivo

Este documento establece las mejores prácticas de seguridad para el deployment de AztecAI en ambientes de producción corporativos.

---

## 🎯 Principios de Seguridad

### Defensa en Profundidad (Defense in Depth)

```
┌─────────────────────────────────────────────────────────┐
│                    CAPAS DE SEGURIDAD                    │
├─────────────────────────────────────────────────────────┤
│  1. Seguridad Física (Data Center, Access Control)      │
│  2. Seguridad de Red (Firewalls, VPN, Segmentation)     │
│  3. Seguridad de Host (OS Hardening, Patches)           │
│  4. Seguridad de Aplicación (Auth, Encryption)          │
│  5. Seguridad de Datos (Encryption at Rest/Transit)     │
│  6. Monitoreo y Auditoría (Logs, SIEM, Alerts)          │
└─────────────────────────────────────────────────────────┘
```

### Principio de Mínimo Privilegio

- ✅ Usuarios solo tienen permisos necesarios
- ✅ Servicios corren con usuarios no-privilegiados
- ✅ Acceso basado en roles (RBAC)

### Zero Trust

- ✅ Verificar siempre, nunca confiar implícitamente
- ✅ Autenticación multifactor (MFA)
- ✅ Segmentación de red

---

## 🔐 Seguridad en Transferencia de Archivos

### 1. Autenticación

#### SSH Keys (Recomendado)

```bash
# ============================================
# Generar par de keys SSH
# ============================================

# En workstation
ssh-keygen -t ed25519 -C "aztecai-deployment@tvazteca.com" -f ~/.ssh/aztecai_deploy

# Proteger key privada
chmod 600 ~/.ssh/aztecai_deploy

# Copiar key pública al servidor
ssh-copy-id -i ~/.ssh/aztecai_deploy.pub user@server

# Configurar SSH config
cat >> ~/.ssh/config << 'EOF'
Host aztecai-prod
    HostName 10.x.x.x
    User aztecai_deploy
    IdentityFile ~/.ssh/aztecai_deploy
    IdentitiesOnly yes
EOF

# Usar
scp -F ~/.ssh/config file.tar.gz aztecai-prod:/tmp/
```

#### ❌ Evitar Passwords

```bash
# MAL - No usar passwords en scripts
sshpass -p 'password123' scp file.tar.gz user@server:/tmp/

# BIEN - Usar SSH keys
scp -i ~/.ssh/aztecai_deploy file.tar.gz user@server:/tmp/
```

### 2. Encriptación en Tránsito

#### SCP/SFTP (Recomendado)

```bash
# SCP usa SSH encryption por defecto
scp -C file.tar.gz user@server:/tmp/
# -C: Compresión (reduce bandwidth)

# SFTP para transferencias interactivas
sftp user@server
put file.tar.gz /tmp/
```

#### rsync sobre SSH

```bash
# rsync con SSH encryption
rsync -avz -e "ssh -i ~/.ssh/aztecai_deploy" \
    file.tar.gz user@server:/tmp/

# Con progress y bandwidth limit
rsync -avz --progress --bwlimit=10000 \
    -e "ssh -i ~/.ssh/aztecai_deploy" \
    file.tar.gz user@server:/tmp/
```

#### ❌ Evitar Protocolos Inseguros

```bash
# MAL - FTP sin encriptación
ftp server
put file.tar.gz

# MAL - HTTP sin encriptación
curl -T file.tar.gz http://server/upload

# BIEN - SFTP o HTTPS
sftp user@server
curl -T file.tar.gz https://server/upload
```

### 3. Validación de Integridad

#### Checksums (Obligatorio)

```bash
# ============================================
# En workstation: Generar checksums
# ============================================

# SHA-256 (recomendado)
sha256sum aztecai_package.tar.gz > aztecai_package.sha256

# MD5 (legacy, menos seguro)
md5sum aztecai_package.tar.gz > aztecai_package.md5

# Para múltiples archivos
find . -type f -exec sha256sum {} \; > checksums.sha256

# ============================================
# En servidor: Validar checksums
# ============================================

# Validar SHA-256
sha256sum -c aztecai_package.sha256

# Si OK, continuar
# Si FAIL, NO usar el archivo (puede estar corrupto o comprometido)
```

#### Firmas Digitales (Máxima Seguridad)

```bash
# ============================================
# Generar par de keys GPG (una vez)
# ============================================

gpg --full-generate-key
# Seleccionar: RSA and RSA, 4096 bits

# ============================================
# Firmar archivo
# ============================================

gpg --armor --detach-sign aztecai_package.tar.gz
# Genera: aztecai_package.tar.gz.asc

# ============================================
# Verificar firma (en servidor)
# ============================================

# Importar public key (una vez)
gpg --import public_key.asc

# Verificar firma
gpg --verify aztecai_package.tar.gz.asc aztecai_package.tar.gz

# Si OK: "Good signature from..."
# Si FAIL: NO usar el archivo
```

---

## 🔒 Gestión de Secretos

### 1. NUNCA en Código o Git

#### ❌ Prácticas Inseguras

```bash
# MAL - Secretos en código
WEBUI_SECRET_KEY="my-secret-123"

# MAL - Secretos en Git
git add .env
git commit -m "Add config"

# MAL - Secretos en logs
echo "Password: $PASSWORD" >> install.log
```

#### ✅ Prácticas Seguras

```bash
# BIEN - Variables de entorno
export WEBUI_SECRET_KEY=$(cat /secure/secrets/webui_key)

# BIEN - Archivos de secretos con permisos restrictivos
echo "my-secret-123" > /etc/aztecai/webui_key
chmod 600 /etc/aztecai/webui_key
chown aztecai:aztecai /etc/aztecai/webui_key

# BIEN - Secrets manager
vault kv get -field=webui_key secret/aztecai
```

### 2. Secrets Managers (Recomendado)

#### HashiCorp Vault

```bash
# ============================================
# Setup (una vez)
# ============================================

# Instalar Vault
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vault

# Inicializar
vault operator init

# ============================================
# Almacenar secretos
# ============================================

vault kv put secret/aztecai \
    webui_secret_key="..." \
    ldap_password="..." \
    ssl_cert_password="..."

# ============================================
# Recuperar en deployment
# ============================================

export WEBUI_SECRET_KEY=$(vault kv get -field=webui_secret_key secret/aztecai)
```

#### Ansible Vault

```bash
# ============================================
# Encriptar archivo de secretos
# ============================================

ansible-vault create secrets.yml
# Ingresar password
# Editar archivo con secretos

# ============================================
# Usar en playbook
# ============================================

ansible-playbook deploy.yml --ask-vault-pass

# ============================================
# Encriptar string individual
# ============================================

ansible-vault encrypt_string 'my_secret_password' --name 'ldap_password'
```

### 3. Rotación de Secretos

```bash
# ============================================
# Política de Rotación
# ============================================

# Passwords: Cada 90 días
# API Keys: Cada 180 días
# Certificates: Antes de expiración (típicamente 1 año)
# SSH Keys: Cada 1 año o al cambio de personal

# ============================================
# Script de rotación (ejemplo)
# ============================================

#!/bin/bash
# rotate_secrets.sh

# Generar nuevo secret
NEW_SECRET=$(openssl rand -base64 32)

# Actualizar en Vault
vault kv put secret/aztecai webui_secret_key="$NEW_SECRET"

# Actualizar en servidor
ssh server "echo '$NEW_SECRET' > /etc/aztecai/webui_key"

# Reiniciar servicio
ssh server "sudo systemctl restart openwebui"

# Log de rotación
echo "$(date): Secret rotated" >> /var/log/secret_rotation.log
```

---

## 🛡️ Hardening del Servidor

### 1. Sistema Operativo

```bash
# ============================================
# Updates y Patches
# ============================================

# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Habilitar updates automáticos de seguridad
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# ============================================
# Firewall
# ============================================

# UFW (Ubuntu)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable

# iptables (alternativa)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -j DROP

# ============================================
# SSH Hardening
# ============================================

sudo nano /etc/ssh/sshd_config

# Cambios recomendados:
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2

sudo systemctl restart sshd

# ============================================
# Fail2Ban (protección contra brute force)
# ============================================

sudo apt install fail2ban

sudo cat > /etc/fail2ban/jail.local << 'EOF'
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF

sudo systemctl restart fail2ban
```

### 2. Usuarios y Permisos

```bash
# ============================================
# Crear usuario dedicado para AztecAI
# ============================================

sudo useradd -r -s /bin/bash -d /opt/aztecai -m aztecai

# ============================================
# Configurar permisos
# ============================================

# Código y configs
sudo chown -R aztecai:aztecai /opt/aztecai
sudo chmod 750 /opt/aztecai

# Scripts ejecutables
sudo chmod 750 /opt/aztecai/04_Scripts/*.sh

# Archivos de configuración
sudo chmod 640 /opt/aztecai/05_Configuracion/*.conf

# Secretos (solo lectura para owner)
sudo chmod 600 /etc/aztecai/secrets/*

# ============================================
# Sudoers (si necesario)
# ============================================

sudo visudo

# Agregar (solo comandos específicos):
aztecai ALL=(ALL) NOPASSWD: /bin/systemctl restart ollama
aztecai ALL=(ALL) NOPASSWD: /bin/systemctl restart openwebui
```

### 3. Servicios

```bash
# ============================================
# Configurar servicios para correr como usuario no-root
# ============================================

# Ollama service
sudo cat > /etc/systemd/system/ollama.service << 'EOF'
[Unit]
Description=Ollama Service
After=network.target

[Service]
Type=simple
User=aztecai
Group=aztecai
ExecStart=/usr/local/bin/ollama serve
Restart=always
RestartSec=10

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/aztecai /var/lib/ollama

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable ollama
```

---

## 🔍 Auditoría y Monitoreo

### 1. Logging

```bash
# ============================================
# Configurar logging centralizado
# ============================================

# rsyslog para enviar logs a servidor central
sudo nano /etc/rsyslog.d/50-aztecai.conf

# Agregar:
*.* @@log-server.internal:514

sudo systemctl restart rsyslog

# ============================================
# Logs de deployment
# ============================================

# Crear log de deployment
cat > /var/log/aztecai/deployment.log << 'EOF'
$(date): Deployment started by $USER
$(date): Version: v1.0.0
$(date): Source: Git bundle
$(date): Checksum validated: OK
$(date): Installation completed
EOF

# Permisos
sudo chmod 640 /var/log/aztecai/deployment.log
```

### 2. Monitoreo de Integridad

```bash
# ============================================
# AIDE (Advanced Intrusion Detection Environment)
# ============================================

# Instalar
sudo apt install aide

# Inicializar base de datos
sudo aideinit

# Verificar integridad
sudo aide --check

# Automatizar (cron)
echo "0 2 * * * root /usr/bin/aide --check" | sudo tee -a /etc/crontab
```

### 3. Auditoría de Accesos

```bash
# ============================================
# auditd para auditoría del sistema
# ============================================

sudo apt install auditd

# Reglas de auditoría
sudo auditctl -w /opt/aztecai -p wa -k aztecai_changes
sudo auditctl -w /etc/aztecai -p wa -k aztecai_config_changes

# Ver eventos
sudo ausearch -k aztecai_changes

# Persistir reglas
sudo nano /etc/audit/rules.d/aztecai.rules
```

---

## 🔐 Encriptación

### 1. Datos en Tránsito

```bash
# ============================================
# SSL/TLS para OpenWebUI
# ============================================

# Generar certificado (producción: usar CA corporativo)
sudo openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -keyout /etc/ssl/private/aztecai.key \
    -out /etc/ssl/certs/aztecai.crt

# Permisos
sudo chmod 600 /etc/ssl/private/aztecai.key
sudo chmod 644 /etc/ssl/certs/aztecai.crt

# Configurar Nginx
sudo nano /etc/nginx/sites-available/aztecai

# Agregar:
server {
    listen 443 ssl http2;
    server_name aztecai.tvazteca.com;
    
    ssl_certificate /etc/ssl/certs/aztecai.crt;
    ssl_certificate_key /etc/ssl/private/aztecai.key;
    
    # SSL hardening
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # HSTS
    add_header Strict-Transport-Security "max-age=31536000" always;
    
    location / {
        proxy_pass http://localhost:3000;
    }
}
```

### 2. Datos en Reposo

```bash
# ============================================
# Encriptar partición de datos
# ============================================

# LUKS encryption (setup inicial)
sudo cryptsetup luksFormat /dev/sdb1
sudo cryptsetup open /dev/sdb1 aztecai_data
sudo mkfs.ext4 /dev/mapper/aztecai_data
sudo mount /dev/mapper/aztecai_data /var/lib/aztecai

# ============================================
# Encriptar backups
# ============================================

# Backup encriptado con GPG
tar -czf - /opt/aztecai | gpg --encrypt --recipient admin@tvazteca.com > backup.tar.gz.gpg

# Restaurar
gpg --decrypt backup.tar.gz.gpg | tar -xzf -
```

---

## 📋 Checklist de Seguridad Pre-Deployment

### Infraestructura

- [ ] Firewall configurado (solo puertos necesarios)
- [ ] SSH hardening aplicado
- [ ] Fail2Ban instalado y configurado
- [ ] Sistema operativo actualizado
- [ ] Updates automáticos habilitados

### Autenticación y Autorización

- [ ] SSH keys configuradas (no passwords)
- [ ] Usuario dedicado creado (aztecai)
- [ ] Permisos de archivos configurados correctamente
- [ ] Sudoers configurado (mínimo privilegio)
- [ ] MFA habilitado para acceso administrativo

### Secretos

- [ ] Secrets manager configurado (Vault/Ansible Vault)
- [ ] No hay secretos en Git
- [ ] Archivos de secretos con permisos 600
- [ ] Templates (.example) creados para configs

### Encriptación

- [ ] SSL/TLS configurado para OpenWebUI
- [ ] Certificados válidos instalados
- [ ] Transferencias usan SCP/SFTP (no FTP)
- [ ] Backups encriptados

### Monitoreo y Auditoría

- [ ] Logging centralizado configurado
- [ ] auditd instalado y configurado
- [ ] AIDE o similar para integridad de archivos
- [ ] Alertas configuradas para eventos críticos

### Validación

- [ ] Checksums generados para todos los archivos
- [ ] Firmas digitales (opcional pero recomendado)
- [ ] Validación de integridad post-transferencia
- [ ] Tests de penetración realizados (opcional)

---

## 🚨 Respuesta a Incidentes

### Plan de Respuesta

```bash
# ============================================
# 1. Detección
# ============================================

# Monitorear logs
sudo tail -f /var/log/auth.log
sudo tail -f /var/log/aztecai/app.log

# Alertas automáticas
# Configurar con SIEM o herramienta de monitoreo

# ============================================
# 2. Contención
# ============================================

# Aislar servidor (si comprometido)
sudo ufw deny in
sudo systemctl stop ollama openwebui

# ============================================
# 3. Erradicación
# ============================================

# Identificar y eliminar amenaza
# Restaurar desde backup conocido bueno

# ============================================
# 4. Recuperación
# ============================================

# Restaurar desde backup
sudo ./04_Scripts/restore_backup.sh

# Validar integridad
sudo aide --check

# ============================================
# 5. Lecciones Aprendidas
# ============================================

# Documentar incidente
# Actualizar procedimientos
# Mejorar controles
```

---

## 📚 Recursos Adicionales

### Estándares y Frameworks

- **NIST Cybersecurity Framework**
- **CIS Benchmarks** (Center for Internet Security)
- **OWASP Top 10**
- **ISO 27001**

### Herramientas Recomendadas

- **Vault:** Secrets management
- **Fail2Ban:** Protección brute force
- **AIDE:** Detección de intrusiones
- **auditd:** Auditoría del sistema
- **Lynis:** Security auditing tool

### Comandos Útiles

```bash
# Security audit
sudo lynis audit system

# Check open ports
sudo netstat -tulpn

# Check running services
sudo systemctl list-units --type=service --state=running

# Check failed login attempts
sudo grep "Failed password" /var/log/auth.log

# Check sudo usage
sudo grep sudo /var/log/auth.log
```

---

**Última actualización:** Enero 2025  
**Próxima revisión:** Marzo 2025  
**Clasificación:** Corporativo - Uso Interno

