# ═══════════════════════════════════════════════════════════════════════════════
# SCRIPT DE CREACIÓN AUTOMÁTICA - AZTECAI CON DOCUMENTOS
# ═══════════════════════════════════════════════════════════════════════════════
# Versión: 1.0.0
# Fecha: 2026-01-27
# Organización: TV Azteca / Grupo Salinas
# CAIO: Héctor Romero Pico
# ═══════════════════════════════════════════════════════════════════════════════

# Configuración de encoding UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Write-Host "═══════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  AZTECAI - CREACIÓN AUTOMÁTICA DE MODELO CON DOCUMENTOS CORPORATIVOS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# ═══════════════════════════════════════════════════════════════════════════════
# PASO 1: VERIFICAR ARCHIVOS NECESARIOS
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host "[1/6] Verificando archivos necesarios..." -ForegroundColor Yellow

$archivosRequeridos = @(
    "Modelfile.AztecAI.optimized",
    "Funcionamiento_tv_azteca.md",
    "Empresas_del_grupo.md",
    "Capital_Humano_e_historia.md"
)

$todosExisten = $true
foreach ($archivo in $archivosRequeridos) {
    if (Test-Path $archivo) {
        Write-Host "  ✓ $archivo" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $archivo - NO ENCONTRADO" -ForegroundColor Red
        $todosExisten = $false
    }
}

if (-not $todosExisten) {
    Write-Host ""
    Write-Host "ERROR: Faltan archivos necesarios. Verifica que estés en el directorio correcto." -ForegroundColor Red
    exit 1
}

Write-Host "  ✓ Todos los archivos encontrados" -ForegroundColor Green
Write-Host ""

# ═══════════════════════════════════════════════════════════════════════════════
# PASO 2: VERIFICAR OLLAMA
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host "[2/6] Verificando instalación de Ollama..." -ForegroundColor Yellow

try {
    $ollamaVersion = ollama --version 2>&1
    Write-Host "  ✓ Ollama instalado: $ollamaVersion" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Ollama no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "  Descarga Ollama desde: https://ollama.ai/download" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# ═══════════════════════════════════════════════════════════════════════════════
# PASO 3: LEER ARCHIVOS
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host "[3/6] Leyendo archivos..." -ForegroundColor Yellow

try {
    $modelfileBase = Get-Content "Modelfile.AztecAI.optimized" -Raw -Encoding UTF8
    Write-Host "  ✓ Modelfile.AztecAI.optimized ($(($modelfileBase -split "`n").Count) líneas)" -ForegroundColor Green
    
    $doc1 = Get-Content "Funcionamiento_tv_azteca.md" -Raw -Encoding UTF8
    Write-Host "  ✓ Funcionamiento_tv_azteca.md ($(($doc1 -split "`n").Count) líneas)" -ForegroundColor Green
    
    $doc2 = Get-Content "Empresas_del_grupo.md" -Raw -Encoding UTF8
    Write-Host "  ✓ Empresas_del_grupo.md ($(($doc2 -split "`n").Count) líneas)" -ForegroundColor Green
    
    $doc3 = Get-Content "Capital_Humano_e_historia.md" -Raw -Encoding UTF8
    Write-Host "  ✓ Capital_Humano_e_historia.md ($(($doc3 -split "`n").Count) líneas)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Error al leer archivos: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ═══════════════════════════════════════════════════════════════════════════════
# PASO 4: CONSTRUIR MODELFILE COMPLETO
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host "[4/6] Construyendo Modelfile completo con documentos..." -ForegroundColor Yellow

# Construir el Modelfile completo
$modelfileCompleto = $modelfileBase

# Agregar separador
$modelfileCompleto += "`n`n"
$modelfileCompleto += "# ═══════════════════════════════════════════════════════════════════════════════`n"
$modelfileCompleto += "# DOCUMENTOS CORPORATIVOS CARGADOS`n"
$modelfileCompleto += "# ═══════════════════════════════════════════════════════════════════════════════`n"
$modelfileCompleto += "`n"

# Documento 1: Funcionamiento de TV Azteca
$modelfileCompleto += "MESSAGE system `"`"`"`n"
$modelfileCompleto += "═══════════════════════════════════════════════════════════════════════════════`n"
$modelfileCompleto += "DOCUMENTO 1: FUNCIONAMIENTO DE TV AZTECA`n"
$modelfileCompleto += "═══════════════════════════════════════════════════════════════════════════════`n"
$modelfileCompleto += "`n"
$modelfileCompleto += $doc1
$modelfileCompleto += "`n`"`"`"`n`n"

# Documento 2: Empresas del Grupo
$modelfileCompleto += "MESSAGE system `"`"`"`n"
$modelfileCompleto += "═══════════════════════════════════════════════════════════════════════════════`n"
$modelfileCompleto += "DOCUMENTO 2: EMPRESAS DE GRUPO SALINAS`n"
$modelfileCompleto += "═══════════════════════════════════════════════════════════════════════════════`n"
$modelfileCompleto += "`n"
$modelfileCompleto += $doc2
$modelfileCompleto += "`n`"`"`"`n`n"

# Documento 3: Capital Humano e Historia
$modelfileCompleto += "MESSAGE system `"`"`"`n"
$modelfileCompleto += "═══════════════════════════════════════════════════════════════════════════════`n"
$modelfileCompleto += "DOCUMENTO 3: CAPITAL HUMANO E HISTORIA DE TV AZTECA`n"
$modelfileCompleto += "═══════════════════════════════════════════════════════════════════════════════`n"
$modelfileCompleto += "`n"
$modelfileCompleto += $doc3
$modelfileCompleto += "`n`"`"`"`n"

# Guardar archivo
try {
    $modelfileCompleto | Out-File "Modelfile.AztecAI.full" -Encoding UTF8 -NoNewline
    $lineasTotales = ($modelfileCompleto -split "`n").Count
    Write-Host "  ✓ Modelfile.AztecAI.full creado ($lineasTotales líneas)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Error al guardar Modelfile: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ═══════════════════════════════════════════════════════════════════════════════
# PASO 5: CREAR MODELO EN OLLAMA
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host "[5/6] Creando modelo en Ollama..." -ForegroundColor Yellow
Write-Host "  Esto puede tomar varios minutos..." -ForegroundColor Gray
Write-Host ""

try {
    $output = ollama create aztecai:full -f Modelfile.AztecAI.full 2>&1
    Write-Host $output
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "  ✓ Modelo 'aztecai:full' creado exitosamente" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "  ✗ Error al crear el modelo" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  ✗ Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# ═══════════════════════════════════════════════════════════════════════════════
# PASO 6: TEST RÁPIDO
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host "[6/6] Ejecutando test rápido..." -ForegroundColor Yellow
Write-Host ""

$testPrompt = "¿Quién eres? Responde en máximo 3 líneas."

Write-Host "  Pregunta: $testPrompt" -ForegroundColor Cyan
Write-Host "  Respuesta:" -ForegroundColor Cyan
Write-Host ""

try {
    ollama run aztecai:full $testPrompt
} catch {
    Write-Host "  ⚠ No se pudo ejecutar el test, pero el modelo fue creado" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✓ PROCESO COMPLETADO EXITOSAMENTE" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Modelo creado: " -NoNewline
Write-Host "aztecai:full" -ForegroundColor Yellow
Write-Host ""
Write-Host "Para usar el modelo:" -ForegroundColor Cyan
Write-Host "  ollama run aztecai:full" -ForegroundColor White
Write-Host ""
Write-Host "Para ver información del modelo:" -ForegroundColor Cyan
Write-Host "  ollama show aztecai:full" -ForegroundColor White
Write-Host ""
Write-Host "Para listar todos tus modelos:" -ForegroundColor Cyan
Write-Host "  ollama list" -ForegroundColor White
Write-Host ""

