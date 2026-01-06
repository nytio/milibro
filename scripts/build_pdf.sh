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
includeonly_list="${INCLUDEONLY:-}"

mkdir -p "$build_dir" "$dist_dir"

[[ -f "$main_tex" ]] || die "no existe el archivo: $main_tex"

compile_tex="$main_tex"
latexmk_jobname_args=()
pdflatex_jobname_args=()
if [[ -n "$includeonly_list" ]]; then
  wrapper="$build_dir/$jobname.includeonly.tex"
  cat >"$wrapper" <<EOF
\\def\\IncludeOnlyList{$includeonly_list}
\\input{$main_tex}
EOF
  compile_tex="$wrapper"
  latexmk_jobname_args=(-jobname="$jobname")
  pdflatex_jobname_args=(-jobname "$jobname")
fi

if command -v latexmk >/dev/null 2>&1; then
  latexmk \
    -pdf \
    -interaction=nonstopmode \
    -halt-on-error \
    -file-line-error \
    "${latexmk_jobname_args[@]}" \
    -outdir="$build_dir" \
    "$compile_tex"
else
  have pdflatex || die "no se encontró 'latexmk' ni 'pdflatex' en PATH (instala TeX Live)."
  pdflatex \
    -interaction=nonstopmode \
    -halt-on-error \
    -file-line-error \
    "${pdflatex_jobname_args[@]}" \
    -output-directory="$build_dir" \
    "$compile_tex"

  # Bibliografía (biblatex+biber): detecta .bcf y corre biber si está disponible.
  if [[ -f "$build_dir/$jobname.bcf" ]]; then
    have biber || die "se requiere 'biber' (biblatex) para compilar bibliografía. Instala TeX Live completo o biber."
    biber --input-directory "$build_dir" --output-directory "$build_dir" "$jobname"
  fi

  # Índice analítico: detecta .idx y corre makeindex si está disponible.
  if [[ -f "$build_dir/$jobname.idx" ]]; then
    have makeindex || die "se requiere 'makeindex' para compilar el índice. Instala TeX Live completo."
    makeindex -o "$build_dir/$jobname.ind" "$build_dir/$jobname.idx"
  fi

  pdflatex \
    -interaction=nonstopmode \
    -halt-on-error \
    -file-line-error \
    "${pdflatex_jobname_args[@]}" \
    -output-directory="$build_dir" \
    "$compile_tex"
  pdflatex \
    -interaction=nonstopmode \
    -halt-on-error \
    -file-line-error \
    "${pdflatex_jobname_args[@]}" \
    -output-directory="$build_dir" \
    "$compile_tex"
fi

[[ -f "$build_dir/$jobname.pdf" ]] || die "no se generó el PDF esperado: $build_dir/$jobname.pdf"
cp -f "$build_dir/$jobname.pdf" "$dist_dir/$jobname.pdf"
printf 'PDF listo: %s/%s.pdf\n' "$dist_dir" "$jobname"

open_pdf "$dist_dir/$jobname.pdf"
