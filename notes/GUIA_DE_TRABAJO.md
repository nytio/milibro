# Guía de trabajo (terminal) para `milibro`

Esta guía es el “camino feliz” para escribir, compilar y preparar un libro listo para publicar, manteniendo el flujo 100% desde terminal.

## 1) Dónde escribir (rutas)

- Archivo maestro (no escribas contenido aquí): `milibro.tex`
- Metadatos (título/autor/keywords): `tex/metadatos.tex`
- Configuración/paquetes: `tex/preambulo.tex`
- Portada + página legal + TOC: `tex/frontmatter.tex`
- Lista de capítulos incluidos: `tex/chapters.tex`
- Capítulos: `tex/capituloN.tex`
- Secciones finales (p.ej. bio): `tex/backmatter.tex`
- Imágenes: `img/` (siempre rutas relativas)
- Entregables: `dist/` (PDF/EPUB finales)
- Artefactos: `build/` (aux/log/intermedios)
- Notas del escritor: `notes/` (esta carpeta)

## 2) Flujo diario recomendado (pasos)

1) Crear un capítulo nuevo (opcional):
   - `make new-chapter TITLE="Título del capítulo" SLUG="mi-slug"`
   - Se crea `tex/capituloN.tex` y se agrega a `tex/chapters.tex`.
2) Preparar portada (opcional pero recomendado para eBook):
   - Coloca tu imagen en `img/portada.jpg` (o `img/portada.png`).
   - Si usas otro nombre/ruta: edita `tex/metadatos.tex` y define `\LibroPortadaArchivo` (ruta relativa).
   - Referencia rápida: `img/README.md`.
3) Escribir/editar:
   - `nano tex/capituloN.tex` o `vim tex/capituloN.tex`
4) Compilar y revisar rápidamente:
   - `make pdf OPEN_VIEWER=0`
   - `make check` (falla si hay referencias indefinidas o archivos faltantes)
5) Generar EPUB para pruebas (cuando aplique):
   - `make epub OPEN_VIEWER=0`
6) Limpiar auxiliares:
   - `make clean`

Tips:
- Si quieres recompilación automática mientras escribes: `make watch` (requiere `latexmk`).
- Mantén LaTeX “semántico” (capítulos/secciones/listas) y evita maquetación rígida si planeas EPUB.

## 3) Reglas de oro (para no romper PDF/EPUB)

- No uses rutas absolutas a imágenes. Colócalas en `img/` y referencia relativo.
- Mantén `\\label{...}` estable y con prefijos: `chap:`, `sec:`, `fig:`.
- Evita saltos de página excesivos (`\\newpage`) en contenido si tu objetivo incluye EPUB.
- No repitas preámbulo en capítulos: los `tex/capituloN.tex` deben contener solo contenido.

## 4) Herramientas y utilidades (terminal)

### Targets de `make` (atajos recomendados)

- `make pdf`: compila y deja `dist/milibro.pdf`.
- `make epub`: genera `dist/milibro.epub` (usa `tex4ebook`; si no está, intenta `pandoc`).
- `make dist`: corre `pdf` + `epub`.
- `make check`: compila y revisa problemas comunes vía el `.log` (referencias indefinidas / archivos faltantes).
- `make watch`: recompila en caliente (requiere `latexmk`).
- `make clean`: borra auxiliares y limpia `build/` (conserva `dist/`).
- `make new-chapter TITLE="..." [SLUG=...]`: crea `tex/capituloN.tex` y lo agrega a `tex/chapters.tex`.
- `make spellcheck`: lista palabras sospechosas (sin modificar archivos).
- `make languagetool`: revisión de redacción/estilo con LanguageTool local (API).

Variables comunes:
- `OPEN_VIEWER=0` desactiva abrir visor (PDF/EPUB).
- `BUILD_DIR=...` y `DIST_DIR=...` cambian carpetas de salida.
- `EPUB_FORMAT=epub3|epub2` (solo para `tex4ebook`).

### Búsquedas útiles (ripgrep)
- Encontrar etiquetas: `rg -n "\\\\label\\{chap:" tex/`
- Encontrar referencias: `rg -n "\\\\ref\\{" tex/`
- Encontrar `\\newpage`: `rg -n "\\\\newpage" tex/`

### Scripts (uso directo)

Nota: normalmente no necesitas llamar scripts a mano; `make` ya los usa. Si los llamas, ejecútalos desde la raíz del repo o deja que ellos mismos hagan `cd` (ya lo hacen).

- `scripts/build_pdf.sh [milibro.tex]`:
  - Genera `dist/milibro.pdf` (usa `latexmk` si existe, si no cae a `pdflatex`).
  - Variables: `BUILD_DIR`, `DIST_DIR`, `OPEN_VIEWER`, `MAIN_TEX`.
- `scripts/build_epub.sh [milibro.tex]`:
  - Genera `dist/milibro.epub` (preferente `tex4ebook`; fallback `pandoc`).
  - Si hay `img/portada.jpg|png`, el fallback `pandoc` la usa como cover (`--epub-cover-image`).
  - Variables: `BUILD_DIR`, `DIST_DIR`, `OPEN_VIEWER`, `MAIN_TEX`, `EPUB_FORMAT`.
- `scripts/check.sh [milibro.tex]`:
  - Corre una compilación y falla si detecta referencias indefinidas o archivos faltantes en el `.log`.
  - Variables: `BUILD_DIR`, `DIST_DIR`, `MAIN_TEX`.
- `scripts/clean.sh [milibro.tex]`:
  - Limpia `build/` y temporales típicos sin borrar `dist/`.
  - Variables: `BUILD_DIR`, `DIST_DIR`, `MAIN_TEX`.
- `scripts/new_chapter.sh "Título" [slug]`:
  - Crea el siguiente `tex/capituloN.tex` y lo agrega a `tex/chapters.tex`.
- `scripts/spellcheck.sh [--list|--check] [archivos...]`:
  - `--list` (default) imprime palabras sospechosas.
  - `--check` abre el corrector interactivo (requiere `aspell` con diccionario).
  - Variables: `FILES`, `SPELL_LANG`, `ASPELL_PERSONAL`.
- `scripts/languagetool_check.sh [archivos...]`:
  - Envía texto “limpio” (vía `detex`) a LanguageTool y muestra sugerencias con `archivo:línea:col`.
  - Variables: `FILES`, `LT_URL`, `LT_LANGUAGE`, `LT_LEVEL`, `LT_ONLY`, `LT_CONNECT_TIMEOUT`, `LT_TIMEOUT`.

Scripts internos (normalmente no se llaman a mano):
- `scripts/_common.sh` (helpers de bash).
- `scripts/flatten_tex.py` (aplana `\input/\include` para `pandoc`).
- `scripts/languagetool_prepare.py` y `scripts/languagetool_format.py` (preparan/formatean la salida de LanguageTool).

## 5) Correctores ortográficos (tips prácticos)

Objetivo: corregir el texto sin que los comandos LaTeX estorben.

## 5.1 Procedimiento recomendado (este proyecto)

Orden sugerido (rápido y repetible):

1) Asegura compilación limpia (detecta errores de LaTeX y referencias rotas):
   - `make check`
2) Revisión ortográfica (palabras mal escritas):
   - Lista de palabras sospechosas (no modifica archivos):
     - `make spellcheck`
   - Revisión interactiva (modifica el archivo si aceptas cambios):
     - `scripts/spellcheck.sh --check tex/capitulo1.tex`
3) Revisión de redacción/estilo (acuerdos, repeticiones, puntuación, etc.) con LanguageTool local:
   - `make languagetool`
   - Si quieres una revisión más estricta: `LT_LEVEL=picky make languagetool`
4) Aplica correcciones en los `.tex` (capítulos), recompila y repite:
   - `make check`

Archivos que normalmente se revisan:
- Capítulos: `tex/capitulo*.tex`
- Cierre/bio: `tex/backmatter.tex`

El objetivo es no “arreglar” LaTeX, sino el texto del libro.

Nota importante:
- `make spellcheck` usa `aspell`/`hunspell` si hay diccionarios instalados; si no, cae a LanguageTool local (requiere el servidor activo en `LT_URL`).

### Opción A (recomendada): `aspell` en modo TeX
- Revisar un capítulo:
  - `aspell --lang=es --mode=tex check tex/capitulo1.tex`
- Revisar varios archivos (uno por uno):
  - `aspell --lang=es --mode=tex check tex/capitulo2.tex`

Notas:
- `--mode=tex` hace que `aspell` ignore la mayoría de comandos.
- Si `aspell` falla diciendo que no hay diccionario para `es`, instala el diccionario (p.ej. `aspell-es`) o usa LanguageTool (sección siguiente).

### Opción B: `hunspell` en modo TeX
- `hunspell -d es_ES -t tex/capitulo1.tex`

### Gramática/estilo (opcional)
- LanguageTool puede ejecutarse localmente (sin red) si lo tienes instalado, pero no es parte del repo.
- Recomendación práctica: primero ortografía (aspell/hunspell), luego gramática (LanguageTool), y al final lectura en voz alta (detecta repeticiones).

#### LanguageTool (API local)

Este repo incluye una herramienta para consultar tu LanguageTool Server vía API:

- Endpoint por defecto: `http://localhost:8081/v2/check`
- Ejemplo mínimo (prueba manual):
  - `curl -d "language=es" -d "text=un texto de ejemplo" http://localhost:8081/v2/check`

Uso en el proyecto:
- `scripts/languagetool_check.sh` revisa por defecto `tex/capitulo*.tex` y `tex/backmatter.tex`.
- Hace una extracción de texto con `detex` antes de enviar a LanguageTool (para evitar ruido de comandos LaTeX).

Variables:
- `LT_URL` (por defecto `http://localhost:8081/v2/check`)
- `LT_LANGUAGE` (por defecto `es`)
- `LT_LEVEL` (`default` o `picky`)

Ejemplos:
- `make languagetool`
- `LT_LEVEL=picky make languagetool`
- `FILES="tex/capitulo1.tex tex/backmatter.tex" make languagetool`

## 6) “Listo para publicar de verdad” (qué completar y cómo)

### 6.1 Completar título/autor/keywords (PDF)
Edita `tex/metadatos.tex`:
- `\\LibroTitulo`: título final.
- `\\LibroSubtitulo`: subtítulo (opcional).
- `\\LibroAutor`: nombre del autor tal como aparecerá publicado.
- `\\LibroEditorial`: sello/editorial (opcional).
- `\\LibroEdicion`: texto de edición (opcional; p.ej. “Primera edición”).
- `\\LibroAsunto`: categoría/tema (breve).
- `\\LibroPalabrasClave`: palabras clave separadas por comas (sin llaves extra), por ejemplo:
  - `\\newcommand{\\LibroPalabrasClave}{novela, historia, México, siglo XIX}`

Esto alimenta los metadatos PDF vía `hyperref` en `milibro.tex`.

### 6.2 Completar metadatos para EPUB (pandoc fallback)
Edita `metadata.yaml`:
- `title`: título final.
- `subtitle`: subtítulo (opcional).
- `author`: autor.
- `language`: `es`.
- `subject`: tema/categoría.
- `keywords`: lista YAML, por ejemplo:
  - `keywords: ["novela", "historia", "México", "siglo XIX"]`

Notas:
- Si tu EPUB se genera con `tex4ebook`, sus metadatos vienen más de LaTeX/TeX4ht; `metadata.yaml` se usa principalmente cuando el script cae a `pandoc`.

### 6.3 Ajustar página legal (copyright/ISBN/derechos)
Edita `tex/metadatos.tex` (recomendado) y/o `tex/frontmatter.tex`:
- Lo normal es completar campos en `tex/metadatos.tex` (año, derechos, ISBN, contacto) y dejar `tex/frontmatter.tex` como plantilla.

Contenido típico de una página legal (depende del país/editorial):
- Año y titular de derechos: `© 2026 Nombre del autor`
- Reservas de derechos / licencia (p.ej. “Todos los derechos reservados” o Creative Commons)
- ISBN (si aplica) para tapa blanda/ebook (suelen ser distintos)
- Edición/impresión (p.ej. “Primera edición”)
- Créditos (portada, edición, corrección, ilustraciones)
- Avisos (p.ej. “Cualquier semejanza…”, “Este libro es ficción…”, etc.) si aplica
- Contacto (web/correo) si lo deseas

Tip:
- Mantén la página legal simple y sin enlaces llamativos (por eso `hidelinks`).

### 6.4 Portada, ISBN y derechos (entregables fuera del texto)
Este repo genera interior (PDF) y un EPUB de lectura; la portada suele ser un entregable aparte.

- Portada (imagen en el interior/EPUB):
  - Coloca `img/portada.jpg` (recomendado) o `img/portada.png`; también soporta `img/portada.pdf`.
  - Si usas otro nombre, define `\LibroPortadaArchivo` en `tex/metadatos.tex` (ruta relativa).
  - En PDF: se inserta como primera página a página completa (si existe).
  - En EPUB:
    - Con `tex4ebook`: queda incluida como primera página del libro.
    - Con `pandoc`: se usa además como cover del EPUB (`--epub-cover-image`) cuando existe `img/portada.jpg|png`.
  - Notas prácticas: ver `img/README.md`.
- Portada (impreso):
  - Normalmente se entrega como archivo independiente (PDF/JPG) con dimensiones exactas + lomo según número de páginas y papel.
  - Usa el “cover calculator”/plantilla del proveedor (p.ej. KDP) para fijar tamaño final.
- ISBN:
  - Según plataforma, puede ser provisto por la plataforma o propio; confirma antes.
  - Suele haber ISBN distinto para tapa blanda vs eBook.
- Derechos/licencia:
  - Define si será “todos los derechos reservados” o una licencia abierta.
  - Si incluyes imágenes/quotes, documenta permisos/fuentes.

Checklist técnico complementario:
- `docs/PUBLICACION.md`
Nota:
- `hunspell` necesita un diccionario instalado (p.ej. `es_ES`). Si no lo tienes, usa LanguageTool.
