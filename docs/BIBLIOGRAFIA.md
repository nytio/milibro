# Bibliografía y citas (LaTeX) en `milibro`

Este repo soporta **dos niveles**:

1) **Simple** (sin herramientas extra): notas al pie o `thebibliography`.
2) **Completo** (recomendado): archivo `.bib` + `biblatex` + `biber`.

## Opción A: simple (sin `.bib`)

### A.1 Notas al pie (rápido)

```tex
Una afirmación.\footnote{Autor, \emph{Título}, Editorial, Año.}
```

### A.2 `thebibliography` (manual)

En `backmatter.tex` (dentro del libro, p.ej. `tex/books/<libro>/backmatter.tex`) puedes añadir:

```tex
\chapter*{Bibliografía}
\addcontentsline{toc}{chapter}{Bibliografía}
\begin{thebibliography}{9}
\bibitem{borges1944} Jorge Luis Borges. \emph{Ficciones}. 1944.
\end{thebibliography}
```

Y luego citar en el texto:

```tex
Texto con cita.\cite{borges1944}
```

Limitación: tienes que mantener la lista “a mano”.

## Opción B: `.bib` con `biblatex` + `biber` (recomendado)

### 1) Activar bibliografía

Edita `metadatos.tex` dentro del libro (p.ej. `tex/books/<libro>/metadatos.tex`):

```tex
\newcommand{\LibroUsarBibliografia}{1}
```

### 2) Crear `referencias.bib`

Este repo espera `referencias.bib` dentro del libro (p.ej. `tex/books/<libro>/referencias.bib`). Ejemplo:

```bibtex
@book{borges1944,
  author    = {Borges, Jorge Luis},
  title     = {Ficciones},
  year      = {1944},
  publisher = {Editorial ejemplo}
}
```

### 3) Citar dentro del texto

Con `biblatex`, formas típicas:

- `\autocite{borges1944}` (cita automática)
- `\textcite{borges1944}` (autor en el texto)
- `\parencite{borges1944}` (entre paréntesis)

Ejemplo:

```tex
Como observa \textcite{borges1944}, ...
```

### 4) Compilar

- Recomendado: `make pdf BOOK=<libro>` (usa `latexmk` si está disponible).
- Si compilas a mano: `pdflatex → biber → pdflatex → pdflatex`.

## Notas para EPUB/Kindle

- Si tu EPUB lo genera `tex4ebook`, `biblatex` suele conservarse mejor (en general, cuanto más “semántico” sea el LaTeX, mejor).
- Si tu EPUB lo genera `pandoc` (fallback), el script añade `--citeproc` automáticamente si existe `referencias.bib` dentro del libro.
  - Para máxima compatibilidad, usa citas simples tipo `\cite{...}` (pandoc no siempre entiende comandos específicos como `\autocite`).
