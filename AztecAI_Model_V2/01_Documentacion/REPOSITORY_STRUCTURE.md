# Estructura del Repositorio de Deployment - AztecAI

**Versión:** 1.0.0  
**Fecha:** Noviembre 2025  
**Owner:** Inteligencia Artificial Azteca (IAA)  

---

## 📋 Resumen Ejecutivo

Este documento define qué archivos deben incluirse en el repositorio Git para deployment de AztecAI, y cuáles deben gestionarse por separado.

---

## 🎯 Principios de Organización

### ✅ Incluir en Git Repository

**Criterios:**
- Archivos de texto (código, configs, docs)
- Tamaño < 100 MB
- Versionado necesario
- Sin información sensible
- Compartible entre ambientes

### ❌ Excluir de Git Repository

**Criterios:**
- Archivos binarios grandes (> 100 MB)
- Datos generados en runtime
- Información sensible (secretos, keys)
- Datos de usuarios
- Logs y temporales

---

## 📁 Estructura Recomendada del Repositorio

```
aztecai-deployment/
│
├── .gitignore                          ✅ Control de versiones
├── .gitlab-ci.yml                      ✅ CI/CD pipeline (opcional)
├── README.md                           ✅ Documentación principal
├── CHANGELOG.md                        ✅ Historial de cambios
├── LICENSE                             ✅ Licencia (si aplica)
│
├── 01_Documentacion/                   ✅ INCLUIR TODO
│   ├── 00_INICIO_AQUI.md
│   ├── REQUISITOS_TECNICOS.md
│   ├── GUIA_INSTALACION_SERVIDOR.md
│   ├── CHECKLIST_VERIFICACION.md
│   ├── ARQUITECTURA_TECNICA.md
│   ├── EJEMPLOS_USO.md
│   ├── TROUBLESHOOTING_PRODUCCION.md
│   ├── MEJORAS_RECOMENDADAS.md
│   ├── DEPLOYMENT_METHODS_COMPARISON.md
│   ├── DEPLOYMENT_AIRGAPPED.md
│   ├── REPOSITORY_STRUCTURE.md
│   └── SECURITY_BEST_PRACTICES.md
│
├── 02_Modelfiles/                      ✅ INCLUIR TODO
│   ├── Modelfile.AztecAI.Professional
│   ├── parametros_explicados.md
│   └── README.md
│
├── 03_Knowledge_Base/                  ✅ INCLUIR TODO (son pequeños)
│   ├── AztecAI_Complete_Knowledge_Base.md
│   ├── TV_Azteca_Informacion_Corporativa.md
│   ├── Funcionamiento TV Aztec.md
│   ├── README_KNOWLEDGE_BASE.md
│   ├── metadata.json
│   └── sections/                       ✅ INCLUIR
│       ├── 01_METADATA_Y_CONTROL_DE_VERSIONES.md
│       ├── 02_IDENTIDAD_CENTRAL_Y_MISIÓN.md
│       └── ... (todas las secciones)
│
├── 04_Scripts/                         ✅ INCLUIR TODO
│   ├── deploy_production.sh
│   ├── verify_installation.sh
│   ├── import_knowledge_base.sh
│   ├── import_knowledge_base.ps1
│   ├── prepare_knowledge_base.py
│   ├── backup_system.sh               (nuevo)
│   ├── rollback.sh                    (nuevo)
│   └── README.md
│
├── 05_Configuracion/                   ✅ INCLUIR (sin secretos)
│   ├── nginx.conf
│   ├── environment_variables.env.example  ✅ Template
│   ├── systemd/
│   │   ├── ollama.service
│   │   └── openwebui.service
│   └── README.md
│
├── 06_Tests/                           ✅ INCLUIR TODO
│   ├── test_installation.sh
│   ├── test_rag_quality.py
│   ├── test_model_response.py
│   ├── test_data/                      ✅ Datos de prueba pequeños
│   │   └── sample_questions.json
│   └── README.md
│
├── 07_CI_CD/                           ✅ INCLUIR (opcional)
│   ├── .gitlab-ci.yml
│   ├── Jenkinsfile
│   ├── ansible/
│   │   ├── playbook.yml
│   │   └── inventory.example
│   └── README.md
│
└── 08_Utilities/                       ✅ INCLUIR
    ├── health_check.sh
    ├── monitoring_setup.sh
    ├── log_analyzer.py
    └── README.md
```

---

## 📦 Archivos a INCLUIR en Git

### Categoría 1: Documentación (100% incluir)

| Archivo | Tamaño | Razón |
|---------|--------|-------|
| `*.md` | < 1 MB | Documentación esencial |
| `*.txt` | < 100 KB | Notas y referencias |
| `README.*` | < 100 KB | Guías de uso |

**Total estimado:** ~500 KB

### Categoría 2: Scripts (100% incluir)

| Archivo | Tamaño | Razón |
|---------|--------|-------|
| `*.sh` | < 50 KB | Scripts de deployment |
| `*.py` | < 100 KB | Scripts de Python |
| `*.ps1` | < 50 KB | Scripts de PowerShell |

**Total estimado:** ~200 KB

### Categoría 3: Configuraciones (incluir templates)

| Archivo | Incluir | Razón |
|---------|---------|-------|
| `nginx.conf` | ✅ | Config base sin secretos |
| `*.service` | ✅ | Systemd units |
| `environment_variables.env.example` | ✅ | Template sin secretos |
| `environment_variables.env` | ❌ | Contiene secretos |
| `*.conf` | ✅ | Configs generales |
| `*.yaml` | ✅ | Configs de aplicación |

**Total estimado:** ~50 KB

### Categoría 4: Knowledge Base (100% incluir)

| Archivo | Tamaño | Razón |
|---------|--------|-------|
| `*.md` (KB files) | ~97 KB | Archivos de texto pequeños |
| `metadata.json` | < 5 KB | Metadata del KB |
| `sections/*.md` | ~50 KB | Secciones del KB |

**Total estimado:** ~150 KB

### Categoría 5: Modelfiles (100% incluir)

| Archivo | Tamaño | Razón |
|---------|--------|-------|
| `Modelfile.*` | < 20 KB | Definición del modelo |
| `parametros_explicados.md` | < 30 KB | Documentación |

**Total estimado:** ~50 KB

### Categoría 6: Tests (incluir código, no datos grandes)

| Archivo | Incluir | Razón |
|---------|---------|-------|
| `test_*.py` | ✅ | Scripts de testing |
| `test_*.sh` | ✅ | Scripts de testing |
| `sample_questions.json` | ✅ | Datos de prueba pequeños |
| `test_results/` | ❌ | Resultados generados |

**Total estimado:** ~100 KB

---

## 🚫 Archivos a EXCLUIR de Git

### Categoría 1: Archivos Grandes (gestionar por separado)

| Archivo/Directorio | Tamaño | Método Alternativo |
|-------------------|--------|-------------------|
| Modelo Ollama (`gpt-oss:20b`) | ~20 GB | SCP/rsync o pre-instalado |
| `*.gguf` | > 1 GB | Artifact repository |
| `*.bin` | > 1 GB | Artifact repository |
| `models/` | > 10 GB | File server interno |

**Razón:** Git no está diseñado para archivos tan grandes. Usar Git LFS o transferencia separada.

### Categoría 2: Datos Generados en Runtime

| Archivo/Directorio | Razón |
|-------------------|-------|
| `embeddings/` | Se regeneran en servidor |
| `*.faiss` | Índices generados |
| `*.index` | Índices generados |
| `vector_store/` | Se crea en runtime |
| `data/` | Datos de OpenWebUI |
| `*.db`, `*.sqlite` | Bases de datos locales |
| `.ollama/` | Directorio de Ollama |

**Razón:** Se generan automáticamente durante la instalación.

### Categoría 3: Información Sensible

| Archivo | Razón |
|---------|-------|
| `.env` | Contiene secretos |
| `*.key` | Claves privadas |
| `*.pem` | Certificados privados |
| `*.crt` | Certificados SSL |
| `credentials.json` | Credenciales |
| `id_rsa*` | SSH keys |
| `ssl/` | Certificados SSL |

**Razón:** Seguridad. Gestionar con Vault, secrets manager, o transferencia manual segura.

### Categoría 4: Logs y Temporales

| Archivo/Directorio | Razón |
|-------------------|-------|
| `*.log` | Logs de ejecución |
| `logs/` | Directorio de logs |
| `*.tmp` | Archivos temporales |
| `*.bak` | Backups |
| `__pycache__/` | Cache de Python |
| `.pytest_cache/` | Cache de tests |

**Razón:** Generados en runtime, no necesarios para deployment.

### Categoría 5: Datos de Usuarios

| Archivo/Directorio | Razón |
|-------------------|-------|
| `user_data/` | Datos de usuarios |
| `conversations/` | Historial de chats |
| `chat_history/` | Conversaciones |
| `backups/*.sql` | Backups de BD |
| `metrics/` | Métricas de uso |

**Razón:** Privacidad y seguridad. NUNCA versionar datos de usuarios.

### Categoría 6: Archivos de Sistema

| Archivo | Razón |
|---------|-------|
| `.DS_Store` | macOS |
| `Thumbs.db` | Windows |
| `.vscode/` | IDE settings |
| `.idea/` | IDE settings |
| `*.swp` | Vim temporales |

**Razón:** Específicos de sistema/IDE, no necesarios para deployment.

---

## 📊 Resumen de Tamaños

| Categoría | Tamaño Estimado | Incluir en Git |
|-----------|-----------------|----------------|
| Documentación | ~500 KB | ✅ Sí |
| Scripts | ~200 KB | ✅ Sí |
| Configuraciones | ~50 KB | ✅ Sí (templates) |
| Knowledge Base | ~150 KB | ✅ Sí |
| Modelfiles | ~50 KB | ✅ Sí |
| Tests | ~100 KB | ✅ Sí |
| **TOTAL EN GIT** | **~1 MB** | ✅ |
| | | |
| Modelo Ollama | ~20 GB | ❌ No (separado) |
| Embeddings | ~500 MB | ❌ No (generado) |
| Datos runtime | Variable | ❌ No (generado) |

---

## 🔧 Gestión de Archivos Grandes

### Opción 1: Pre-instalación en Servidores (Recomendado)

```bash
# En cada servidor de producción, instalar Ollama y modelo una vez
curl -fsSL https://ollama.com/install.sh | sh
ollama pull gpt-oss:20b

# Luego, solo deployar código vía Git
git clone <repo>
cd aztecai-deployment
./04_Scripts/deploy_production.sh
```

**Ventajas:**
- Modelo ya está en servidor
- Git repository pequeño y rápido
- No hay transferencia de 20 GB

### Opción 2: Transferencia Separada vía SCP/rsync

```bash
# Una vez: transferir modelo
rsync -avz --progress /local/ollama/models/ user@server:/opt/ollama/models/

# Deployments subsecuentes: solo código
git pull
./04_Scripts/deploy_production.sh
```

**Ventajas:**
- Transferencia eficiente (rsync solo envía cambios)
- Modelo versionado manualmente

### Opción 3: Git LFS (Large File Storage)

```bash
# Configurar Git LFS
git lfs install
git lfs track "*.gguf"
git lfs track "models/*"

# Commit y push
git add .gitattributes
git commit -m "Track large files with LFS"
git push
```

**Ventajas:**
- Todo en Git (conceptualmente)
- Versionado de archivos grandes

**Desventajas:**
- Requiere Git LFS server
- Clones iniciales siguen siendo lentos
- Costos de storage (GitHub LFS: $5/50GB/mes)

### Opción 4: Artifact Repository (Nexus/Artifactory)

```bash
# Subir modelo a Nexus
curl -u user:pass --upload-file gpt-oss-20b.gguf \
  http://nexus.internal/repository/ai-models/

# En servidor, descargar
curl -u user:pass -O \
  http://nexus.internal/repository/ai-models/gpt-oss-20b.gguf
```

**Ventajas:**
- Diseñado para artifacts grandes
- Versionado y checksums
- Control de acceso granular

---

## 🔐 Gestión de Secretos

### ❌ NUNCA en Git

```bash
# MAL - NO HACER ESTO
git add .env
git add ssl/private.key
git add credentials.json
```

### ✅ Usar Templates

```bash
# Incluir template en Git
cat > 05_Configuracion/environment_variables.env.example << 'EOF'
# Variables de Entorno para AztecAI
OLLAMA_HOST=0.0.0.0:11434
WEBUI_SECRET_KEY=CHANGE_ME_IN_PRODUCTION
LDAP_BIND_PASSWORD=CHANGE_ME
EOF

# En servidor, copiar y editar
cp environment_variables.env.example .env
nano .env  # Editar con valores reales
```

### ✅ Usar Secrets Manager

```bash
# Opción 1: HashiCorp Vault
vault kv put secret/aztecai \
  webui_secret_key="..." \
  ldap_password="..."

# En deployment script
export WEBUI_SECRET_KEY=$(vault kv get -field=webui_secret_key secret/aztecai)
```

```bash
# Opción 2: Ansible Vault
ansible-vault encrypt_string 'my_secret_password' --name 'ldap_password'

# En playbook
- name: Deploy AztecAI
  vars:
    ldap_password: !vault |
      $ANSIBLE_VAULT;1.1;AES256
      ...
```

---

## 📋 Checklist de Preparación del Repositorio

### Antes del Primer Commit

- [ ] Crear `.gitignore` (usar el proporcionado)
- [ ] Revisar que NO hay secretos en archivos
- [ ] Crear templates (`.example`) para configs con secretos
- [ ] Verificar tamaño de archivos (`find . -size +10M`)
- [ ] Documentar en README qué archivos se gestionan por separado
- [ ] Crear `CHANGELOG.md` para tracking de versiones

### Antes de Cada Commit

- [ ] Revisar cambios: `git diff`
- [ ] Verificar que no hay secretos: `git diff | grep -i password`
- [ ] Actualizar `CHANGELOG.md`
- [ ] Ejecutar tests locales
- [ ] Commit con mensaje descriptivo

### Antes de Cada Release

- [ ] Crear tag: `git tag -a v1.0.0 -m "Release 1.0.0"`
- [ ] Actualizar documentación de versión
- [ ] Generar release notes
- [ ] Probar en ambiente de staging
- [ ] Push tag: `git push origin v1.0.0`

---

## 🎯 Ejemplo de Workflow Completo

### Setup Inicial del Repositorio

```bash
# 1. Crear repositorio local
cd /path/to/AztecAI_Model
git init

# 2. Agregar .gitignore
cp .gitignore.template .gitignore

# 3. Crear templates de configs
cp 05_Configuracion/environment_variables.env \
   05_Configuracion/environment_variables.env.example

# Limpiar secretos del template
sed -i 's/=.*/=CHANGE_ME/' \
   05_Configuracion/environment_variables.env.example

# 4. Agregar archivos
git add .
git status  # Revisar qué se va a commitear

# 5. Primer commit
git commit -m "Initial commit: AztecAI v1.0.0"

# 6. Agregar remote (Git server interno)
git remote add origin git@gitlab.internal:aia/aztecai-deployment.git

# 7. Push
git push -u origin main
```

### Deployment en Servidor

```bash
# En servidor de producción

# 1. Clone (primera vez)
cd /opt
git clone git@gitlab.internal:aia/aztecai-deployment.git aztecai

# 2. Crear .env desde template
cd aztecai/05_Configuracion
cp environment_variables.env.example .env
nano .env  # Editar con valores reales

# 3. Ejecutar deployment
cd /opt/aztecai/04_Scripts
sudo ./deploy_production.sh

# 4. Verificar
./verify_installation.sh
```

### Update Subsecuente

```bash
# En servidor de producción
cd /opt/aztecai
git pull origin main
./04_Scripts/deploy_production.sh
```

---

## 📚 Recursos Adicionales

### Documentos Relacionados
- `.gitignore` - Archivo de exclusiones
- `DEPLOYMENT_METHODS_COMPARISON.md` - Comparación de métodos
- `DEPLOYMENT_AIRGAPPED.md` - Guía para ambientes air-gapped
- `SECURITY_BEST_PRACTICES.md` - Prácticas de seguridad

### Herramientas Útiles

```bash
# Ver tamaño de archivos
find . -type f -size +1M -exec ls -lh {} \;

# Buscar secretos accidentales
git secrets --scan

# Limpiar archivos grandes del historial
git filter-branch --tree-filter 'rm -f large_file.bin' HEAD

# Ver qué archivos están trackeados
git ls-files
```

---

**Última actualización:** Enero 2025  
**Próxima revisión:** Marzo 2025

