# milibro

Proyecto para escribir un libro en **LaTeX** en **Ubuntu desde la terminal**, generando un **PDF** (pensado para KDP/impresión) y un **EPUB** (para Kindle/KDP) con un flujo reproducible vía `make`.

La guía de trabajo del agente está en [`AGENTS.md`](AGENTS.md) y el documento objetivo/base está en [`Escribir un libro con LaTeX en Ubuntu desde la terminal.pdf`](Escribir%20un%20libro%20con%20LaTeX%20en%20Ubuntu%20desde%20la%20terminal.pdf).

## Inicio rápido

1) Compilar PDF:
   - `make pdf`
2) Generar EPUB:
   - `make epub`
3) Crear un capítulo:
   - `make new-chapter TITLE="Título del capítulo" SLUG="mi-slug"`

Atajos útiles:
- Verifica herramientas instaladas: `make doctor`
- Lista de comandos: `make help`

## Estructura del repositorio

- [`milibro.tex`](milibro.tex): archivo maestro (configurado para tamaño 6x9 y TOC navegable en PDF).
- [`tex/`](tex/): contenido del libro por capítulos/secciones.
  - Ejemplo: [`tex/capitulo1.tex`](tex/capitulo1.tex) (poema en prosa de prueba).
  - Soporte: [`tex/metadatos.tex`](tex/metadatos.tex), [`tex/preambulo.tex`](tex/preambulo.tex), [`tex/frontmatter.tex`](tex/frontmatter.tex), [`tex/chapters.tex`](tex/chapters.tex), [`tex/backmatter.tex`](tex/backmatter.tex).
- [`img/`](img/): imágenes y recursos gráficos del libro (siempre con rutas relativas, p.ej. `img/figura.png`).
  - Portada: coloca `img/portada.jpg|png|pdf` (ver [`img/README.md`](img/README.md)).
- [`scripts/`](scripts/): scripts usados por el [`Makefile`](Makefile) para compilar/limpiar y utilidades de revisión de texto.
- [`build/`](build/): artefactos de compilación (auxiliares y salidas intermedias).
- [`dist/`](dist/): entregables finales (PDF/EPUB generados).
- [`docs/`](docs/): documentación operativa (estructura y checklist de publicación).
- [`notes/`](notes/): notas de trabajo del escritor (opcional).

## Recomendaciones para trabajar en `tex/`

- Mantén cada capítulo en un archivo separado (`tex/capituloN.tex`) y no repitas preámbulo: solo contenido.
- Para libros largos, `tex/chapters.tex` usa `\milibroChapter{...}` (permite compilar solo capítulos específicos con `INCLUDEONLY=...`).
- Usa etiquetas estables para referencias:
  - `\label{chap:...}` para capítulos, `\label{sec:...}` para secciones, `\label{fig:...}` para figuras.
- Evita rutas absolutas y recursos fuera del repo (rompe compilación/EPUB). Todo debe vivir en `img/` u otra carpeta del proyecto.
- Mantén el LaTeX “semántico” (títulos, secciones, listas) y evita maquetación rígida si piensas convertir a EPUB.

## Funciones avanzadas (opcionales)

Todas se activan editando `tex/metadatos.tex`:

- Lista de figuras: `\LibroMostrarListaFiguras` (`0/1`).
- Lista de tablas: `\LibroMostrarListaTablas` (`0/1`).
- Bibliografía con `.bib` (biblatex+biber): `\LibroUsarBibliografia` (`0/1`) y `tex/referencias.bib`.
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
- Alternativa/fallback: `pandoc` (usa `metadata.yaml` si existe y `img/portada.jpg|png` como cover cuando aplica).
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
- `make pdf`: compila `milibro.tex` y copia el resultado a `dist/milibro.pdf`.
- `make epub`: genera `dist/milibro.epub` (usa `tex4ebook` si está disponible; si no, intenta `pandoc`).
- `make dist`: ejecuta `pdf` y `epub`.
- `make check`: compila y revisa referencias/archivos faltantes (si algo falla, devuelve error).
- `make doctor`: verifica que tienes herramientas mínimas en `PATH` (sin instalar nada).
- `make watch`: recompila en caliente (requiere `latexmk`).
- `make new-chapter TITLE="..."`: crea `tex/capituloN.tex` y lo agrega a `tex/chapters.tex`.
- `make spellcheck`: lista palabras sospechosas (por defecto revisa `tex/capitulo*.tex` y `tex/backmatter.tex`).
- `make languagetool`: revisión de redacción/estilo vía LanguageTool local (API).
- `make clean`: limpia `build/` y temporales en la raíz (conserva `dist/`).

Variables útiles:
- `OPEN_VIEWER=0 make pdf` / `OPEN_VIEWER=0 make epub`: desactiva la apertura automática del visor.
- `EPUB_FORMAT=epub2 make epub` o `EPUB_FORMAT=epub3 make epub`: el formato usado por `tex4ebook` (por defecto `epub3`).
- `INCLUDEONLY=capitulo3 make pdf`: compila solo ese capítulo (o varios separados por coma: `capitulo2,capitulo3`).
- `FILES="tex/capitulo1.tex tex/backmatter.tex" make spellcheck`: limita archivos a revisar.
- `SPELL_LANG=es make spellcheck`: idioma del corrector (aspell/hunspell).
- `ASPELL_PERSONAL=notes/aspell.es.pws make spellcheck`: diccionario personal del proyecto (si aplica).
- `LT_LEVEL=picky make languagetool`: modo más estricto (LanguageTool).
- `LT_URL=http://localhost:8081/v2/check make languagetool`: endpoint de LanguageTool (API local).
- `LT_FAIL_ON_ISSUES=1 make languagetool`: falla si hay sugerencias (útil para CI/local).
- `PDF_VIEWER=...` / `EPUB_VIEWER=...`: fuerza un visor concreto (si está en `PATH`).

Notas:
- La compilación genera auxiliares dentro de `build/` para mantener el directorio raíz limpio.
- Si al generar EPUB ves `tidy: not found`, instala `tidy` (o `tidy-html5`) y vuelve a ejecutar `make epub`.

## Entregables

- Se generan en `dist/` al ejecutar `make pdf` / `make epub`.
- Archivos típicos: `dist/milibro.pdf`, `dist/milibro.epub`.

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
