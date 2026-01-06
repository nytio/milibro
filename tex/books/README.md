# `tex/books/` (libros en edición)

Cada subcarpeta dentro de `tex/books/` es un libro **independiente** con sus propios archivos `.tex` (capítulos, metadatos, etc.).

Este repo **ignora** (`.gitignore`) todo el contenido de `tex/books/` para evitar que se publique material privado.

Uso típico:

- Crear un libro nuevo copiando las plantillas de `tex/`:
  - `make new-book BOOK=mi-libro`
- Compilar un libro:
  - `make pdf BOOK=mi-libro`
  - `make epub BOOK=mi-libro`
- Crear un capítulo dentro de un libro:
  - `make new-chapter BOOK=mi-libro TITLE="Título" SLUG="mi-slug"`

