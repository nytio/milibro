# Recetas LaTeX (rápidas y “compatibles con eBook”)

Estas recetas asumen el estilo del repo: capítulos en `tex/`, imágenes en `img/`, y etiquetas estables con prefijos `chap:`, `sec:`, `fig:`.

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
- `tex/preambulo.tex` ya incluye `graphicx` y `\graphicspath{{img/}}`, por eso puedes referenciar `figura.png` sin prefijar `img/`.
- Evita rutas absolutas: rompen compilación/EPUB.

## Nota al pie (sin bibliografía)

```tex
Una idea con contexto.\footnote{Aquí va la nota al pie.}
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

## Saltos de página (ojo con EPUB)

- Para PDF: `\newpage` puede ser útil.
- Para eBook: úsalo con moderación; el flujo se reacomoda y no hay “páginas fijas”.

