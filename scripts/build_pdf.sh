#!/usr/bin/env bash
set -euo pipefail

main_tex="${1:-milibro.tex}"
build_dir="${BUILD_DIR:-build}"
dist_dir="${DIST_DIR:-dist}"
jobname="$(basename "$main_tex" .tex)"
open_viewer="${OPEN_VIEWER:-1}"

mkdir -p "$build_dir" "$dist_dir"

if command -v latexmk >/dev/null 2>&1; then
  latexmk \
    -pdf \
    -interaction=nonstopmode \
    -halt-on-error \
    -file-line-error \
    -outdir="$build_dir" \
    "$main_tex"
else
  pdflatex \
    -interaction=nonstopmode \
    -halt-on-error \
    -file-line-error \
    -output-directory="$build_dir" \
    "$main_tex"
  pdflatex \
    -interaction=nonstopmode \
    -halt-on-error \
    -file-line-error \
    -output-directory="$build_dir" \
    "$main_tex"
fi

cp -f "$build_dir/$jobname.pdf" "$dist_dir/$jobname.pdf"
printf 'PDF listo: %s/%s.pdf\n' "$dist_dir" "$jobname"

if [[ "$open_viewer" != "0" ]] && command -v atril >/dev/null 2>&1; then
  if [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
    (atril "$dist_dir/$jobname.pdf" >/dev/null 2>&1 &)
  else
    printf 'Nota: sin entorno gráfico; abre manualmente con: atril %s/%s.pdf\n' "$dist_dir" "$jobname"
  fi
fi
