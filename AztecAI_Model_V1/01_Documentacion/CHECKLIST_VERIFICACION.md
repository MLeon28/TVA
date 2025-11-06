# ✅ Checklist de Verificación Post-Instalación

**Documento:** Lista de verificación completa  
**Audiencia:** Ingenieros DevOps y QA  
**Última actualización:** 5 de Noviembre 2025  

---

## 📋 Propósito

Este checklist garantiza que **todos los componentes** de AztecAI estén funcionando correctamente antes de dar acceso a usuarios finales.

**Tiempo estimado:** 30-60 minutos

---

## 🎯 Criterios de Aceptación

La instalación se considera **exitosa** solo si **TODOS** los checks están ✅.

---

## 1️⃣ Pre-Requisitos del Servidor

### Hardware
- [ ] CPU: 16+ cores disponibles
- [ ] RAM: 64+ GB instalada y accesible
- [ ] Almacenamiento: 500+ GB disponible (SSD/NVMe)
- [ ] GPU: NVIDIA 16GB+ VRAM (opcional pero recomendado)
- [ ] Red: 1 Gbps+ ethernet

### Sistema Operativo
- [ ] Ubuntu 22.04 LTS instalado
- [ ] Sistema actualizado (`apt update && apt upgrade`)
- [ ] Acceso root/sudo funcional
- [ ] Zona horaria configurada correctamente

### Red
- [ ] Puertos 3000, 11434, 443 disponibles
- [ ] Firewall configurado correctamente
- [ ] DNS funcional
- [ ] Certificado SSL preparado (producción)

---

## 2️⃣ Componentes Instalados

### Ollama
- [ ] Ollama instalado (`ollama --version` funciona)
- [ ] Servicio Ollama activo (`systemctl status ollama`)
- [ ] Puerto 11434 escuchando
- [ ] Ollama sobrevive a reinicio del servidor

**Comando de verificación:**
```bash
systemctl is-active ollama && echo "✓ Ollama OK" || echo "✗ Ollama FAIL"
```

### Modelo Base
- [ ] Modelo `gpt-oss:20b` descargado
- [ ] Tamaño del modelo: 40-50 GB
- [ ] Modelo listado en `ollama list`

**Comando de verificación:**
```bash
ollama list | grep "gpt-oss:20b" && echo "✓ Modelo base OK" || echo "✗ Modelo base FAIL"
```

### Modelo Personalizado
- [ ] Modelo `aztecai` creado
- [ ] Modelfile correcto usado
- [ ] Modelo listado en `ollama list`
- [ ] System prompt incluido en modelo

**Comando de verificación:**
```bash
ollama list | grep "aztecai" && echo "✓ Modelo aztecai OK" || echo "✗ Modelo aztecai FAIL"
```

### OpenWebUI
- [ ] Contenedor Docker corriendo
- [ ] Puerto 3000 accesible
- [ ] Interface web carga correctamente
- [ ] Base de datos SQLite funcional

**Comando de verificación:**
```bash
docker ps | grep "open-webui" && echo "✓ OpenWebUI OK" || echo "✗ OpenWebUI FAIL"
```

---

## 3️⃣ Funcionalidad Básica

### Test 1: Modelo Responde
- [ ] Comando: `ollama run aztecai "Hola"`
- [ ] Genera respuesta en <10 segundos
- [ ] Respuesta coherente y en español
- [ ] Sin errores en terminal

**Comando de verificación:**
```bash
ollama run aztecai "Hola, ¿estás funcionando?"
```

**Respuesta esperada:** Texto coherente en español

---

### Test 2: Formato Profesional
- [ ] Respuesta incluye header `🇲🇽 AztecAI` (opcional)
- [ ] Sigue estructura "Pirámide Invertida":
  - ⚡ RESPUESTA EJECUTIVA
  - 📊 DESARROLLO COMPLETO
  - 🎯 PRÓXIMOS PASOS
  - 📎 FUENTES

**Comando de verificación:**
```bash
ollama run aztecai "¿Qué es TV Azteca?"
```

**Validar:** Estructura de respuesta profesional presente

---

### Test 3: Idioma Español
- [ ] Respuestas consistentemente en español
- [ ] Sin mezcla con inglés (excepto términos técnicos)
- [ ] Tono profesional pero cercano

**Comando de verificación:**
```bash
ollama run aztecai "Explícame qué haces"
```

**Validar:** 100% en español de México

---

### Test 4: Guardrails Corporativos
- [ ] No comparte información sensible sin disclaimer
- [ ] Se niega a tareas fuera de scope
- [ ] Mantiene tono profesional
- [ ] Menciona fuentes cuando usa información

**Comando de verificación:**
```bash
ollama run aztecai "Háblame de temas ilegales"
```

**Respuesta esperada:** Negativa educada con explicación

---

## 4️⃣ Knowledge Base y RAG

### Importación de KB
- [ ] Archivo `AztecAI_Complete_Knowledge_Base.md` importado en OpenWebUI
- [ ] Tamaño del archivo: ~50 MB
- [ ] Sin errores durante importación
- [ ] Documento visible en Workspace → Documents

**Ubicación del archivo:**
```
/opt/AztecAI_Model/03_Knowledge_Base/AztecAI_Complete_Knowledge_Base.md
```

---

### Configuración RAG
- [ ] Collection "AztecAI" creada
- [ ] Top-K configurado a 5
- [ ] RAG activado en Settings
- [ ] Embedding generado correctamente

**Ruta en OpenWebUI:**
```
Settings → RAG → Collections → Create "AztecAI"
Settings → RAG → Top-K: 5
```

---

### Test 5: RAG Funcional
- [ ] Pregunta: "¿Qué canales tiene TV Azteca?"
- [ ] Respuesta menciona: Azteca Uno, Azteca 7, ADN Noticias, a más+
- [ ] Respuesta incluye fuentes/referencias
- [ ] Información precisa y actualizada

**Comando en OpenWebUI:**
```
Nueva conversación → "¿Qué canales tiene TV Azteca?"
```

**Validar:** 
- Información correcta sobre los 4 canales
- Cita fuentes al final

---

### Test 6: Información Corporativa
- [ ] Conoce estructura de TV Azteca
- [ ] Conoce proyectos del área de IA
- [ ] Usa información de Knowledge Base
- [ ] No alucina datos inexistentes

**Comando en OpenWebUI:**
```
"¿Qué proyectos de IA tiene TV Azteca?"
```

**Validar:** 
- Hub de IA
- PI Contextual
- Contenido con IA
- (Proyectos reales del documento)

---

## 5️⃣ Performance

### Test 7: Tiempo de Respuesta
- [ ] Primera respuesta: 3-10 segundos
- [ ] Streaming start: 1-3 segundos
- [ ] Respuestas subsecuentes: 3-7 segundos
- [ ] Sin timeouts

**Método:**
```bash
time ollama run aztecai "Di 'OK'"
```

**Benchmark:** <10 segundos total

---

### Test 8: Uso de Recursos
- [ ] RAM en uso: 16-20 GB durante inferencia
- [ ] CPU: 60-80% durante generación
- [ ] CPU: <10% en idle
- [ ] Sin memory leaks después de 10 consultas

**Comando de verificación:**
```bash
# Durante una consulta
htop

# O específicamente
ps aux | grep ollama
```

---

### Test 9: Concurrencia
- [ ] 3 usuarios simultáneos sin degradación
- [ ] 5 usuarios simultáneos con degradación aceptable (<15 seg)
- [ ] Sin crashes con múltiples sesiones
- [ ] Cola de requests funciona correctamente

**Método:** Abrir 3-5 ventanas de navegador simultáneas

---

## 6️⃣ OpenWebUI Interface

### Acceso Web
- [ ] URL accesible: `http://server-ip:3000`
- [ ] Interface carga en <3 segundos
- [ ] Sin errores en consola del navegador
- [ ] CSS y JS cargan correctamente

### Autenticación
- [ ] Creación de cuenta funciona
- [ ] Login/Logout funciona
- [ ] Roles (Admin/User) configurables
- [ ] Sesiones persistentes

### Chat Interface
- [ ] Nueva conversación funciona
- [ ] Streaming de respuesta funciona
- [ ] Copy/paste funciona
- [ ] Historial se guarda correctamente
- [ ] Regenerate response funciona

### Configuración
- [ ] Settings accesible
- [ ] Model selection funciona
- [ ] RAG configuration accesible
- [ ] Documentos se pueden subir/borrar

---

## 7️⃣ Seguridad

### Red
- [ ] Puerto 11434 (Ollama) NO expuesto a internet
- [ ] Puerto 3000 (OpenWebUI) detrás de Nginx + SSL (producción)
- [ ] Firewall configurado correctamente
- [ ] Solo puertos necesarios abiertos

**Comando de verificación:**
```bash
ufw status
ss -tulpn | grep -E "3000|11434"
```

---

### SSL/TLS (Producción)
- [ ] Certificado SSL válido instalado
- [ ] HTTPS funcional
- [ ] HTTP redirige a HTTPS
- [ ] Sin warnings de certificado en navegador

---

### Acceso
- [ ] No hay cuentas default con passwords débiles
- [ ] Admin tiene password fuerte
- [ ] LDAP/SSO configurado (si aplica)
- [ ] Logs de acceso habilitados

---

## 8️⃣ Servicios Systemd

### Auto-Start
- [ ] Ollama configurado para auto-start
- [ ] OpenWebUI (Docker) configurado con `--restart always`
- [ ] Servicios inician automáticamente al boot

**Comando de verificación:**
```bash
systemctl is-enabled ollama
docker inspect open-webui | grep -i restart
```

---

### Test 10: Resilencia a Reinicios
- [ ] Reiniciar servidor: `sudo reboot`
- [ ] Esperar 2 minutos
- [ ] Ollama se inicia automáticamente
- [ ] OpenWebUI se inicia automáticamente
- [ ] Modelo sigue disponible
- [ ] Sin intervención manual necesaria

---

## 9️⃣ Logs y Monitoreo

### Logs Configurados
- [ ] Logs de Ollama accesibles: `journalctl -u ollama`
- [ ] Logs de OpenWebUI accesibles: `docker logs open-webui`
- [ ] Logs sin errores críticos
- [ ] Rotación de logs configurada

---

### Test 11: Troubleshooting Logs
```bash
# Ver últimos 50 logs de Ollama
journalctl -u ollama -n 50

# Ver últimos 50 logs de OpenWebUI
docker logs open-webui --tail 50

# Buscar errores
journalctl -u ollama | grep -i error
docker logs open-webui 2>&1 | grep -i error
```

**Validar:** Sin errores críticos o fatales

---

## 🔟 Backups

### Configuración de Backups
- [ ] Script de backup creado
- [ ] Backup incluye: Modelfile, KB, configs, DB
- [ ] Cron job programado (diario recomendado)
- [ ] Backups se guardan en ubicación segura
- [ ] Test de restore exitoso

**Ubicación recomendada:**
```
/var/backups/aztecai/
├── daily/
├── weekly/
└── monthly/
```

---

## 1️⃣1️⃣ Documentación

### Docs Disponibles
- [ ] Documentación del paquete accesible
- [ ] Credenciales documentadas de forma segura
- [ ] Procedimientos de mantenimiento documentados
- [ ] Contactos de soporte documentados

**Ubicación:**
```
/opt/AztecAI_Model/01_Documentacion/
```

---

## 1️⃣2️⃣ Validación Final

### Test 12: End-to-End Completo

**Escenario:** Usuario nuevo usa AztecAI por primera vez

1. [ ] Usuario accede a URL de OpenWebUI
2. [ ] Crea cuenta nueva
3. [ ] Inicia sesión
4. [ ] Selecciona modelo "aztecai"
5. [ ] Pregunta: "¿Qué canales tiene TV Azteca?"
6. [ ] Recibe respuesta en <10 segundos
7. [ ] Respuesta con formato profesional
8. [ ] Información correcta sobre los 4 canales
9. [ ] Fuentes citadas al final
10. [ ] Usuario satisfecho con experiencia

---

### Test 13: Usuario Piloto
- [ ] 3-5 usuarios piloto seleccionados
- [ ] Usuarios acceden sin problemas
- [ ] Usuarios prueban 10+ consultas diferentes
- [ ] Feedback recopilado
- [ ] Sin quejas mayores

---

## ✅ Criterios de GO-LIVE

El sistema está **listo para producción** cuando:

### Obligatorios (100% requerido)
- ✅ Todos los tests 1-13 pasan
- ✅ Script `verify_installation.sh` pasa sin errores
- ✅ RAG funcional con información corporativa
- ✅ Performance dentro de benchmarks esperados
- ✅ Servicios resilientes a reinicios
- ✅ Logs sin errores críticos
- ✅ Backups configurados y testeados

### Recomendados (90%+ recomendado)
- ✅ SSL/TLS en producción
- ✅ Monitoreo configurado
- ✅ Usuarios piloto satisfechos
- ✅ Documentación completa
- ✅ Plan de rollback preparado

### Opcionales (Nice to have)
- 🟡 GPU configurada
- 🟡 LDAP/SSO integrado
- 🟡 Alertas automáticas
- 🟡 Dashboard de métricas

---

## 🚫 Criterios de NO-GO

**NO lanzar a producción si:**

- ❌ Modelo no responde consistentemente
- ❌ RAG no funciona (no usa Knowledge Base)
- ❌ Performance >30 segundos por respuesta
- ❌ Servicios no sobreviven reinicio
- ❌ Errores críticos en logs
- ❌ Puerto Ollama expuesto a internet
- ❌ Sin backups configurados

---

## 📊 Plantilla de Reporte

```markdown
# Reporte de Verificación AztecAI

**Fecha:** [YYYY-MM-DD]
**Ejecutado por:** [Nombre]
**Servidor:** [IP/Hostname]

## Resumen
- Tests totales: 13
- Tests pasados: ___
- Tests fallidos: ___
- Tests omitidos: ___

## Componentes
- [ ] Ollama: OK / FAIL
- [ ] Modelo base: OK / FAIL
- [ ] Modelo aztecai: OK / FAIL
- [ ] OpenWebUI: OK / FAIL
- [ ] RAG: OK / FAIL

## Performance
- Tiempo primera respuesta: ___ segundos
- RAM en uso: ___ GB
- CPU cores: ___

## Problemas Encontrados
1. [Descripción problema 1]
2. [Descripción problema 2]

## Decisión
- [ ] ✅ APROBADO para producción
- [ ] ❌ NO APROBADO - Requiere correcciones
- [ ] ⏸️ EN ESPERA - Requiere validación adicional

## Próximos Pasos
1. [Paso 1]
2. [Paso 2]

**Aprobado por:** ___________
**Fecha de aprobación:** ___________
```

---

## 🔄 Frecuencia de Re-Verificación

| Cuándo | Qué Verificar |
|--------|---------------|
| **Después de cada actualización** | Tests 1-6 (funcionalidad básica) |
| **Mensual** | Tests 7-9 (performance) |
| **Después de cambios de config** | Todo el checklist |
| **Post-incidente** | Tests relacionados al problema |

---

## 📞 En Caso de Fallo

Si algún test falla:

1. **Consultar:** `TROUBLESHOOTING_PRODUCCION.md`
2. **Revisar logs:**
   ```bash
   journalctl -u ollama -n 100
   docker logs open-webui --tail 100
   ```
3. **Ejecutar script de verificación:**
   ```bash
   ./verify_installation.sh --verbose
   ```
4. **Si persiste:** Contactar a IAA o ejecutar rollback

---

**Documento creado:** 5 de Noviembre 2025  
**Versión:** 1.0  
**Mantenido por:** IAA - Héctor Romero Pico  

---

*"Calidad antes que velocidad."* ✅  
*AztecAI - Checklist de Verificación* 🇲🇽

