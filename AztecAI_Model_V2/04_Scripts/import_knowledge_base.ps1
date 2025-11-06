################################################################################
# Script de Importación de Knowledge Base para AztecAI (PowerShell)
################################################################################
#
# Este script ayuda a verificar y preparar los archivos de Knowledge Base
# para su importación en OpenWebUI.
#
# Autor: IAA - Inteligencia Artificial Azteca
# Versión: 1.0.0
# Fecha: 2025-01-06
#
################################################################################

# Configuración
$KB_DIR = "..\03_Knowledge_Base"
$KB_FILES = @(
    "AztecAI_Complete_Knowledge_Base.md",
    "TV_Azteca_Informacion_Corporativa.md",
    "Funcionamiento TV Aztec.md"
)

################################################################################
# Funciones de Utilidad
################################################################################

function Print-Header {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Blue
    Write-Host $Message -ForegroundColor Blue
    Write-Host "========================================`n" -ForegroundColor Blue
}

function Print-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Print-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Print-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Print-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

################################################################################
# Funciones Principales
################################################################################

function Check-Files {
    Print-Header "Verificando Archivos de Knowledge Base"
    
    $allFound = $true
    
    foreach ($file in $KB_FILES) {
        $filepath = Join-Path $KB_DIR $file
        
        if (Test-Path $filepath) {
            $fileInfo = Get-Item $filepath
            $sizeKB = [math]::Round($fileInfo.Length / 1KB, 2)
            $lines = (Get-Content $filepath | Measure-Object -Line).Lines
            
            Print-Success "Encontrado: $file"
            Write-Host "           Tamaño: $sizeKB KB | Líneas: $lines"
        }
        else {
            Print-Error "No encontrado: $file"
            $allFound = $false
        }
    }
    
    Write-Host ""
    
    if ($allFound) {
        Print-Success "Todos los archivos de Knowledge Base están presentes"
        return $true
    }
    else {
        Print-Error "Faltan archivos de Knowledge Base"
        return $false
    }
}

function Show-FileInfo {
    Print-Header "Información de los Archivos"
    
    Write-Host "1. AztecAI_Complete_Knowledge_Base.md" -ForegroundColor Blue
    Write-Host "   • System prompt completo con identidad y guardrails"
    Write-Host "   • Base principal del comportamiento del asistente"
    Write-Host "   • Contiene framework operativo y plantillas de respuesta"
    Write-Host ""
    
    Write-Host "2. TV_Azteca_Informacion_Corporativa.md" -ForegroundColor Blue
    Write-Host "   • Información corporativa detallada de TV Azteca"
    Write-Host "   • Estructura organizacional y áreas funcionales"
    Write-Host "   • Procesos, políticas y procedimientos internos"
    Write-Host ""
    
    Write-Host "3. Funcionamiento TV Aztec.md" -ForegroundColor Blue
    Write-Host "   • Guía operativa de TV Azteca"
    Write-Host "   • Descripción de canales y programación"
    Write-Host "   • Áreas, clientes y flujos de trabajo"
    Write-Host ""
}

function Show-ImportInstructions {
    Print-Header "Instrucciones de Importación"
    
    Write-Host "Pasos para importar en OpenWebUI:`n" -ForegroundColor Yellow
    
    Write-Host "1. Acceder a OpenWebUI"
    Write-Host "   → Abrir navegador: http://localhost:3000"
    Write-Host "   → Login con tu cuenta de administrador"
    Write-Host ""
    
    Write-Host "2. Ir a Workspace → Documents"
    Write-Host "   → Click en el menú lateral"
    Write-Host "   → Seleccionar 'Workspace'"
    Write-Host "   → Click en 'Documents'"
    Write-Host ""
    
    Write-Host "3. Subir los archivos"
    Write-Host "   → Click en '+ Upload Document'"
    Write-Host "   → Seleccionar los 3 archivos:"
    foreach ($file in $KB_FILES) {
        $fullPath = Join-Path (Resolve-Path $KB_DIR) $file
        Write-Host "     • $fullPath"
    }
    Write-Host "   → Esperar a que termine la carga"
    Write-Host ""
    
    Write-Host "4. Crear Collection"
    Write-Host "   → Ir a Settings → RAG"
    Write-Host "   → Click en 'Collections'"
    Write-Host "   → Click en 'Create Collection'"
    Write-Host "   → Nombre: AztecAI"
    Write-Host "   → Save"
    Write-Host ""
    
    Write-Host "5. Agregar documentos a Collection"
    Write-Host "   → Volver a Workspace → Documents"
    Write-Host "   → Seleccionar los 3 archivos (checkbox)"
    Write-Host "   → Click en 'Add to Collection'"
    Write-Host "   → Seleccionar 'AztecAI'"
    Write-Host "   → Confirm"
    Write-Host ""
    
    Write-Host "6. Configurar RAG"
    Write-Host "   → Settings → RAG"
    Write-Host "   → Top-K: 5"
    Write-Host "   → Chunk Size: 1500"
    Write-Host "   → Chunk Overlap: 150"
    Write-Host "   → Toggle 'RAG Enabled': ON"
    Write-Host "   → Save"
    Write-Host ""
    
    Write-Host "7. Verificar Embeddings"
    Write-Host "   → Workspace → Documents"
    Write-Host "   → Los 3 archivos deben mostrar estado 'Embedded'"
    Write-Host "   → Tiempo estimado: 2-5 minutos"
    Write-Host ""
    
    Print-Success "Una vez completados estos pasos, el RAG estará activo"
}

function Copy-FilesToTemp {
    Print-Header "Copiando Archivos a Directorio Temporal"
    
    $tempDir = Join-Path $env:TEMP "aztecai_kb_import"
    
    # Crear directorio temporal
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir | Out-Null
    }
    
    # Copiar archivos
    foreach ($file in $KB_FILES) {
        $source = Join-Path $KB_DIR $file
        $dest = Join-Path $tempDir $file
        
        if (Test-Path $source) {
            Copy-Item $source $dest -Force
            Print-Success "Copiado: $file → $tempDir\"
        }
        else {
            Print-Error "No se pudo copiar: $file"
        }
    }
    
    Write-Host ""
    Print-Info "Archivos copiados a: $tempDir"
    Print-Info "Puedes importarlos desde esta ubicación en OpenWebUI"
    
    # Abrir explorador de archivos
    $response = Read-Host "`n¿Deseas abrir el explorador de archivos? (S/N)"
    if ($response -eq "S" -or $response -eq "s") {
        Start-Process explorer.exe $tempDir
    }
}

function Show-VerificationTests {
    Print-Header "Tests de Verificación Post-Importación"
    
    Write-Host "Prueba estas preguntas para verificar el RAG:`n" -ForegroundColor Yellow
    
    Write-Host "1. Test de Canales:"
    Write-Host "   Pregunta: '¿Qué canales tiene TV Azteca?'"
    Write-Host "   Esperado: Debe mencionar Azteca Uno, Azteca 7, ADN Noticias y a más+"
    Write-Host ""
    
    Write-Host "2. Test de Identidad:"
    Write-Host "   Pregunta: '¿Quién eres?'"
    Write-Host "   Esperado: Debe identificarse como AztecAI, asistente de TV Azteca"
    Write-Host ""
    
    Write-Host "3. Test de Áreas:"
    Write-Host "   Pregunta: '¿Qué hace el área de Ventas?'"
    Write-Host "   Esperado: Debe explicar Ventas Nacional y Ventas Digital"
    Write-Host ""
    
    Write-Host "4. Test de Guardrails:"
    Write-Host "   Pregunta: '¿Puedes ayudarme con mi tarea de matemáticas?'"
    Write-Host "   Esperado: Debe declinar educadamente (fuera de alcance)"
    Write-Host ""
    
    Print-Info "Si todas las respuestas son correctas, el RAG está funcionando"
}

function Show-Menu {
    Clear-Host
    Print-Header "Script de Importación de Knowledge Base - AztecAI"
    
    Write-Host "Selecciona una opción:"
    Write-Host ""
    Write-Host "  1) Verificar archivos de Knowledge Base"
    Write-Host "  2) Mostrar información de los archivos"
    Write-Host "  3) Mostrar instrucciones de importación"
    Write-Host "  4) Copiar archivos a directorio temporal"
    Write-Host "  5) Mostrar tests de verificación"
    Write-Host "  6) Ejecutar todo (verificar + instrucciones)"
    Write-Host "  0) Salir"
    Write-Host ""
    $option = Read-Host "Opción"
    
    return $option
}

################################################################################
# Main
################################################################################

function Main {
    while ($true) {
        $option = Show-Menu
        
        switch ($option) {
            "1" {
                Check-Files
            }
            "2" {
                Show-FileInfo
            }
            "3" {
                Show-ImportInstructions
            }
            "4" {
                Copy-FilesToTemp
            }
            "5" {
                Show-VerificationTests
            }
            "6" {
                $result = Check-Files
                if ($result) {
                    Show-FileInfo
                    Show-ImportInstructions
                    Show-VerificationTests
                }
            }
            "0" {
                Print-Info "Saliendo..."
                exit 0
            }
            default {
                Print-Error "Opción inválida"
            }
        }
        
        Write-Host ""
        Write-Host "Presiona Enter para continuar..." -ForegroundColor Blue
        Read-Host
    }
}

# Ejecutar
Main

