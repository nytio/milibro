# Estructura recomendada (escritor)

El repositorio está pensado para escribir y publicar desde la terminal, separando contenido, recursos y automatización.

## Carpeta y archivos clave

- `milibro.tex`: archivo maestro (punto único de entrada).
- `tex/`: contenido del libro (capítulos y auxiliares de LaTeX).
  - `tex/metadatos.tex`: título/autor y metadatos básicos (PDF/EPUB).
  - `tex/preambulo.tex`: paquetes y configuración base (español, tipografía, imágenes).
  - `tex/frontmatter.tex`: portada, página legal y tabla de contenidos.
  - `tex/chapters.tex`: lista de capítulos incluidos (se edita al añadir capítulos).
  - `tex/capituloN.tex`: capítulos.
  - `tex/backmatter.tex`: secciones finales (p.ej., “Sobre el autor”).
  - (Opcional) `tex/referencias.bib`: bibliografía en formato BibTeX (si activas biblatex).
- `img/`: imágenes (rutas siempre relativas).
- `scripts/`: compilación, conversión y utilidades.
- `build/`: artefactos de compilación (aux/log/pdf intermedio).
- `dist/`: entregables finales listos para subir (PDF/EPUB).

## Carpeta opcional para el escritor

Si quieres separar material de trabajo sin mezclarlo con el libro:

- `notes/`: esquemas, lista de pendientes, personajes, cronología, glosario, etc. (texto plano/Markdown).

## Para empezar rápido

- `docs/INICIO_RAPIDO.md`: pasos mínimos para compilar y empezar a escribir.
- `docs/RECETAS_LATEX.md`: ejemplos cortos de LaTeX (referencias, imágenes, notas).
