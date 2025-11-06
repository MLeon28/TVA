# 🏗️ Arquitectura Técnica de AztecAI

**Documento:** Diseño y Componentes del Sistema  
**Audiencia:** Arquitectos de Software e Ingenieros  
**Última actualización:** 5 de Noviembre 2025  

---

## 📊 Diagrama de Arquitectura General

```
┌───────────────────────────────────────────────────────────────┐
│                       USUARIOS FINALES                         │
│                  (Empleados de TV Azteca)                      │
└──────────────────────────┬────────────────────────────────────┘
                           │
                           │ HTTPS (443)
                           ▼
┌───────────────────────────────────────────────────────────────┐
│                    CAPA DE PRESENTACIÓN                        │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Nginx Reverse Proxy                                    │  │
│  │  • SSL/TLS Termination                                  │  │
│  │  • Load Balancing (opcional)                            │  │
│  │  • Puerto 443 → 3000                                    │  │
│  └─────────────────────────────────────────────────────────┘  │
└──────────────────────────┬────────────────────────────────────┘
                           │ HTTP (3000)
                           ▼
┌───────────────────────────────────────────────────────────────┐
│                    CAPA DE APLICACIÓN                          │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  OpenWebUI (Docker Container)                           │  │
│  │  Puerto: 3000 (interno 8080)                            │  │
│  │                                                          │  │
│  │  ┌──────────────────────────────────────────────────┐   │  │
│  │  │  Frontend (React + TailwindCSS)                  │   │  │
│  │  │  • Chat Interface                                │   │  │
│  │  │  • Document Management                           │   │  │
│  │  │  • Settings UI                                   │   │  │
│  │  └──────────────────────────────────────────────────┘   │  │
│  │                                                          │  │
│  │  ┌──────────────────────────────────────────────────┐   │  │
│  │  │  Backend (Python FastAPI)                        │   │  │
│  │  │  • API Endpoints                                 │   │  │
│  │  │  • Authentication                                │   │  │
│  │  │  • Session Management                            │   │  │
│  │  └──────────────────────────────────────────────────┘   │  │
│  │                                                          │  │
│  │  ┌──────────────────────────────────────────────────┐   │  │
│  │  │  RAG System                                      │   │  │
│  │  │  • Document Processing                           │   │  │
│  │  │  • Embeddings Generation                         │   │  │
│  │  │  • Semantic Search (Top-K: 5)                    │   │  │
│  │  │  • Context Enrichment                            │   │  │
│  │  └──────────────────────────────────────────────────┘   │  │
│  │                                                          │  │
│  │  ┌──────────────────────────────────────────────────┐   │  │
│  │  │  Database (SQLite)                               │   │  │
│  │  │  • User data                                     │   │  │
│  │  │  • Conversations                                 │   │  │
│  │  │  • Settings                                      │   │  │
│  │  └──────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────┘  │
└──────────────────────────┬────────────────────────────────────┘
                           │ HTTP API (11434)
                           ▼
┌───────────────────────────────────────────────────────────────┐
│                    CAPA DE INFERENCIA                          │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Ollama Engine                                          │  │
│  │  Puerto: 11434                                          │  │
│  │                                                          │  │
│  │  ┌──────────────────────────────────────────────────┐   │  │
│  │  │  Model Manager                                   │   │  │
│  │  │  • Load models in memory                         │   │  │
│  │  │  • Model lifecycle                               │   │  │
│  │  └──────────────────────────────────────────────────┘   │  │
│  │                                                          │  │
│  │  ┌──────────────────────────────────────────────────┐   │  │
│  │  │  Inference Engine                                │   │  │
│  │  │  • Token generation                              │   │  │
│  │  │  • Streaming responses                           │   │  │
│  │  │  • GPU acceleration (opcional)                   │   │  │
│  │  └──────────────────────────────────────────────────┘   │  │
│  │                                                          │  │
│  │  ┌──────────────────────────────────────────────────┐   │  │
│  │  │  Modelo: aztecai                                 │   │  │
│  │  │  Base: gpt-oss:20b                               │   │  │
│  │  │  System Prompt: 450 líneas                       │   │  │
│  │  │  Size: ~45GB en memoria                          │   │  │
│  │  └──────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────┐
│                    CAPA DE DATOS                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Knowledge Base (RAG)                                   │  │
│  │  • AztecAI_Complete_Knowledge_Base.md (2,690 líneas)   │  │
│  │  • System Prompt completo                              │  │
│  │  • Información corporativa TV Azteca                   │  │
│  │  • Embeddings vectorizados                             │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Model Storage (/opt/ollama/models/)                   │  │
│  │  • gpt-oss:20b (40-50 GB)                              │  │
│  │  • aztecai (45-55 GB)                                  │  │
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Datos

### Flujo de una Consulta Típica

```
1. USUARIO escribe: "¿Qué canales tiene TV Azteca?"
   │
   ▼
2. NGINX recibe request HTTPS (puerto 443)
   │
   ▼
3. NGINX forward a OpenWebUI (puerto 3000)
   │
   ▼
4. OpenWebUI BACKEND (FastAPI)
   ├─→ Autentica usuario
   ├─→ Valida sesión
   └─→ Procesa consulta
       │
       ▼
5. RAG SYSTEM busca en Knowledge Base
   ├─→ Genera embedding de la pregunta
   ├─→ Busca documentos similares
   ├─→ Recupera Top-5 chunks más relevantes
   └─→ Encuentra información sobre canales
       │
       ▼
6. OpenWebUI construye PROMPT enriquecido
   ┌─────────────────────────────────────┐
   │ [System Prompt del modelo]          │
   │ + [Contexto de Knowledge Base]      │
   │ + [Pregunta del usuario]            │
   └─────────────────────────────────────┘
       │
       ▼
7. OpenWebUI envía a OLLAMA (puerto 11434)
   │
   ▼
8. OLLAMA carga modelo aztecai en RAM
   │
   ▼
9. INFERENCE ENGINE genera respuesta
   ├─→ Procesa prompt completo
   ├─→ Genera tokens uno por uno
   ├─→ Aplica System Prompt (formato)
   └─→ Stream de respuesta
       │
       ▼
10. OLLAMA envía respuesta a OpenWebUI
   │
   ▼
11. OpenWebUI procesa y formatea
   ├─→ Aplica highlighting
   ├─→ Renderiza markdown
   └─→ Guarda en historial (SQLite)
       │
       ▼
12. FRONTEND muestra respuesta al usuario
   │
   ▼
13. USUARIO ve respuesta en formato profesional
    ⚡ RESPUESTA EJECUTIVA
    TV Azteca opera 4 canales...
    
    📊 DESARROLLO COMPLETO
    • Azteca Uno: Entretenimiento...
    • Azteca 7: Deportes...
    • ADN Noticias: Información...
    • a más+: Contenido familia...
    
    🎯 PRÓXIMOS PASOS
    [...]
    
    📎 Fuentes: [Knowledge Base]
```

**Tiempo total:** 3-7 segundos

---

## 🧩 Componentes Detallados

### 1. Nginx (Reverse Proxy)

**Propósito:** Punto de entrada seguro

**Funciones:**
- SSL/TLS termination
- Reverse proxy a OpenWebUI
- Load balancing (multi-instancia)
- Rate limiting
- Compression

**Puerto:** 443 (HTTPS) → 3000 (OpenWebUI)

**Config clave:**
```nginx
proxy_pass http://localhost:3000;
proxy_http_version 1.1;  # Para WebSocket
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

---

### 2. OpenWebUI

**Tecnología:** React + Python FastAPI + SQLite

**Submódulos:**

#### Frontend (React)
- Chat interface
- Document management
- User settings
- Model selection

#### Backend (FastAPI)
- `/api/chat` - Chat endpoint
- `/api/documents` - Document management
- `/api/auth` - Authentication
- `/api/models` - Model management

#### RAG System
- **Document Processing:**
  - Markdown parsing
  - Chunk creation (1500 chars)
  - Overlap (150 chars)

- **Embeddings:**
  - Sentence transformers
  - Vector storage
  - Semantic search

- **Retrieval:**
  - Top-K: 5 chunks
  - Similarity threshold
  - Context window management

#### Database (SQLite)
```
Tables:
- users (id, email, password_hash, role)
- conversations (id, user_id, title, created_at)
- messages (id, conversation_id, role, content)
- documents (id, filename, content, embeddings)
- settings (key, value)
```

---

### 3. Ollama

**Propósito:** Motor de inferencia local

**Arquitectura:**
```
Ollama Service
├── API Server (puerto 11434)
├── Model Loader
│   └── Carga modelos GGUF en RAM
├── Inference Engine
│   ├── Token generation
│   ├── Sampling (temperature, top_p, top_k)
│   └── Streaming
└── Hardware Abstraction
    ├── CPU backend (default)
    └── GPU backend (CUDA/Metal)
```

**Endpoints API:**
```
POST /api/generate
POST /api/chat
GET /api/tags (list models)
POST /api/create (create model)
POST /api/pull (download model)
```

---

### 4. Modelo aztecai

**Composición:**
```
aztecai = gpt-oss:20b + Modelfile

Modelfile contiene:
├── FROM gpt-oss:20b
├── SYSTEM "[System Prompt 450 líneas]"
└── PARAMETER [10 parámetros]
```

**En memoria:**
```
Modelo base: 40 GB
System prompt: ~500 KB
Context window: Variable (hasta 8192 tokens)
Total: ~40-45 GB RAM durante inferencia
```

**Parámetros clave:**
```
temperature: 0.7       (creatividad balanceada)
top_p: 0.9            (nucleus sampling)
top_k: 40             (limit candidatos)
num_ctx: 8192         (context window)
num_predict: 2048     (max output)
repeat_penalty: 1.1   (anti-repetición)
```

---

## 🔐 Arquitectura de Seguridad

### Capas de Seguridad

```
1. EDGE LAYER (Nginx)
   ├── SSL/TLS encryption
   ├── Rate limiting
   └── DDoS protection

2. APPLICATION LAYER (OpenWebUI)
   ├── Authentication (JWT)
   ├── Authorization (RBAC)
   ├── Input validation
   └── XSS protection

3. DATA LAYER
   ├── Encrypted passwords (bcrypt)
   ├── Secure sessions
   └── SQLite file permissions

4. NETWORK LAYER
   ├── Firewall (UFW)
   ├── Port isolation
   │   • 11434: Internal only
   │   • 3000: Behind Nginx only
   │   • 443: Public (HTTPS)
   └── No external connections
```

### Flujo de Autenticación

```
1. Usuario → Login (email + password)
2. OpenWebUI → Valida contra DB
3. Si válido → Genera JWT token
4. Cliente almacena token
5. Requests subsecuentes incluyen JWT
6. Backend valida JWT en cada request
```

---

## 📊 Arquitectura de Datos

### Knowledge Base Structure

```
AztecAI_Complete_Knowledge_Base.md
├── Section 01: Metadata y Control
├── Section 02: Identidad y Misión
├── Section 03: Lenguaje y Comunicación
├── Section 04: Seguridad y Guardrails
├── Section 05: Framework Operativo
├── Section 06: Conocimiento y Veracidad
├── Section 07: Dominios y Capacidades
├── Section 08: Temas Regulados
├── Section 09: Respuestas Tipo
├── Section 10: Gobernanza
├── Section 11: Mantenimiento
├── Section 12: Casos de Uso
├── Section 13: Cierre
└── Section 14: Info Corporativa TV Azteca
```

### RAG Processing Pipeline

```
1. INGESTION
   Document → Parse → Chunk (1500 chars)
   
2. EMBEDDING
   Chunk → Sentence Transformer → Vector [768 dims]
   
3. STORAGE
   Vector + Metadata → Vector DB (Chroma/FAISS)
   
4. RETRIEVAL (Query time)
   Query → Embedding → Similarity Search → Top-K chunks
   
5. AUGMENTATION
   Original Prompt + Retrieved Chunks → Enriched Prompt
```

---

## ⚡ Arquitectura de Performance

### Optimizaciones Implementadas

**1. System Prompt Pequeño (450 líneas)**
- Siempre en memoria
- Carga rápida
- ✅ 2-3x más rápido que 2,690 líneas

**2. RAG Lazy Loading**
- Solo carga contexto relevante
- Top-K: 5 chunks
- ✅ Reduce uso de memoria

**3. Model Quantization**
- GGUF Q4_K_M format
- 4-bit weights
- ✅ 40 GB vs 80 GB (FP16)

**4. Streaming Responses**
- Token-by-token generation
- User ve respuesta inmediatamente
- ✅ Mejora UX

**5. Context Window Optimization**
- 8192 tokens (balanceado)
- Suficiente para conversación larga
- ✅ No sobredimensionado

### Escalabilidad

**Vertical (Single Server):**
```
1-10 usuarios: OK con CPU
10-50 usuarios: Recomendado GPU
50-100 usuarios: Requiere GPU + optimizations
```

**Horizontal (Multi-Server):**
```
OpenWebUI: Múltiples instancias + Load Balancer
Ollama: Instancia dedicada por N usuarios
Shared Knowledge Base: NFS o S3
```

---

## 🔄 Diagrama de Despliegue

```
┌─────────────────────────────────────────────────────────┐
│  PRODUCTION SERVER                                      │
│                                                         │
│  OS: Ubuntu 22.04 LTS                                   │
│  RAM: 64 GB                                             │
│  Storage: 500 GB NVMe                                   │
│  CPU: 16 cores                                          │
│  GPU: NVIDIA RTX 4090 24GB (opcional)                   │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  /opt/ollama/                                     │ │
│  │  ├── models/                                      │ │
│  │  │   ├── gpt-oss:20b (40-50 GB)                  │ │
│  │  │   └── aztecai (45-55 GB)                      │ │
│  │  └── logs/                                        │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  Docker Container: open-webui                     │ │
│  │  ├── /app/backend/data/ (SQLite DB)              │ │
│  │  └── /app/backend/documents/ (Knowledge Base)    │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  /etc/nginx/                                      │ │
│  │  └── sites-enabled/aztecai                       │ │
│  └───────────────────────────────────────────────────┘ │
│                                                         │
│  ┌───────────────────────────────────────────────────┐ │
│  │  /var/backups/aztecai/                           │ │
│  │  ├── daily/                                       │ │
│  │  └── weekly/                                      │ │
│  └───────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## 📈 Decisiones de Arquitectura

### ¿Por qué Ollama?
✅ Local, sin dependencias cloud  
✅ Open source  
✅ Soporta GGUF (quantized models)  
✅ API simple  
✅ Auto-gestión de modelos  

### ¿Por qué OpenWebUI?
✅ Interface moderna  
✅ RAG integrado  
✅ User management  
✅ Open source  
✅ Fácil deployment (Docker)  

### ¿Por qué Arquitectura Híbrida?
✅ System Prompt pequeño = rápido  
✅ Knowledge Base grande = completa  
✅ Actualizable sin recrear modelo  
✅ Balance óptimo performance/flexibilidad  

### ¿Por qué SQLite?
✅ Suficiente para <100 usuarios  
✅ Zero-config  
✅ File-based (fácil backup)  
✅ Upgrade a PostgreSQL si crece  

---

**Documento creado:** 5 de Noviembre 2025  
**Versión:** 1.0  
**Mantenido por:** IAA - Héctor Romero Pico  

---

*"Arquitectura simple, resultados poderosos."* 🏗️  
*AztecAI - Arquitectura Técnica* 🇲🇽

