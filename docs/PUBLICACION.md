# Checklist técnico de publicación (KDP/impresión y eBook)

Este checklist cubre lo que el repositorio puede verificar desde terminal. La parte editorial/legal (ISBN, derechos, portada, etc.) depende del proyecto.

## PDF (interior impreso)

- Portadilla/portada interior: configura la imagen en `img/portada.jpg` (ver `img/README.md`).
- Tamaño de página/trim: configura `geometry` según el tamaño final (por defecto 6x9).
- Márgenes: ajusta `inner/outer/top/bottom` según el número de páginas y requisitos de encuadernación.
- Fuentes embebidas: verifica con `pdffonts dist/milibro.pdf` (si está disponible).
- Enlaces: `hyperref` está configurado con `hidelinks` (sin recuadros/colores).
- Referencias resueltas: no deben quedar “??” en `\ref`/`\pageref`.

Comandos útiles:

- `make pdf`
- `make check`

## EPUB (Kindle/KDP)

- Portada eBook: `pandoc` usa `--epub-cover-image` si existe `img/portada.jpg`/`png`; con `tex4ebook` la portada se incluye como primera página si está en el frontmatter.
- Metadatos básicos: edita `metadata.yaml` (título, autor, idioma).
- Capítulos navegables: evita maquetación rígida y saltos de página excesivos.
- Imágenes: deben vivir en `img/` y referenciarse con rutas relativas.
- Validación/preview: prueba en un lector local o en Kindle Previewer (fuera del repo).

Comandos útiles:

- `make epub`
