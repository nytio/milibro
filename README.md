# milibro

Proyecto para escribir un libro en **LaTeX** en **Ubuntu desde la terminal**, generando un **PDF** (pensado para KDP/impresión) y un **EPUB** (para Kindle/KDP) con un flujo reproducible vía `make`.

La guía de trabajo del agente está en [`AGENTS.md`](AGENTS.md) y el documento objetivo/base está en [`Escribir un libro con LaTeX en Ubuntu desde la terminal.pdf`](Escribir%20un%20libro%20con%20LaTeX%20en%20Ubuntu%20desde%20la%20terminal.pdf).

## Inicio rápido

1) Crear un libro en edición (privado, ignorado por git):
   - `make new-book BOOK=mi-libro`
2) Compilar PDF:
   - `make pdf BOOK=mi-libro`
3) Generar EPUB:
   - `make epub BOOK=mi-libro`
4) Crear un capítulo:
   - `make new-chapter BOOK=mi-libro TITLE="Título del capítulo" SLUG="mi-slug"`

Atajos útiles:
- Verifica herramientas instaladas: `make doctor`
- Lista libros válidos para `BOOK=...`: `make list`
- Lista de comandos: `make help`

## Estructura del repositorio

- [`tex/milibro.tex`](tex/milibro.tex): archivo maestro (configurado para tamaño 6x9 y TOC navegable en PDF).
- [`tex/`](tex/): plantillas para iniciar un libro (públicas).
- [`tex/books/`](tex/books/): libros en edición (privados, cada subcarpeta es un libro independiente; se ignora en `.gitignore`).
- [`img/`](img/): imágenes y recursos gráficos compartidos (esta carpeta se mantiene, pero su contenido se ignora por defecto).
  - Portada: coloca `img/portada.jpg|png|pdf` (ver [`img/README.md`](img/README.md)).
- [`scripts/`](scripts/): scripts usados por el [`Makefile`](Makefile) para compilar/limpiar y utilidades de revisión de texto.
- [`build/`](build/): artefactos de compilación (auxiliares y salidas intermedias).
- [`dist/`](dist/): entregables finales (PDF/EPUB generados).
- [`docs/`](docs/): documentación operativa (estructura y checklist de publicación).
- [`notes/`](notes/): notas compartidas (la carpeta se mantiene, pero su contenido se ignora por defecto).

## Recomendaciones para trabajar en `tex/`

- Mantén cada capítulo en un archivo separado dentro del libro (p.ej. `tex/books/mi-libro/capituloN.tex`) y no repitas preámbulo: solo contenido.
- Para libros largos, `chapters.tex` usa `\milibroChapter{...}` (permite compilar solo capítulos específicos con `INCLUDEONLY=...`).
- Usa etiquetas estables para referencias:
  - `\label{chap:...}` para capítulos, `\label{sec:...}` para secciones, `\label{fig:...}` para figuras.
- Evita rutas absolutas y recursos fuera del repo (rompe compilación/EPUB). Todo debe vivir en `img/` u otra carpeta del proyecto.
- Mantén el LaTeX “semántico” (títulos, secciones, listas) y evita maquetación rígida si piensas convertir a EPUB.

## Funciones avanzadas (opcionales)

Todas se activan editando `metadatos.tex` dentro del libro seleccionado:

- Lista de figuras: `\LibroMostrarListaFiguras` (`0/1`).
- Lista de tablas: `\LibroMostrarListaTablas` (`0/1`).
- Bibliografía con `.bib` (biblatex+biber): `\LibroUsarBibliografia` (`0/1`) y `referencias.bib`.
- Índice analítico: `\LibroUsarIndiceAnalitico` (`0/1`) y marcas en el texto con `\index{...}`.

Requiere:
- Bibliografía: `biber`.
- Índice analítico: `makeindex`.

Guías:
- Bibliografía: `docs/BIBLIOGRAFIA.md`.
- Índices/listas y compilación parcial: `docs/INDICES.md`.

## Requisitos (herramientas)

Base:
- `make` + `bash`.

Compilación a PDF:
- TeX Live (recomendado `texlive-full`) y/o `latexmk` (si no está, el script cae a `pdflatex` con 2 pasadas).

EPUB:
- Preferente: `tex4ebook`.
- Alternativa/fallback: `pandoc` (usa `tex/books/<libro>/metadata.yaml` si existe; si no, `tex/metadata.yaml` como plantilla; y `img/portada.jpg|png` como cover cuando aplica).
- Recomendado: `tidy` (o `tidy-html5`) para reducir warnings cuando se usa `tex4ebook`.

Revisión de ortografía/redacción (opcional pero recomendado):
- `make spellcheck`: `aspell` + diccionario (`aspell-es`) o `hunspell` + diccionario (p.ej. `hunspell-es`).
- `make languagetool`: requiere LanguageTool Server local (por defecto `http://localhost:8081`) + `curl`, `detex`, `python3`.

Visores (opcionales):
- PDF: `atril`, `evince` u `okular` (se abre automáticamente si hay sesión GUI y `OPEN_VIEWER=1`).
- EPUB: `fbreader`, `ebook-viewer` (Calibre) (idem).

### Instalación sugerida (Ubuntu)

Nota: estos comandos son solo referencia; instala lo que necesites según tu sistema.

- Suite completa (más simple): `sudo apt update && sudo apt install texlive-full`
- Alternativa mínima (ajusta según falten paquetes): `sudo apt install texlive-latex-recommended texlive-latex-extra texlive-lang-spanish latexmk`
- EPUB (si no viene con tu TeX Live): `sudo apt install pandoc tidy`
- Ortografía: `sudo apt install aspell aspell-es` (o `sudo apt install hunspell hunspell-es`)
- Cliente de LanguageTool (para `make languagetool`): `sudo apt install curl python3`
- LanguageTool (server local): ver [`notes/GUIA_DE_TRABAJO.md`](notes/GUIA_DE_TRABAJO.md) (no se instala desde este repo)

## Uso con `make`

Targets:
- `make help`: muestra un resumen de targets y variables.
- `make list`: lista libros válidos (carpetas en `tex/books/` con `chapters.tex`) para usarlos como `BOOK=...`.
- `make pdf`: compila el libro seleccionado por `BOOK` (si no hay `BOOK`, compila las plantillas en `tex/`).
- `make epub`: genera el EPUB del libro seleccionado por `BOOK` (preferente `tex4ebook`; fallback `pandoc`).
- `make dist`: ejecuta `pdf` y `epub`.
- `make check`: compila y revisa referencias/archivos faltantes (si algo falla, devuelve error; usa `BOOK=...` para un libro).
- `make doctor`: verifica que tienes herramientas mínimas en `PATH` (sin instalar nada).
- `make watch`: recompila en caliente (requiere `latexmk`; usa `BOOK=...` para un libro).
- `make new-book BOOK=...`: crea `tex/books/BOOK/` copiando plantillas desde `tex/`.
- `make new-chapter BOOK=... TITLE="..."`: crea `capituloN.tex` en el libro seleccionado y lo agrega a `chapters.tex`.
- `make spellcheck`: lista palabras sospechosas (usa `BOOK=...` para revisar un libro; sin `BOOK`, revisa las plantillas en `tex/`).
- `make languagetool`: revisión de redacción/estilo vía LanguageTool local (usa `BOOK=...` para revisar un libro; sin `BOOK`, revisa las plantillas en `tex/`).
- `make clean`: limpia `build/` y temporales en la raíz (usa `BOOK=...` para limpiar solo `build/<libro>/`; conserva `dist/`).

Variables útiles:
- `OPEN_VIEWER=0 make pdf` / `OPEN_VIEWER=0 make epub`: desactiva la apertura automática del visor.
- `EPUB_FORMAT=epub2 make epub` o `EPUB_FORMAT=epub3 make epub`: el formato usado por `tex4ebook` (por defecto `epub3`).
- `INCLUDEONLY=capitulo3 make pdf`: compila solo ese capítulo (o varios separados por coma: `capitulo2,capitulo3`).
- `BOOK=mi-libro make pdf`: selecciona el libro (carpeta `tex/books/mi-libro/`).
- `FILES="tex/books/mi-libro/capitulo1.tex tex/books/mi-libro/backmatter.tex" make spellcheck`: limita archivos a revisar.
- `SPELL_LANG=es make spellcheck`: idioma del corrector (aspell/hunspell).
- `ASPELL_PERSONAL=notes/aspell.es.pws make spellcheck`: diccionario personal del proyecto (si aplica).
- `LT_LEVEL=picky make languagetool`: modo más estricto (LanguageTool).
- `LT_URL=http://localhost:8081/v2/check make languagetool`: endpoint de LanguageTool (API local).
- `LT_FAIL_ON_ISSUES=1 make languagetool`: falla si hay sugerencias (útil para CI/local).
- `PDF_VIEWER=...` / `EPUB_VIEWER=...`: fuerza un visor concreto (si está en `PATH`).

Notas:
- La compilación genera auxiliares dentro de `build/` para mantener el directorio raíz limpio.
- Si no indicas `BOOK`, los targets que trabajan con contenido usan `tex/` (plantillas base), útil para probar el flujo sin crear un libro.
- Si al generar EPUB ves `tidy: not found`, instala `tidy` (o `tidy-html5`) y vuelve a ejecutar `make epub`.

## Entregables

- Se generan en `dist/` al ejecutar `make pdf` / `make epub`.
- Archivos típicos: `dist/mi-libro.pdf`, `dist/mi-libro.epub` (cuando usas `BOOK=mi-libro`).

## Guías rápidas

- [`docs/INICIO_RAPIDO.md`](docs/INICIO_RAPIDO.md): el “camino feliz” para empezar.
- [`docs/RECETAS_LATEX.md`](docs/RECETAS_LATEX.md): ejemplos cortos (capítulos, referencias, imágenes, notas).
- [`docs/BIBLIOGRAFIA.md`](docs/BIBLIOGRAFIA.md): bibliografía con `.bib` (biblatex+biber) y alternativas simples.
- [`docs/INDICES.md`](docs/INDICES.md): TOC, lista de figuras/tablas e índice analítico.

## Licencia

Este proyecto está bajo la licencia MIT. Ver [`LICENSE`](LICENSE).

## Documentos

- [`docs/ESTRUCTURA.md`](docs/ESTRUCTURA.md): propuesta de estructura para escritura.
- [`docs/PUBLICACION.md`](docs/PUBLICACION.md): checklist técnico para publicación (PDF/EPUB).

## Notas y guía de trabajo

- [`notes/README.md`](notes/README.md): qué guardar en `notes/` (material de trabajo del escritor).
- [`notes/GUIA_DE_TRABAJO.md`](notes/GUIA_DE_TRABAJO.md): flujo recomendado (terminal), herramientas y checklist diario.
