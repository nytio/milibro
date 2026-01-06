# milibro

Proyecto para escribir un libro en **LaTeX** en **Ubuntu desde la terminal**, generando un **PDF** (pensado para KDP/impresión) y un **EPUB** (para Kindle/KDP) con un flujo reproducible vía `make`.

La guía de trabajo del agente está en `AGENTS.md` y el documento objetivo/base está en `Escribir un libro con LaTeX en Ubuntu desde la terminal.pdf`.

## Estructura del repositorio

- `milibro.tex`: archivo maestro (configurado para tamaño 6x9 y TOC navegable en PDF).
- `tex/`: contenido del libro por capítulos/secciones.
  - Ejemplo: `tex/capitulo1.tex` (poema en prosa de prueba).
  - Soporte: `tex/metadatos.tex`, `tex/preambulo.tex`, `tex/frontmatter.tex`, `tex/chapters.tex`, `tex/backmatter.tex`.
- `img/`: imágenes y recursos gráficos del libro (siempre con rutas relativas, p.ej. `img/figura.png`).
- `scripts/`: scripts usados por el `Makefile` para compilar/limpiar.
- `build/`: artefactos de compilación (auxiliares y salidas intermedias).
- `dist/`: entregables finales (PDF/EPUB generados).
- `docs/`: documentación operativa (estructura y checklist de publicación).
- `notes/`: notas de trabajo del escritor (opcional).

## Recomendaciones para trabajar en `tex/`

- Mantén cada capítulo en un archivo separado (`tex/capituloN.tex`) y no repitas preámbulo: solo contenido.
- Usa etiquetas estables para referencias:
  - `\label{chap:...}` para capítulos, `\label{sec:...}` para secciones, `\label{fig:...}` para figuras.
- Evita rutas absolutas y recursos fuera del repo (rompe compilación/EPUB). Todo debe vivir en `img/` u otra carpeta del proyecto.
- Mantén el LaTeX “semántico” (títulos, secciones, listas) y evita maquetación rígida si piensas convertir a EPUB.

## Requisitos (herramientas)

Para compilar:
- TeX Live (recomendado `texlive-full`) y/o `latexmk`.
- Para EPUB:
  - Preferente: `tex4ebook` (suele venir con TeX Live extra).
  - Alternativa: `pandoc`.
  - Recomendado: `tidy` (evita warnings y mejora validez del EPUB generado por `tex4ebook`).

Visores (opcionales):
- PDF: `atril` (configurado para abrir automáticamente al finalizar `make pdf`).
- EPUB: `fbreader` (configurado para abrir automáticamente al finalizar `make epub`).

## Uso con `make`

Targets:
- `make pdf`: compila `milibro.tex` y copia el resultado a `dist/milibro.pdf`.
- `make epub`: genera `dist/milibro.epub` (usa `tex4ebook` si está disponible; si no, intenta `pandoc`).
- `make dist`: ejecuta `pdf` y `epub`.
- `make check`: compila y revisa referencias/archivos faltantes (si algo falla, devuelve error).
- `make watch`: recompila en caliente (requiere `latexmk`).
- `make new-chapter TITLE="..."`: crea `tex/capituloN.tex` y lo agrega a `tex/chapters.tex`.
- `make clean`: limpia `build/` y temporales en la raíz (conserva `dist/`).

Variables útiles:
- `OPEN_VIEWER=0 make pdf` / `OPEN_VIEWER=0 make epub`: desactiva la apertura automática del visor.
- `EPUB_FORMAT=epub2 make epub` o `EPUB_FORMAT=epub3 make epub`: el formato usado por `tex4ebook` (por defecto `epub3`).

Notas:
- La compilación genera auxiliares dentro de `build/` para mantener el directorio raíz limpio.
- Si al generar EPUB ves `tidy: not found`, instala `tidy` (o `tidy-html5`) y vuelve a ejecutar `make epub`.

## Entregables

- `dist/milibro.pdf`: PDF final (actual).
- `dist/milibro.epub`: EPUB para pruebas/Kindle.

## Licencia

Este proyecto está bajo la licencia MIT. Ver `LICENSE`.

## Documentos

- `docs/ESTRUCTURA.md`: propuesta de estructura para escritura.
- `docs/PUBLICACION.md`: checklist técnico para publicación (PDF/EPUB).
