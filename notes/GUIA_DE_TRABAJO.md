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
2) Escribir/editar:
   - `nano tex/capituloN.tex` o `vim tex/capituloN.tex`
3) Compilar y revisar rápidamente:
   - `make pdf OPEN_VIEWER=0`
   - `make check` (falla si hay referencias indefinidas o archivos faltantes)
4) Generar EPUB para pruebas (cuando aplique):
   - `make epub OPEN_VIEWER=0`
5) Limpiar auxiliares:
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

### Compilación
- `make pdf`: compila y deja `dist/milibro.pdf`.
- `make check`: compila y revisa problemas comunes vía el `.log`.
- `make clean`: borra auxiliares (conserva `dist/`).

### Búsquedas útiles (ripgrep)
- Encontrar etiquetas: `rg -n "\\\\label\\{chap:" tex/`
- Encontrar referencias: `rg -n "\\\\ref\\{" tex/`
- Encontrar `\\newpage`: `rg -n "\\\\newpage" tex/`

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
- `\\LibroAutor`: nombre del autor tal como aparecerá publicado.
- `\\LibroAsunto`: categoría/tema (breve).
- `\\LibroPalabrasClave`: palabras clave separadas por comas (sin llaves extra), por ejemplo:
  - `\\newcommand{\\LibroPalabrasClave}{novela, historia, México, siglo XIX}`

Esto alimenta los metadatos PDF vía `hyperref` en `milibro.tex`.

### 6.2 Completar metadatos para EPUB (pandoc fallback)
Edita `metadata.yaml`:
- `title`: título final.
- `author`: autor.
- `language`: `es`.
- `subject`: tema/categoría.
- `keywords`: lista YAML, por ejemplo:
  - `keywords: ["novela", "historia", "México", "siglo XIX"]`

Notas:
- Si tu EPUB se genera con `tex4ebook`, sus metadatos vienen más de LaTeX/TeX4ht; `metadata.yaml` se usa principalmente cuando el script cae a `pandoc`.

### 6.3 Ajustar página legal (copyright/ISBN/derechos)
Edita `tex/frontmatter.tex` y reemplaza la sección “Todos los derechos reservados” por tu texto final.

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
