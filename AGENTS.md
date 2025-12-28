# AGENTS.md — Guía operativa para Codex (milibro)

Este repositorio tiene como finalidad materializar el flujo descrito en `Escribir un libro con LaTeX en Ubuntu desde la terminal.pdf`: escribir un libro en LaTeX **desde la terminal** (Ubuntu), compilar a **PDF** y, cuando se requiera, convertir a **EPUB** para Kindle/KDP, con posibilidad de automatizar tareas mediante scripts/Makefile.

## Prioridades del agente

1. Mantener el flujo 100% terminal (edición, compilación, conversión, verificación).
2. Favorecer una estructura modular (un archivo `.tex` maestro + capítulos en archivos separados).
3. Asegurar compatibilidad con español (UTF‑8, separación silábica, encabezados “Capítulo”, etc.).
4. Hacer reproducibles las tareas (comandos documentados + `make`/scripts cuando aporte valor).
5. Evitar decisiones irreversibles sin pedir confirmación (instalación de paquetes, cambios de estructura).

## Lectura del objetivo (el PDF)

Cuando el usuario pida “seguir el documento” o “hacer el proyecto”, toma este PDF como fuente de verdad:
- Instalación: TeX Live (preferente `texlive-full`) y visor PDF (Evince/Okular).
- Edición: archivos de texto plano `.tex` en editor de terminal (p.ej. nano).
- Estructura: carpeta de proyecto con subcarpetas `tex/` (capítulos) e `img/` (imágenes) y un maestro `milibro.tex`.
- Contenido: `\chapter`, `\section`, `\tableofcontents`, `\label`/`\ref`, `graphicx` para imágenes; notas con `\footnote` si no hay bibliografía.
- Compilación PDF: `pdflatex` (mínimo 2 pasadas) o `latexmk -pdf` para automatizar.
- EPUB: opción 1 `pandoc`; opción 2 `tex4ebook` (preferible si hay elementos complejos).
- Automatización: scripts bash o `Makefile` con targets `pdf`, `epub`, `clean`.

## Convenciones del proyecto (qué debe crear/modificar Codex)

Si el repo aún no tiene estructura LaTeX, propón (y luego aplica) esta estructura mínima:
- `milibro.tex` (archivo maestro).
- `tex/` (capítulos: `capitulo1.tex`, `capitulo2.tex`, …).
- `img/` (recursos gráficos referenciados con rutas relativas).
- Opcional: `build/` para artefactos (`latexmk -outdir=build`) y `dist/` para entregables finales.

Reglas:
- No usar rutas absolutas a imágenes; siempre relativas dentro del repo (evita roturas al convertir a EPUB o empaquetar).
- Mantener nombres de `\label{...}` estables y con prefijos (`chap:`, `sec:`, `fig:`).
- Para español, incluir (si se usa PDFLaTeX):
  - `\usepackage[utf8]{inputenc}`
  - `\usepackage[T1]{fontenc}`
  - `\usepackage[spanish]{babel}`
  - `\usepackage{graphicx}`
  - Nota: si el usuario decide usar XeLaTeX/LuaLaTeX, **no** usar `inputenc` y ajustar fuentes con `fontspec`.

## Flujo de trabajo recomendado (terminal)

### Edición
- Edita `.tex` con herramientas CLI (nano/vim/emacs) según preferencia del usuario.
- Al crear capítulos, dividir por archivos y ensamblar en `milibro.tex` con `\include{tex/capitulo1}` (o `\input` si conviene insertar sin saltos).

### Compilación a PDF
- Preferido (automático): `latexmk -pdf milibro.tex`.
- Alternativa (manual): `pdflatex milibro.tex` dos veces.
- Para diagnósticos, usar opciones que mejoren errores: `-file-line-error -halt-on-error`.

Si se agregan índices (`makeidx`) o bibliografía (BibTeX/Biber), actualizar el flujo de compilación (latexmk suele manejarlo).

### Conversión a EPUB
Mantener el LaTeX “semántico” y simple para eBooks (evitar posicionamiento absoluto y espaciados forzados).

Opciones:
- `pandoc -s -o milibro.epub milibro.tex` (añadir `--toc` si se requiere TOC explícito).
- `tex4ebook milibro.tex` (tiende a preservar más características; genera temporales adicionales).

Después de generar EPUB:
- Probar en un lector (p.ej. FBReader) o en el previewer de KDP/Kindle fuera del repo.
- Iterar: EPUB no tiene páginas fijas; el layout puede variar por dispositivo.

## Automatización (cuando valga la pena)

Si el usuario lo solicita o el proyecto ya está en marcha, proponer:
- `Makefile` con targets: `pdf`, `epub`, `clean` (y opcional `watch` si se desea).
- Scripts `./scripts/compilar_pdf.sh` y `./scripts/compilar_epub.sh` cuando el usuario prefiera bash.

`clean` debe eliminar auxiliares típicos (`*.aux`, `*.log`, `*.toc`, `*.out`, `*.fls`, `*.fdb_latexmk`, `*.xml`, `*.html`, `*.css`, `*.4ct`, `*.4tc`, `*.tmp`, `*.xref`, etc.) y respetar `build/` si se usa.

## Verificación y checklist antes de entregar

- `\tableofcontents` aparece y se actualiza (compilar las pasadas necesarias).
- `\ref`/`\pageref` no quedan como “??” (referencias resueltas).
- No hay imágenes faltantes (rutas correctas dentro de `img/`).
- PDF abre correctamente en un visor local.
- EPUB se visualiza razonablemente (capítulos navegables, imágenes incluidas).

## Política de comandos con privilegios/red

En este entorno, el acceso de red puede estar restringido y ciertos comandos requieren aprobación.
- **No** ejecutar `sudo apt install ...` ni descargas sin que el usuario lo pida explícitamente.
- Si el usuario pide instalación (TeX Live, latexmk, pandoc, tex4ebook, visor), proporcionar comandos exactos y preguntar antes de ejecutarlos.

## Cómo debe actuar Codex ante tareas típicas

- “Crea el esqueleto del libro”: generar estructura (`milibro.tex`, `tex/`, `img/`) + un capítulo de ejemplo, TOC y paquetes base.
- “Añade un capítulo”: crear `tex/capituloN.tex`, incluirlo en `milibro.tex`, añadir `\label{chap:...}`.
- “Inserta una imagen”: ubicar archivo en `img/`, incluir con `graphicx`, `figure`, `\caption` y `\label`.
- “Referenciar secciones/figuras”: usar `\label` justo tras el título o tras `\caption`, y `\ref` en el texto.
- “Generar PDF/EPUB”: usar `latexmk`/`pdflatex` y `tex4ebook`/`pandoc` según lo acordado; registrar errores relevantes del log y proponer correcciones.

