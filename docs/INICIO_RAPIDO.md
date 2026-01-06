# Inicio rápido (usuario nuevo)

Objetivo: crear un libro en `tex/books/<libro>/`, compilar a `dist/<libro>.pdf` y (si lo necesitas) generar `dist/<libro>.epub`, todo desde terminal.

## 1) Comprobar herramientas (sin instalar nada)

- `make doctor`

Si falta algo, revisa la sección **Requisitos** de `README.md` (incluye comandos sugeridos para Ubuntu, pero este repo no instala dependencias por ti).

## 2) Dónde editar

- Metadatos (título/autor/portada opcional): `tex/books/<libro>/metadatos.tex`
- Capítulos: `tex/books/<libro>/capituloN.tex`
- Lista de capítulos incluidos: `tex/books/<libro>/chapters.tex`
- Imágenes: `img/` (siempre rutas relativas)

## 3) Crear tu primer capítulo

- 1) Crea el libro:
  - `make new-book BOOK=mi-libro`
- 2) Crea el capítulo:
  - `make new-chapter BOOK=mi-libro TITLE="Mi primer capítulo" SLUG="mi-primer-capitulo"`

Esto crea `tex/books/mi-libro/capituloN.tex` y lo añade a `tex/books/mi-libro/chapters.tex`.

## 4) Compilar PDF

- `make pdf BOOK=mi-libro`

Salida: `dist/mi-libro.pdf` (auxiliares en `build/mi-libro/`).

## 5) Generar EPUB

- `make epub BOOK=mi-libro`

Salida: `dist/mi-libro.epub`.

Notas:
- Si tienes `tex4ebook`, se usa por defecto. Si no, el script intenta `pandoc`.
- Para `pandoc`, puedes completar metadatos en `tex/books/<libro>/metadata.yaml` (se crea con `make new-book`) y usar `img/portada.jpg|png` como cover si existe.

## 6) Recetas rápidas de LaTeX

- Ver `docs/RECETAS_LATEX.md`.

Si necesitas funciones “de libro largo”:
- Bibliografía: `docs/BIBLIOGRAFIA.md`.
- Listas e índices (figuras/tablas/índice analítico): `docs/INDICES.md`.
