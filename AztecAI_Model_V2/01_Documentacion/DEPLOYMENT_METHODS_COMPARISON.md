# Comparación de Métodos de Despliegue para AztecAI

**Versión:** 1.0.0  
**Fecha:** Enero 2025  
**Owner:** Inteligencia Artificial Azteca (IAA)  

---

## 📋 Resumen Ejecutivo

Este documento compara diferentes métodos de despliegue para AztecAI en servidores de producción con restricciones de seguridad y acceso limitado a internet.

---

## 🎯 Escenario de Despliegue

### Características del Ambiente Objetivo

| Característica | Descripción |
|----------------|-------------|
| **Tipo de servidor** | Linux (Ubuntu/RHEL) en producción |
| **Acceso a internet** | Restringido o nulo (air-gapped) |
| **Seguridad** | Alta - Ambiente corporativo regulado |
| **Tamaño del proyecto** | ~3 MB (código) + ~20 GB (modelo Ollama) |
| **Frecuencia de updates** | Media (mensual para KB, trimestral para modelo) |
| **Número de servidores** | 1-10 instancias |
| **Requisitos de auditoría** | Alta trazabilidad requerida |

---

## 📊 Métodos de Despliegue Comparados

### Método A: Git Repository (GitHub/GitLab/Bitbucket)

#### Descripción
Usar un repositorio Git (privado) para versionar el código y scripts, con Git LFS para archivos grandes.

#### Arquitectura
```
Developer Workstation          Corporate Git Server          Production Server
┌─────────────────┐           ┌──────────────────┐          ┌─────────────────┐
│  AztecAI Code   │           │   Git Repository │          │  Target Server  │
│  + Scripts      │  git push │   (GitHub/GitLab)│ git pull │  (Air-gapped)   │
│  + Docs         │ ────────> │                  │ ────────>│                 │
│  + Configs      │           │  + Git LFS       │          │  Clone/Pull     │
└─────────────────┘           │  + Ollama Model  │          └─────────────────┘
                              └──────────────────┘
```

#### ✅ Ventajas

1. **Versionado Completo**
   - Control total de versiones con Git
   - Historial completo de cambios
   - Branches para desarrollo/staging/producción
   - Tags para releases

2. **Colaboración**
   - Múltiples desarrolladores pueden contribuir
   - Pull requests para revisión de código
   - Issues tracking integrado

3. **Rollback Fácil**
   - `git checkout <version>` para volver a cualquier versión
   - Branches de emergencia

4. **CI/CD Integration**
   - Automatización con GitHub Actions/GitLab CI
   - Tests automáticos pre-deployment
   - Deployment pipelines

5. **Auditoría**
   - Logs completos de quién cambió qué y cuándo
   - Compliance con regulaciones

#### ❌ Desventajas

1. **Requiere Conectividad**
   - Servidor necesita acceso a Git server (aunque sea interno)
   - Para air-gapped: requiere Git server interno o workarounds

2. **Complejidad con Archivos Grandes**
   - Git LFS necesario para modelo Ollama (~20 GB)
   - Clones iniciales lentos
   - Requiere configuración adicional

3. **Curva de Aprendizaje**
   - Equipo debe conocer Git
   - Procesos de branching/merging

4. **Overhead de Infraestructura**
   - Requiere Git server (GitHub Enterprise, GitLab self-hosted)
   - Mantenimiento del servidor Git

#### 🔐 Consideraciones de Seguridad

| Aspecto | Evaluación | Notas |
|---------|------------|-------|
| **Autenticación** | ⭐⭐⭐⭐⭐ | SSH keys, tokens, 2FA disponibles |
| **Encriptación** | ⭐⭐⭐⭐⭐ | HTTPS/SSH para transferencias |
| **Control de acceso** | ⭐⭐⭐⭐⭐ | Granular (por repo, branch, archivo) |
| **Auditoría** | ⭐⭐⭐⭐⭐ | Logs completos de acceso y cambios |
| **Air-gap compatibility** | ⭐⭐⭐ | Requiere Git server interno o bundle files |

#### 💰 Costos

- **GitHub Enterprise:** $21/usuario/mes
- **GitLab Self-Hosted:** Gratis (Community) o $19/usuario/mes (Premium)
- **Bitbucket Data Center:** $2,300/año (25 usuarios)
- **Git Server Interno:** Solo costos de infraestructura

#### 📈 Escalabilidad

| Métrica | Rating | Notas |
|---------|--------|-------|
| **Múltiples servidores** | ⭐⭐⭐⭐⭐ | Cada servidor hace git pull |
| **Updates frecuentes** | ⭐⭐⭐⭐⭐ | Incremental updates eficientes |
| **Archivos grandes** | ⭐⭐⭐ | Git LFS ayuda pero no es ideal |
| **Bandwidth efficiency** | ⭐⭐⭐⭐ | Solo descarga cambios (delta) |

#### 🎯 Recomendación de Uso

**✅ Usar cuando:**
- Tienes Git server interno o puedes usar GitHub Enterprise
- Necesitas versionado robusto y colaboración
- Múltiples ambientes (dev/staging/prod)
- Equipo familiarizado con Git
- Frecuentes updates de código/scripts

**❌ Evitar cuando:**
- Servidor completamente air-gapped sin Git interno
- Equipo sin experiencia en Git
- Solo deployment único sin updates frecuentes

---

### Método B: SCP/SFTP File Transfer

#### Descripción
Transferencia directa de archivos vía SCP (Secure Copy) o SFTP desde workstation a servidor.

#### Arquitectura
```
Developer Workstation                    Production Server
┌─────────────────┐                     ┌─────────────────┐
│  AztecAI Code   │                     │  Target Server  │
│  + Scripts      │  scp/sftp/rsync     │  (Air-gapped)   │
│  + Docs         │ ──────────────────> │                 │
│  + Configs      │  SSH Connection     │  /opt/aztecai/  │
│  + Ollama Model │                     │                 │
└─────────────────┘                     └─────────────────┘
```

#### ✅ Ventajas

1. **Simplicidad**
   - Herramientas estándar (scp, sftp, rsync)
   - No requiere infraestructura adicional
   - Fácil de entender y ejecutar

2. **Air-Gap Friendly**
   - Solo requiere SSH habilitado
   - No necesita internet ni Git server
   - Ideal para ambientes aislados

3. **Transferencia Eficiente**
   - rsync solo transfiere cambios
   - Compresión on-the-fly
   - Reanudación de transferencias interrumpidas

4. **Control Total**
   - Decides exactamente qué archivos transferir
   - No hay "magia" de Git

5. **Bajo Overhead**
   - No requiere software adicional
   - Mínimo uso de recursos

#### ❌ Desventajas

1. **Sin Versionado Automático**
   - No hay historial de cambios
   - Difícil hacer rollback
   - Requiere versionado manual (carpetas con fechas)

2. **Sin Colaboración**
   - No hay mecanismo de merge
   - Conflictos manuales
   - No hay code review integrado

3. **Auditoría Limitada**
   - Solo logs de SSH
   - No hay tracking de qué cambió
   - Difícil compliance

4. **Propenso a Errores**
   - Fácil sobrescribir archivos
   - No hay validación automática
   - Riesgo de transferencias incompletas

5. **Escalabilidad Manual**
   - Cada servidor requiere transferencia separada
   - No hay automatización built-in

#### 🔐 Consideraciones de Seguridad

| Aspecto | Evaluación | Notas |
|---------|------------|-------|
| **Autenticación** | ⭐⭐⭐⭐ | SSH keys, passwords |
| **Encriptación** | ⭐⭐⭐⭐⭐ | SSH encryption |
| **Control de acceso** | ⭐⭐⭐ | Basado en permisos SSH/filesystem |
| **Auditoría** | ⭐⭐ | Solo logs de SSH, no de cambios |
| **Air-gap compatibility** | ⭐⭐⭐⭐⭐ | Perfecto para air-gapped |

#### 💰 Costos

- **Costo:** $0 (herramientas incluidas en Linux)
- **Infraestructura:** Solo SSH habilitado

#### 📈 Escalabilidad

| Métrica | Rating | Notas |
|---------|--------|-------|
| **Múltiples servidores** | ⭐⭐ | Requiere scripts para automatizar |
| **Updates frecuentes** | ⭐⭐⭐ | rsync es eficiente |
| **Archivos grandes** | ⭐⭐⭐⭐ | Maneja bien archivos grandes |
| **Bandwidth efficiency** | ⭐⭐⭐⭐ | rsync solo transfiere cambios |

#### 🎯 Recomendación de Uso

**✅ Usar cuando:**
- Servidor completamente air-gapped
- Deployment único o poco frecuente
- Equipo pequeño sin necesidad de colaboración
- Máxima simplicidad requerida
- No hay presupuesto para Git server

**❌ Evitar cuando:**
- Necesitas versionado robusto
- Múltiples desarrolladores colaborando
- Frecuentes updates y rollbacks
- Requisitos estrictos de auditoría

---

### Método C: Artifact Repository (Nexus/Artifactory)

#### Descripción
Usar un artifact repository manager para almacenar releases versionados como paquetes.

#### Arquitectura
```
Build Server                  Artifact Repository           Production Server
┌─────────────────┐          ┌──────────────────┐          ┌─────────────────┐
│  Build Pipeline │          │  Nexus/Artifactory│          │  Target Server  │
│  Package AztecAI│  upload  │                  │ download │  (Air-gapped)   │
│  Create .tar.gz │ ───────> │  Versioned       │ ───────> │                 │
│  + Checksums    │          │  Artifacts       │          │  Extract & Run  │
└─────────────────┘          └──────────────────┘          └─────────────────┘
```

#### ✅ Ventajas

1. **Versionado de Releases**
   - Cada release es un artifact inmutable
   - Semantic versioning (1.0.0, 1.1.0, etc.)
   - Fácil rollback a versiones anteriores

2. **Checksums Automáticos**
   - Validación de integridad
   - Detección de corrupciones
   - Compliance con seguridad

3. **Metadata Rica**
   - Información de build
   - Dependencias
   - Release notes

4. **Escalabilidad**
   - Múltiples servidores descargan del mismo artifact
   - Caching y CDN
   - Alta disponibilidad

5. **Integración CI/CD**
   - Pipelines automáticos
   - Promotion entre ambientes (dev→staging→prod)

#### ❌ Desventajas

1. **Infraestructura Compleja**
   - Requiere Nexus/Artifactory server
   - Mantenimiento y configuración
   - Costos de licencias (Artifactory Pro)

2. **Overhead de Packaging**
   - Cada release requiere build/package
   - Tiempo adicional en pipeline

3. **Menos Flexible**
   - No puedes hacer cambios rápidos
   - Requiere nuevo artifact para cada cambio

#### 🔐 Consideraciones de Seguridad

| Aspecto | Evaluación | Notas |
|---------|------------|-------|
| **Autenticación** | ⭐⭐⭐⭐⭐ | LDAP, SSO, tokens |
| **Encriptación** | ⭐⭐⭐⭐⭐ | HTTPS |
| **Control de acceso** | ⭐⭐⭐⭐⭐ | Granular por artifact/repo |
| **Auditoría** | ⭐⭐⭐⭐⭐ | Logs completos de downloads |
| **Air-gap compatibility** | ⭐⭐⭐⭐ | Requiere Nexus/Artifactory interno |

#### 💰 Costos

- **Nexus OSS:** Gratis
- **Nexus Pro:** $10,000+/año
- **Artifactory Pro:** $2,950+/año

#### 🎯 Recomendación de Uso

**✅ Usar cuando:**
- Ya tienes Nexus/Artifactory en la empresa
- Necesitas releases formales versionados
- CI/CD pipeline maduro
- Múltiples ambientes y servidores
- Requisitos estrictos de compliance

**❌ Evitar cuando:**
- No tienes artifact repository
- Proyecto pequeño sin CI/CD
- Necesitas flexibilidad para cambios rápidos

---

### Método D: USB/Physical Media Transfer

#### Descripción
Transferencia física de archivos vía USB, disco externo, o DVD para ambientes completamente aislados.

#### ✅ Ventajas
- Máxima seguridad (air-gap total)
- No requiere red
- Simple y directo

#### ❌ Desventajas
- Muy lento y manual
- Propenso a errores
- No escalable
- Sin versionado
- Riesgo de malware en USB

#### 🎯 Recomendación de Uso

**✅ Usar cuando:**
- Servidor completamente air-gapped sin SSH
- Máxima seguridad requerida (militar/gobierno)
- Deployment único sin updates

**❌ Evitar cuando:**
- Hay cualquier conectividad de red disponible
- Necesitas updates frecuentes

---

## 📊 Matriz de Comparación Completa

| Criterio | Git Repository | SCP/SFTP | Artifact Repo | USB Transfer |
|----------|----------------|----------|---------------|--------------|
| **Versionado** | ⭐⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐⭐ | ⭐ |
| **Rollback** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐ |
| **Auditoría** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ |
| **Air-gap friendly** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Simplicidad** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| **Escalabilidad** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ |
| **Bandwidth efficiency** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | N/A |
| **Archivos grandes** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Colaboración** | ⭐⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐ | ⭐ |
| **Costo** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Seguridad** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 🏆 Recomendación Final

### Para AztecAI en TV Azteca

Basado en el análisis, recomiendo un **enfoque híbrido**:

#### 🥇 Opción Recomendada: Git Repository (Interno) + SCP para Modelo

**Arquitectura Propuesta:**

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT ARCHITECTURE                       │
└─────────────────────────────────────────────────────────────────┘

Development                Git Server (Interno)         Production
┌──────────────┐          ┌──────────────────┐         ┌──────────────┐
│              │          │                  │         │              │
│  Developers  │  push    │  GitLab/GitHub   │  pull   │  Server 1    │
│  + IAA Team  │ ──────>  │  Enterprise      │ ──────> │  (Prod)      │
│              │          │                  │         │              │
│  Code        │          │  • Code          │         │  Clone repo  │
│  Scripts     │          │  • Scripts       │         │  Run deploy  │
│  Docs        │          │  • Docs          │         │              │
│  Configs     │          │  • KB files      │         └──────────────┘
│              │          │  • Configs       │                │
└──────────────┘          │                  │                │ pull
                          │  NO large files  │                │
                          └──────────────────┘                ▼
                                                       ┌──────────────┐
Artifact Storage                                       │  Server 2    │
┌──────────────┐                                       │  (Staging)   │
│              │          scp/rsync                    └──────────────┐
│  File Server │ ─────────────────────────────────────────────────────┘
│  (Internal)  │          One-time transfer
│              │
│  • Ollama    │          OR: Pre-installed on servers
│    Model     │
│    (20 GB)   │
└──────────────┘
```

**Implementación:**

1. **Git Repository (GitLab Self-Hosted o GitHub Enterprise):**
   - Código, scripts, documentación, configs
   - Knowledge Base files (97 KB - pequeños)
   - Versionado completo
   - Branches: `main`, `staging`, `development`
   - Tags para releases: `v1.0.0`, `v1.1.0`, etc.

2. **Modelo Ollama (20 GB):**
   - **Opción A:** Pre-instalado en servidores (recomendado)
   - **Opción B:** Transferencia única vía SCP/rsync
   - **Opción C:** Almacenado en file server interno accesible

3. **Workflow de Deployment:**
   ```bash
   # En servidor de producción
   cd /opt/aztecai
   git pull origin main
   ./04_Scripts/deploy_production.sh
   ```

#### ✅ Beneficios de Este Enfoque

1. **Mejor de Ambos Mundos:**
   - Versionado robusto para código (Git)
   - Transferencia eficiente para archivos grandes (SCP/pre-install)

2. **Seguridad:**
   - Git server interno (no internet)
   - SSH keys para autenticación
   - Auditoría completa

3. **Escalabilidad:**
   - Múltiples servidores hacen `git pull`
   - Modelo se instala una vez por servidor

4. **Mantenibilidad:**
   - Updates de código: `git pull`
   - Updates de modelo: Proceso separado (poco frecuente)

5. **Rollback:**
   - Código: `git checkout v1.0.0`
   - Modelo: Mantener versiones anteriores en `/opt/ollama/models/`

#### 📋 Checklist de Implementación

**Fase 1: Setup Inicial (Una vez)**
- [ ] Instalar GitLab/GitHub Enterprise en servidor interno
- [ ] Crear repositorio privado `aztecai-deployment`
- [ ] Configurar SSH keys para servidores de producción
- [ ] Transferir modelo Ollama a servidores (una vez)

**Fase 2: Primer Deployment**
- [ ] Push código a Git repository
- [ ] En servidor: `git clone <repo>`
- [ ] Ejecutar `deploy_production.sh`
- [ ] Verificar instalación

**Fase 3: Updates Subsecuentes**
- [ ] Desarrollar cambios en branch `development`
- [ ] Merge a `staging` → probar
- [ ] Merge a `main` → tag release
- [ ] En servidores: `git pull && ./deploy_production.sh`

---

## 🎯 Decisión por Escenario

### Escenario 1: Servidor con SSH pero sin Internet
**Recomendación:** Git Repository Interno + SCP para modelo
**Razón:** Balance perfecto de versionado y practicidad

### Escenario 2: Servidor Completamente Air-Gapped (sin red)
**Recomendación:** USB Transfer + Git Bundles
**Razón:** Única opción viable
```bash
# Crear bundle en workstation
git bundle create aztecai.bundle --all

# Transferir vía USB
# En servidor
git clone aztecai.bundle aztecai
```

### Escenario 3: Múltiples Servidores con Red Interna
**Recomendación:** Git Repository Interno + Artifact Repository
**Razón:** Máxima escalabilidad y control

### Escenario 4: Deployment Único sin Updates Frecuentes
**Recomendación:** SCP/SFTP
**Razón:** Simplicidad máxima

### Escenario 5: Ambiente Regulado con Auditoría Estricta
**Recomendación:** Git Repository + Artifact Repository
**Razón:** Máxima trazabilidad y compliance

---

## 📚 Recursos Adicionales

### Documentos Relacionados
- `DEPLOYMENT_AIRGAPPED.md` - Guía detallada para ambientes air-gapped
- `REPOSITORY_STRUCTURE.md` - Qué incluir/excluir en el repositorio
- `SECURITY_BEST_PRACTICES.md` - Prácticas de seguridad para deployment

### Herramientas Recomendadas
- **Git:** Version control
- **rsync:** Transferencia eficiente de archivos
- **GitLab Runner:** CI/CD automation
- **Ansible:** Configuration management (opcional)

---

## 📞 Contacto

**Preguntas sobre deployment:**
- Equipo: Inteligencia Artificial Azteca (IAA)
- CAIO: Héctor Romero Pico

---

**Última actualización:** Enero 2025
**Próxima revisión:** Marzo 2025


