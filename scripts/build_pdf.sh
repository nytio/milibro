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

mkdir -p "$build_dir" "$dist_dir"

[[ -f "$main_tex" ]] || die "no existe el archivo: $main_tex"

if command -v latexmk >/dev/null 2>&1; then
  latexmk \
    -pdf \
    -interaction=nonstopmode \
    -halt-on-error \
    -file-line-error \
    -outdir="$build_dir" \
    "$main_tex"
else
  have pdflatex || die "no se encontró 'latexmk' ni 'pdflatex' en PATH (instala TeX Live)."
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

[[ -f "$build_dir/$jobname.pdf" ]] || die "no se generó el PDF esperado: $build_dir/$jobname.pdf"
cp -f "$build_dir/$jobname.pdf" "$dist_dir/$jobname.pdf"
printf 'PDF listo: %s/%s.pdf\n' "$dist_dir" "$jobname"

open_pdf "$dist_dir/$jobname.pdf"
