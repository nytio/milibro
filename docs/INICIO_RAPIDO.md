# Inicio rápido (usuario nuevo)

Objetivo: escribir en `tex/`, compilar a `dist/milibro.pdf` y (si lo necesitas) generar `dist/milibro.epub`, todo desde terminal.

## 1) Comprobar herramientas (sin instalar nada)

- `make doctor`

Si falta algo, revisa la sección **Requisitos** de `README.md` (incluye comandos sugeridos para Ubuntu, pero este repo no instala dependencias por ti).

## 2) Dónde editar

- Metadatos (título/autor/portada opcional): `tex/metadatos.tex`
- Capítulos: `tex/capituloN.tex`
- Lista de capítulos incluidos: `tex/chapters.tex`
- Imágenes: `img/` (siempre rutas relativas)

## 3) Crear tu primer capítulo

- `make new-chapter TITLE="Mi primer capítulo" SLUG="mi-primer-capitulo"`

Esto crea `tex/capituloN.tex` y lo añade a `tex/chapters.tex`.

## 4) Compilar PDF

- `make pdf`

Salida: `dist/milibro.pdf` (auxiliares en `build/`).

## 5) Generar EPUB

- `make epub`

Salida: `dist/milibro.epub`.

Notas:
- Si tienes `tex4ebook`, se usa por defecto. Si no, el script intenta `pandoc`.
- Para `pandoc`, puedes completar metadatos en `metadata.yaml` y usar `img/portada.jpg|png` como cover si existe.

## 6) Recetas rápidas de LaTeX

- Ver `docs/RECETAS_LATEX.md`.

