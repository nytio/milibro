# Recetas LaTeX (rápidas y “compatibles con eBook”)

Estas recetas asumen el estilo del repo: capítulos dentro de `tex/books/<libro>/`, imágenes en `img/`, y etiquetas estables con prefijos `chap:`, `sec:`, `fig:`.

## Capítulo + etiqueta

```tex
\chapter{Título del capítulo}
\label{chap:mi-capitulo}
```

## Sección + referencia cruzada

```tex
\section{Contexto}
\label{sec:contexto}

Como vimos en la sección~\ref{sec:contexto}, ...
```

Tip: usa `~` antes de `\ref` para evitar saltos raros de línea.

## Figura (imagen) + caption + referencia

1) Coloca el archivo en `img/` (por ejemplo `img/figura.png`).
2) Inserta en tu capítulo:

```tex
\begin{figure}[htbp]
  \centering
  \includegraphics[width=\linewidth]{figura.png}
  \caption{Ejemplo de figura.}
  \label{fig:figura-ejemplo}
\end{figure}

Ver la figura~\ref{fig:figura-ejemplo}.
```

Notas:
- `preambulo.tex` (dentro del libro) ya incluye `graphicx` y `\graphicspath{{img/}}`, por eso puedes referenciar `figura.png` sin prefijar `img/`.
- Evita rutas absolutas: rompen compilación/EPUB.

Para generar la “lista de figuras” en el frontmatter:
- Edita `metadatos.tex` dentro del libro y pon `\newcommand{\LibroMostrarListaFiguras}{1}`.

## Nota al pie (sin bibliografía)

```tex
Una idea con contexto.\footnote{Aquí va la nota al pie.}
```

## Tabla + caption + referencia (y lista de tablas)

```tex
\begin{table}[htbp]
  \centering
  \begin{tabular}{ll}
    \textbf{Elemento} & \textbf{Estado} \\
    Capítulo 1 & Borrador \\
    Capítulo 2 & Revisión \\
  \end{tabular}
  \caption{Estado de capítulos.}
  \label{tab:estado-capitulos}
\end{table}

Ver la tabla~\ref{tab:estado-capitulos}.
```

Para generar la “lista de tablas” en el frontmatter:
- Edita `metadatos.tex` dentro del libro y pon `\newcommand{\LibroMostrarListaTablas}{1}`.

## Bibliografía (citas) con `.bib`

Ver `docs/BIBLIOGRAFIA.md`. Ejemplo mínimo:

```tex
Texto con cita.\autocite{borges1944}
```

## Listas

```tex
\begin{itemize}
  \item Punto 1
  \item Punto 2
\end{itemize}
```

## Citas largas

```tex
\begin{quote}
Una cita larga va aquí.
\end{quote}
```

## Saltos de línea (poesía) sin cambiar de párrafo

En LaTeX, un salto de línea en el archivo fuente **no** crea un salto de línea en el PDF: se considera “espacio”. Un **párrafo nuevo** se crea con una línea en blanco.

Para cortar línea **sin** iniciar un nuevo párrafo (típico en poemas), usa `\\` (o `\newline`) al final de cada verso:

```tex
Primera línea\\
Segunda línea\\
Tercera línea
```

Sugerencia para poemas: usa el entorno `verse` y marca los versos con `\\`:

```tex
\begin{verse}
Primera línea\\
Segunda línea\\
Tercera línea
\end{verse}
```

Notas:
- `\\*` evita un salto de página justo después del verso.
- Evita `\\` en prosa normal: úsalo para versos, direcciones postales, listas “en bloque”, etc.

## Énfasis, cursivas y comillas

```tex
\emph{Énfasis (recomendado).}
\textit{Cursiva.}
\textbf{Negrita.}
```

Con UTF-8 puedes escribir comillas directamente (p. ej. `« »`, “ ”). Si te resulta más cómodo en terminal:

```tex
``comillas dobles'' y `comillas simples'
```

## Diálogos y citas cortas

```tex
\begin{quote}
—Un diálogo o cita en bloque.
\end{quote}
```

## Guiones y puntos suspensivos

```tex
Rango 1990--2020.
Inciso ---con raya larga--- en el texto.
Puntos suspensivos\ldots{}
```

## Espacios “no separables” y cortes de palabra

```tex
Sr.~Pérez  % evita salto de línea entre Sr. y Pérez
capítulo~\ref{chap:mi-capitulo}
hi\-per\-texto % sugiere cortes silábicos en una palabra difícil
```

## Caracteres especiales (escapar)

```tex
\% \_ \& \# \$ \{ \}
```

## Saltos de página (ojo con EPUB)

- Para PDF: `\newpage` puede ser útil.
- Para eBook: úsalo con moderación; el flujo se reacomoda y no hay “páginas fijas”.

## Índice analítico (palabras clave al final)

Ver `docs/INDICES.md`. Ejemplo:

```tex
campo\index{campo}
```
