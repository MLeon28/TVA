#!/usr/bin/env python3
"""
Preparador de Knowledge Base para OpenWebUI
=============================================

Este script prepara el system prompt completo de AztecAI para ser usado
como Knowledge Base en OpenWebUI, dividiéndolo en chunks optimizados.

Autor: IAA - Inteligencia Artificial Azteca
Versión: 1.0.0
Fecha: 2025-10-31
"""

import os
import json
import re
from pathlib import Path
from typing import List, Dict
import hashlib


class KnowledgeBasePreparator:
    """Prepara documentos para Knowledge Base de OpenWebUI"""
    
    def __init__(self, source_file: str, output_dir: str = "knowledge_base"):
        self.source_file = Path(source_file)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        
    def read_source(self) -> str:
        """Lee el archivo fuente"""
        with open(self.source_file, 'r', encoding='utf-8') as f:
            return f.read()
    
    def extract_sections(self, content: str) -> List[Dict[str, str]]:
        """
        Extrae secciones del markdown basado en headers ##
        Cada sección se convierte en un documento separado para mejor retrieval
        """
        sections = []
        
        # Patrón para capturar secciones con ##
        pattern = r'^## (\d+\.)?\s*(.+?)$'
        
        lines = content.split('\n')
        current_section = None
        current_content = []
        current_title = ""
        
        for line in lines:
            match = re.match(pattern, line)
            
            if match:
                # Guardar sección anterior si existe
                if current_title:
                    sections.append({
                        'title': current_title,
                        'content': '\n'.join(current_content).strip(),
                        'id': self._generate_id(current_title)
                    })
                
                # Iniciar nueva sección
                current_title = match.group(2).strip()
                current_content = [line]
            else:
                if current_title:  # Solo agregar si ya empezamos una sección
                    current_content.append(line)
        
        # Agregar última sección
        if current_title:
            sections.append({
                'title': current_title,
                'content': '\n'.join(current_content).strip(),
                'id': self._generate_id(current_title)
            })
        
        return sections
    
    def _generate_id(self, title: str) -> str:
        """Genera un ID único basado en el título"""
        return hashlib.md5(title.encode()).hexdigest()[:12]
    
    def create_metadata_file(self, sections: List[Dict]) -> None:
        """Crea archivo de metadatos para OpenWebUI"""
        metadata = {
            'name': 'AztecAI System Prompt v2.0',
            'description': 'Documentación completa del asistente corporativo AztecAI',
            'version': '2.0.0',
            'created_date': '2025-10-31',
            'owner': 'Inteligencia Artificial Azteca (IAA)',
            'caio': 'Héctor Romero Pico',
            'sections_count': len(sections),
            'sections': [
                {
                    'id': sec['id'],
                    'title': sec['title'],
                    'length': len(sec['content'])
                }
                for sec in sections
            ]
        }
        
        output_file = self.output_dir / 'metadata.json'
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Metadata creado: {output_file}")
    
    def save_sections_as_individual_files(self, sections: List[Dict]) -> None:
        """
        Guarda cada sección como un archivo markdown individual.
        Este formato es óptimo para OpenWebUI Knowledge Base.
        """
        sections_dir = self.output_dir / 'sections'
        sections_dir.mkdir(exist_ok=True)
        
        for i, section in enumerate(sections, 1):
            # Crear nombre de archivo limpio
            safe_title = re.sub(r'[^\w\s-]', '', section['title'])
            safe_title = re.sub(r'[-\s]+', '_', safe_title)
            filename = f"{i:02d}_{safe_title[:50]}.md"
            
            filepath = sections_dir / filename
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(f"# {section['title']}\n\n")
                f.write(f"**ID:** `{section['id']}`\n\n")
                f.write("---\n\n")
                f.write(section['content'])
            
            print(f"✅ Sección guardada: {filename}")
    
    def create_combined_file(self, sections: List[Dict]) -> None:
        """Crea un archivo combinado con todas las secciones"""
        output_file = self.output_dir / 'AztecAI_Complete_Knowledge_Base.md'
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("# AztecAI System Prompt v2.0 - Knowledge Base Completa\n\n")
            f.write("**Versión:** 2.0.0  \n")
            f.write("**Fecha:** 2025-10-31  \n")
            f.write("**Owner:** Inteligencia Artificial Azteca (IAA)  \n")
            f.write("**CAIO:** Héctor Romero Pico  \n\n")
            f.write("---\n\n")
            f.write("## Tabla de Contenidos\n\n")
            
            # Generar tabla de contenidos
            for i, section in enumerate(sections, 1):
                f.write(f"{i}. [{section['title']}](#{section['id']})\n")
            
            f.write("\n---\n\n")
            
            # Escribir todas las secciones
            for section in sections:
                f.write(f"<a id='{section['id']}'></a>\n\n")
                f.write(section['content'])
                f.write("\n\n---\n\n")
        
        print(f"✅ Archivo combinado creado: {output_file}")
    
    def create_jsonl_for_embeddings(self, sections: List[Dict]) -> None:
        """
        Crea archivo JSONL para crear embeddings (si OpenWebUI lo soporta)
        Este formato es útil para algunos sistemas de RAG
        """
        output_file = self.output_dir / 'embeddings.jsonl'
        
        with open(output_file, 'w', encoding='utf-8') as f:
            for section in sections:
                doc = {
                    'id': section['id'],
                    'title': section['title'],
                    'content': section['content'],
                    'metadata': {
                        'source': 'AztecAI System Prompt',
                        'version': '2.0.0',
                        'type': 'documentation'
                    }
                }
                f.write(json.dumps(doc, ensure_ascii=False) + '\n')
        
        print(f"✅ Archivo JSONL creado: {output_file}")
    
    def generate_summary(self, sections: List[Dict]) -> None:
        """Genera un resumen de estadísticas"""
        total_chars = sum(len(sec['content']) for sec in sections)
        total_words = sum(len(sec['content'].split()) for sec in sections)
        
        summary = f"""
╔══════════════════════════════════════════════════════════════╗
║          AztecAI Knowledge Base - Resumen de Proceso         ║
╚══════════════════════════════════════════════════════════════╝

📊 ESTADÍSTICAS:
   • Secciones procesadas: {len(sections)}
   • Total de caracteres: {total_chars:,}
   • Total de palabras: {total_words:,}
   • Promedio por sección: {total_chars // len(sections):,} caracteres

📁 ARCHIVOS GENERADOS:
   • metadata.json              → Metadatos del knowledge base
   • sections/*.md              → {len(sections)} archivos individuales
   • AztecAI_Complete_KB.md     → Documento combinado
   • embeddings.jsonl           → Formato para embeddings

✅ SIGUIENTE PASO:
   1. Importar los archivos a OpenWebUI (Workspace → Documents)
   2. Crear un nuevo modelo con el Modelfile.AztecAI
   3. Configurar el modelo para usar el Knowledge Base
   
📖 Ver guía completa en: GUIA_INSTALACION_OWUI.md

        """
        
        print(summary)
        
        # Guardar resumen
        summary_file = self.output_dir / 'RESUMEN.txt'
        with open(summary_file, 'w', encoding='utf-8') as f:
            f.write(summary)
    
    def process(self) -> None:
        """Ejecuta el proceso completo"""
        print("\n🚀 Iniciando preparación de Knowledge Base...\n")
        
        # Leer contenido
        print("📖 Leyendo archivo fuente...")
        content = self.read_source()
        print(f"✅ Archivo leído: {len(content)} caracteres\n")
        
        # Extraer secciones
        print("🔍 Extrayendo secciones...")
        sections = self.extract_sections(content)
        print(f"✅ {len(sections)} secciones encontradas\n")
        
        # Generar archivos
        print("📝 Generando archivos...\n")
        self.create_metadata_file(sections)
        self.save_sections_as_individual_files(sections)
        self.create_combined_file(sections)
        self.create_jsonl_for_embeddings(sections)
        
        # Resumen final
        print("\n")
        self.generate_summary(sections)


def main():
    """Función principal"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description='Prepara el System Prompt de AztecAI para OpenWebUI Knowledge Base',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos de uso:
  
  # Procesar el system prompt de AztecAI
  python prepare_knowledge_base.py
  
  # Especificar archivo y directorio de salida
  python prepare_knowledge_base.py --input custom.md --output mi_kb/
  
Después de ejecutar, importa los archivos generados a OpenWebUI.
        """
    )
    
    parser.add_argument(
        '--input', '-i',
        default='AztecAI_SystemPrompt_V2_Professional.md',
        help='Archivo markdown de entrada (default: AztecAI_SystemPrompt_V2_Professional.md)'
    )
    
    parser.add_argument(
        '--output', '-o',
        default='knowledge_base',
        help='Directorio de salida (default: knowledge_base/)'
    )
    
    args = parser.parse_args()
    
    # Verificar que el archivo existe
    if not Path(args.input).exists():
        print(f"❌ Error: No se encuentra el archivo: {args.input}")
        print(f"\n💡 Asegúrate de que el archivo existe en la ruta especificada.")
        return 1
    
    # Procesar
    preparator = KnowledgeBasePreparator(args.input, args.output)
    preparator.process()
    
    return 0


if __name__ == '__main__':
    exit(main())

