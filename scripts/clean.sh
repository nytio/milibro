#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_common.sh
source "$script_dir/_common.sh"

cd "$REPO_ROOT"

main_tex="${1:-${MAIN_TEX:-milibro.tex}}"
build_dir="${BUILD_DIR:-build}"
dist_dir="${DIST_DIR:-dist}"
jobname="$(basename "$main_tex" .tex)"

[[ -n "$build_dir" && "$build_dir" != "/" && "$build_dir" != "." ]] || die "BUILD_DIR inválido: $build_dir"
mkdir -p "$build_dir" "$dist_dir"
find "$build_dir" -mindepth 1 -maxdepth 1 ! -name '.gitkeep' -exec rm -rf -- {} +

shopt -s nullglob

# Auxiliares típicos (raíz), pero sin tocar PDFs/EPUBs ajenos al proyecto.
root_aux=(
  *.aux *.log *.toc *.out *.fls *.fdb_latexmk *.synctex.gz *.bbl *.blg *.bcf
  *.run.xml *.xdv *.lof *.lot *.nav *.snm *.vrb *.ilg *.ind *.idx *.xdy
)
rm -f -- "${root_aux[@]}"

# Basura típica de tex4ebook/TeX4ht en raíz (con prefijo del jobname).
rm -f -- \
  "$jobname".4ct \
  "$jobname".4tc \
  "$jobname".css \
  "$jobname".dvi \
  "$jobname".html \
  "$jobname".opf \
  "$jobname".idv \
  "$jobname".lg \
  "$jobname".ncx \
  "$jobname".tmp \
  "$jobname".xref \
  "$jobname"*.html \
  "$jobname"*.xhtml \
  content.opf
rm -rf -- "$jobname"-epub
rm -rf -- "$jobname"-epub3

# Salidas generadas por el proyecto en raíz (si existieran).
rm -f -- "$jobname".pdf "$jobname".epub

printf 'Limpieza completa (build/ y auxiliares; dist/ se conserva).\n'
