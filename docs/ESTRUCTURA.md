# Estructura recomendada (escritor)

El repositorio está pensado para escribir y publicar desde la terminal, separando contenido, recursos y automatización.

## Carpeta y archivos clave

- `tex/milibro.tex`: archivo maestro (punto único de entrada).
- `tex/`: plantillas base para iniciar un libro.
- `tex/books/<libro>/`: contenido del libro (cada subcarpeta es un libro independiente; se ignora en git).
  - `tex/books/<libro>/metadatos.tex`: título/autor y metadatos básicos (PDF/EPUB).
  - `tex/books/<libro>/preambulo.tex`: paquetes y configuración base (español, tipografía, imágenes).
  - `tex/books/<libro>/frontmatter.tex`: portada, página legal y tabla de contenidos.
  - `tex/books/<libro>/chapters.tex`: lista de capítulos incluidos (se edita al añadir capítulos).
  - `tex/books/<libro>/capituloN.tex`: capítulos.
  - `tex/books/<libro>/backmatter.tex`: secciones finales (p.ej., “Sobre el autor”).
  - (Opcional) `tex/books/<libro>/referencias.bib`: bibliografía en formato BibTeX (si activas biblatex).
- `img/`: imágenes compartidas (rutas siempre relativas; el contenido se ignora por defecto).
- `scripts/`: compilación, conversión y utilidades.
- `build/`: artefactos de compilación (aux/log/pdf intermedio; p.ej. `build/<libro>/`).
- `dist/`: entregables finales listos para subir (PDF/EPUB; p.ej. `dist/<libro>.pdf`).

## Carpeta opcional para el escritor

Si quieres separar material de trabajo sin mezclarlo con el libro:

- `notes/`: esquemas, lista de pendientes, personajes, cronología, glosario, etc. (texto plano/Markdown).

## Para empezar rápido

- `docs/INICIO_RAPIDO.md`: pasos mínimos para compilar y empezar a escribir.
- `docs/RECETAS_LATEX.md`: ejemplos cortos de LaTeX (referencias, imágenes, notas).
