#!/usr/bin/env bash
set -euo pipefail

main_tex="${1:-milibro.tex}"
build_dir="${BUILD_DIR:-build}"
dist_dir="${DIST_DIR:-dist}"
jobname="$(basename "$main_tex" .tex)"
open_viewer="${OPEN_VIEWER:-1}"

mkdir -p "$build_dir" "$dist_dir"

cleanup_root_side_effects() {
  shopt -s nullglob
  rm -f -- \
    "$jobname".4ct \
    "$jobname".4tc \
    "$jobname".aux \
    "$jobname".css \
    "$jobname".dvi \
    "$jobname".html \
    "$jobname".idv \
    "$jobname".lg \
    "$jobname".log \
    "$jobname".ncx \
    "$jobname".tmp \
    "$jobname".xref \
    "$jobname"*.html \
    content.opf
  rm -rf -- "$jobname"-epub
}

if command -v tex4ebook >/dev/null 2>&1; then
  work_dir="$build_dir/epub"
  rm -rf "$work_dir"
  mkdir -p "$work_dir"

  tex4ebook -d "$work_dir" "$main_tex"
  cp -f "$work_dir/$jobname.epub" "$dist_dir/$jobname.epub"
  cleanup_root_side_effects

  printf 'EPUB listo: %s/%s.epub\n' "$dist_dir" "$jobname"

  if [[ "$open_viewer" != "0" ]] && command -v fbreader >/dev/null 2>&1; then
    if [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
      (fbreader "$dist_dir/$jobname.epub" >/dev/null 2>&1 &)
    else
      printf 'Nota: sin entorno gráfico; abre manualmente con: fbreader %s/%s.epub\n' "$dist_dir" "$jobname"
    fi
  fi
  exit 0
fi

if command -v pandoc >/dev/null 2>&1; then
  pandoc -s --toc -o "$dist_dir/$jobname.epub" "$main_tex"
  printf 'EPUB listo: %s/%s.epub\n' "$dist_dir" "$jobname"

  if [[ "$open_viewer" != "0" ]] && command -v fbreader >/dev/null 2>&1; then
    if [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
      (fbreader "$dist_dir/$jobname.epub" >/dev/null 2>&1 &)
    else
      printf 'Nota: sin entorno gráfico; abre manualmente con: fbreader %s/%s.epub\n' "$dist_dir" "$jobname"
    fi
  fi
  exit 0
fi

echo "Error: no se encontró 'tex4ebook' ni 'pandoc' en PATH." >&2
exit 1
