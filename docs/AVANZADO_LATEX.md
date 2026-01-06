# LaTeX avanzado (música, diagramas y “impresión pro”)

Este documento reúne recetas para casos más complejos (partituras, acordes, gráficos, cronogramas y preparación para imprenta). Muchas de estas técnicas son **PDF‑centradas**; para EPUB/Kindle conviene mantener el LaTeX lo más semántico y simple posible.

Dónde poner paquetes/configuración: en este repo, normalmente en `tex/preambulo.tex`.

Guías relacionadas del repo:
- Bibliografía y citas: `docs/BIBLIOGRAFIA.md`.
- Listas e índices (figuras/tablas/índice analítico): `docs/INDICES.md`.

## Música y partituras: opciones prácticas

### Opción A (recomendada): LilyPond + incluir como PDF

Ventajas: calidad tipográfica excelente, tablaturas de guitarra, letras alineadas con notas, y control musical real. Desventaja: requiere tener `lilypond` instalado (herramienta externa).

Flujo típico desde terminal:

1) Exporta tu partitura a PDF (y/o PNG) con LilyPond.
2) Inclúyela en el libro con `graphicx` (ya está en el preámbulo) o con `pdfpages` si quieres páginas completas.

Incluir una página de partitura (como imagen/PDF):

```tex
\begin{figure}[htbp]
  \centering
  \includegraphics[width=\linewidth]{partitura.pdf}
  \caption{Partitura: Título de la canción.}
  \label{fig:partitura-titulo}
\end{figure}
```

Insertar páginas completas de un PDF (útil si la partitura ocupa páginas enteras):

```tex
% en tex/preambulo.tex
\usepackage{pdfpages}
```

```tex
\includepdf[pages=-]{partitura.pdf} % todas las páginas
```

### Opción B: MusiXTeX / MusicTeX (LaTeX “puro”)

Ventajas: todo en LaTeX. Desventajas: curva de aprendizaje y, para algunos estilos, más fricción que LilyPond.

Pistas para explorar: paquetes `musixtex`, `musictex` (suelen venir con instalaciones completas de TeX Live). Si tu objetivo es “notación musical seria”, LilyPond suele ser el camino más directo.

### Opción C: ABC / otros formatos + conversión

Si ya escribes música en ABC, puedes convertir a SVG/PDF con herramientas externas y luego incluir el resultado como vector (ver sección de imágenes vectoriales).

## Música para cantar: letra + acordes (lead sheets)

Para canciones “tipo cancionero” (letra con acordes encima), suele funcionar bien el ecosistema de paquetes `songs`/`leadsheets` (según tu preferencia).

Patrón general (la idea):

- Definir la canción (título/autor).
- Escribir versos.
- Marcar acordes en línea para que se rendericen encima del texto.

Ejemplo con `songs` (acordes en línea con `\[ ... ]`):

```tex
% en tex/preambulo.tex
\usepackage{songs}
```

```tex
\beginsong{Mi canción}[by={Autor}]

\beginverse
\[Am]Primera línea de la \[F]estrofa\\
\[C]segunda línea con \[G]acordes
\endverse

\endsong
```

Si solo quieres letra “limpia” (sin acordes), `songs` permite apagar acordes (según configuración), lo cual es útil cuando el destino es EPUB.

Recomendación editorial:
- Mantén la letra “limpia” y evita ajustar a mano espacios; deja que el paquete se encargue.
- Si tu destino es EPUB, considera además generar un cancionero “solo texto” como fallback (los acordes encima no siempre traducen bien).

## Guitarra: acordes y diagramas

### Acordes en texto (rápido)

En prosa o letra, un formato consistente ayuda (aunque sea sin paquete):

```tex
\textbf{Am} \textbf{F} \textbf{C} \textbf{G}
```

### Diagramas de acordes con `songs` (si lo usas)

Con `songs`, es común definir diagramas con digitación tipo “X02210” y luego referenciarlos en la canción (revisa la documentación del paquete si quieres personalizar el estilo):

```tex
\gtab{Am}{X02210}
\gtab{F}{133211}
```

### Diagramas de acordes (cajas) con TikZ

Si no quieres depender de un paquete de acordes, puedes dibujar diagramas con `tikz`. Es más trabajo, pero muy controlable para imprenta.

```tex
% en tex/preambulo.tex
\usepackage{tikz}
```

(El diagrama exacto depende de tu convención: cuerdas, trastes, cejilla, digitación. Para producción, es preferible elegir un paquete especializado o LilyPond si ya lo usas.)

### Tablatura

- LilyPond ofrece tablatura de guitarra de forma nativa (flujo recomendado si ya compilas música).
- Como alternativa simple en libro, una tab “monoespaciada” puede ir en `verbatim`:

```tex
\begin{verbatim}
e|---0---0---|
B|---1---1---|
G|---0---0---|
D|---2---2---|
A|---3---3---|
E|-----------|
\end{verbatim}
```

## Imágenes vectoriales (PDF/SVG/EPS)

### PDF (lo más compatible con PDFLaTeX)

Para `pdflatex`, lo más simple es incluir vector como `.pdf`:

```tex
\includegraphics[width=0.8\linewidth]{diagrama.pdf}
```

### SVG (dos enfoques)

1) **Convertir SVG→PDF en tu flujo** (robusto):
   - Convierte con Inkscape desde terminal y guarda el `.pdf` en `img/` o `build/`.
   - Incluye el PDF resultante con `\includegraphics`.

2) Paquete `svg` (cómodo, pero requiere `-shell-escape`):

```tex
% en tex/preambulo.tex
\usepackage{svg}
```

```tex
\includesvg[width=\linewidth]{diagrama.svg}
```

Nota: si usas `-shell-escape`, hazlo conscientemente (ej.: para `svg` o `minted`). En este repo, podrías necesitar ajustar el comando de compilación si tu target lo requiere.

### EPS (solo si es inevitable)

Con `pdflatex`, EPS suele requerir conversión a PDF (p. ej. `epstopdf`). Si puedes, exporta a PDF directamente.

## Diagramas, flujos de trabajo y gráficos (TikZ/PGFPlots)

### Diagramas y flowcharts con TikZ

```tex
% en tex/preambulo.tex
\usepackage{tikz}
\usetikzlibrary{arrows.meta,positioning}
```

```tex
\begin{figure}[htbp]
\centering
\begin{tikzpicture}[
  node distance=10mm,
  box/.style={draw,rounded corners,align=center,inner sep=6pt},
  arrow/.style={-Latex}
]
\node[box] (a) {Borrador};
\node[box, right=of a] (b) {Revisión};
\node[box, right=of b] (c) {Edición final};
\draw[arrow] (a) -- (b);
\draw[arrow] (b) -- (c);
\end{tikzpicture}
\caption{Flujo de trabajo editorial.}
\label{fig:flujo-editorial}
\end{figure}
```

### Gráficos con PGFPlots (datos reproducibles)

```tex
% en tex/preambulo.tex
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}
```

```tex
\begin{figure}[htbp]
\centering
\begin{tikzpicture}
\begin{axis}[
  width=\linewidth,
  height=5cm,
  xlabel={Día},
  ylabel={Palabras},
  grid=both,
]
\addplot coordinates {(1,500) (2,800) (3,650) (4,1200)};
\end{axis}
\end{tikzpicture}
\caption{Progreso de escritura.}
\label{fig:progreso-escritura}
\end{figure}
```

Consejo: para datos reales, puedes leer CSV y mantener el gráfico “actualizable” (reproducible).

## Cronogramas (Gantt) para proyectos editoriales

`pgfgantt` permite cronogramas tipo Gantt (ideal para planificación de escritura/edición/corrección).

```tex
% en tex/preambulo.tex
\usepackage{pgfgantt}
```

```tex
\begin{figure}[htbp]
\centering
\begin{ganttchart}[
  vgrid,
  hgrid,
  time slot format=isodate-yearmonth,
  compress calendar
]{2026-01}{2026-06}
\gantttitlecalendar{year, month} \\
\ganttbar{Borrador}{2026-01}{2026-03} \\
\ganttbar{Revisión}{2026-03}{2026-04} \\
\ganttbar{Edición}{2026-04}{2026-05} \\
\ganttbar{Maquetación}{2026-05}{2026-06}
\end{ganttchart}
\caption{Cronograma del libro.}
\label{fig:gantt-libro}
\end{figure}
```

## Impresión avanzada: control fino del PDF

### Tamaño de corte, márgenes y sangrado

El repo ya usa `geometry` en `tex/preambulo.tex`. Para imprenta, normalmente ajustas:
- `papersize` (tamaño de corte)
- `inner/outer` (márgenes para encuadernación)
- `top/bottom`

Si necesitas **marcas de corte** (crop marks), puedes explorar el paquete `crop`:

```tex
% en tex/preambulo.tex (ejemplo; ajusta a tu imprenta)
\usepackage[cam,center]{crop}
```

### Color para imprenta (CMYK)

Si vas a imprimir en CMYK, `xcolor` puede declararse con esa intención:

```tex
% en tex/preambulo.tex
\usepackage[cmyk]{xcolor}
```

### Páginas apaisadas y doble página

```tex
% en tex/preambulo.tex
\usepackage{pdflscape}
```

```tex
\begin{landscape}
Contenido ancho (tablas, cronogramas, etc.).
\end{landscape}
```

### PDF “más profesional” (metadatos, marcadores, enlaces)

Este repo ya incluye `hyperref` + `bookmark`. Si quieres referencias más semánticas, revisa también `cleveref` (nombres automáticos tipo “figura”, “sección”).

## Escritura avanzada: herramientas útiles dentro del texto

### Control tipográfico (viudas/huérfanas, overfull, cortes)

Recetas típicas cuando preparas PDF para imprenta:

```tex
% en tex/preambulo.tex (valores altos = intenta evitar viudas/huérfanas)
\widowpenalty=10000
\clubpenalty=10000
\displaywidowpenalty=10000

% reduce “Overfull \\hbox” en casos difíciles (último recurso)
\emergencystretch=2em

% marca visualmente líneas que se salen del margen (solo para depurar)
% \overfullrule=5pt
```

En el texto, para sugerir cortes de línea/página:

```tex
\linebreak   % salto de línea “suave”
\pagebreak   % salto de página “suave”
\nopagebreak % intenta evitar salto de página aquí
\begin{samepage} ... \end{samepage} % intenta mantener el bloque junto
```

### Notas del autor y modo borrador

Para dejar marcas visibles en PDF mientras escribes:

```tex
% en tex/preambulo.tex
\usepackage{xcolor}
\newcommand{\nota}[1]{\textcolor{red}{[Nota: #1]}}
```

### Texto “literal” y bloques técnicos

- `\verb|...|` para fragmentos cortos.
- `verbatim` para bloques.
- `listings` o `minted` para código con resaltado (minted requiere `-shell-escape`).

### Tablas con calidad tipográfica

```tex
% en tex/preambulo.tex
\usepackage{booktabs}
```

```tex
\begin{tabular}{lrr}
\toprule
Capítulo & Páginas & Estado \\
\midrule
1 & 12 & OK \\
2 & 18 & En revisión \\
\bottomrule
\end{tabular}
```

### Índice analítico y glosario (si el libro lo pide)

- Índice: `makeidx` (genera índice con `makeindex`/latexmk).
- Glosario: `glossaries` (más pesado, pero potente).

Ambos añaden pasos/auxiliares a la compilación; `latexmk` suele manejarlos si está configurado.

## Checklist (antes de “pro”)

- Si incorporas herramientas externas (LilyPond/Inkscape), define un flujo reproducible (ideal: script o target `make`).
- Evita rutas absolutas (imágenes/partituras siempre dentro del repo).
- Para EPUB: valida qué elementos se degradan (TikZ/PGFPlots y partituras complejas suelen necesitar imágenes).
