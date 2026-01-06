# Índices y listas (TOC, figuras, tablas, índice analítico)

Este repo ya genera **tabla de contenidos (TOC)** y permite activar, cuando te convenga:

- Lista de figuras (`\listoffigures`)
- Lista de tablas (`\listoftables`)
- Índice analítico (palabras clave al final del libro)

## 1) Tabla de contenidos (TOC)

Está activada por defecto en `tex/frontmatter.tex` con `\tableofcontents`.

Controla la profundidad del TOC en `tex/preambulo.tex`:

```tex
\setcounter{tocdepth}{2}
```

## 2) Lista de figuras (LOF)

1) Activa en `tex/metadatos.tex`:

```tex
\newcommand{\LibroMostrarListaFiguras}{1}
```

2) Asegúrate de que tus figuras tengan `\caption{...}` y `\label{...}`:

```tex
\begin{figure}[htbp]
  \centering
  \includegraphics[width=\linewidth]{figura.png}
  \caption{Una figura.}
  \label{fig:una-figura}
\end{figure}
```

## 3) Lista de tablas (LOT)

1) Activa en `tex/metadatos.tex`:

```tex
\newcommand{\LibroMostrarListaTablas}{1}
```

2) Asegúrate de que tus tablas tengan `\caption{...}` y `\label{...}` (ver `docs/RECETAS_LATEX.md`).

## 4) Índice analítico (palabras clave)

Útil para no-ficción, manuales o libros con muchos conceptos.

### 4.1 Activar

En `tex/metadatos.tex`:

```tex
\newcommand{\LibroUsarIndiceAnalitico}{1}
```

### 4.2 Marcar entradas en el texto

Ejemplos:

```tex
campo\index{campo}
campo\index{campo!mexicano}
LaTeX\index{LaTeX@\LaTeX}
```

### 4.3 Compilar

Con `latexmk` (recomendado), `make pdf` suele encargarse.

Si compilas manualmente, el flujo típico es:

`pdflatex → makeindex → pdflatex → pdflatex`

## 5) Compilar solo algunos capítulos (para escribir más rápido)

Este repo usa `\milibroChapter{...}` en `tex/chapters.tex`, así que puedes compilar solo ciertos capítulos:

- `INCLUDEONLY=capitulo3 make pdf`
- `INCLUDEONLY=capitulo2,capitulo3 make pdf`

Nota: el argumento debe coincidir con los `\milibroChapter{...}` (sin `.tex`).
