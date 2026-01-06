#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_common.sh
source "$script_dir/_common.sh"

cd "$REPO_ROOT"

books_dir="${BOOKS_DIR:-tex/books}"
book="${BOOK:-}"
book_dir="${BOOK_DIR:-}"
watch=0

usage() {
  cat <<'EOF' >&2
Uso:
  scripts/build_pdf.sh [opciones] [main.tex]

Opciones:
  --book NAME        Compila el libro en tex/books/NAME (salida: dist/NAME.pdf)
  --book-dir DIR     Compila el libro ubicado en DIR (salida: dist/<basename>.pdf)
  --books-dir DIR    Base de libros (default: tex/books)
  --watch            Recompila en caliente (requiere latexmk)

Variables:
  BOOK=...           Igual que --book
  BOOK_DIR=...       Igual que --book-dir
  BOOKS_DIR=...      Igual que --books-dir
  INCLUDEONLY=...    capitulo1,capitulo2 (usa \milibroChapter{...})
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --book) book="${2:-}"; shift 2 ;;
    --book-dir) book_dir="${2:-}"; shift 2 ;;
    --books-dir) books_dir="${2:-}"; shift 2 ;;
    --watch) watch=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) die "opción desconocida: $1" ;;
    *) break ;;
  esac
done

main_tex="${1:-${MAIN_TEX:-tex/milibro.tex}}"
build_root="${BUILD_DIR:-build}"
dist_dir="${DIST_DIR:-dist}"
includeonly_list="${INCLUDEONLY:-}"

tex_dir="tex"
if [[ -n "$book_dir" ]]; then
  tex_dir="$book_dir"
  [[ -z "$book" ]] && book="$(basename "$book_dir")"
elif [[ -n "$book" ]]; then
  tex_dir="$books_dir/$book"
fi

jobname="$(basename "$main_tex" .tex)"
if [[ -n "$book" ]]; then
  jobname="$book"
fi

build_dir="$build_root"
if [[ -n "$book" ]]; then
  build_dir="$build_root/$book"
fi

[[ -f "$main_tex" ]] || die "no existe el archivo: $main_tex"
if [[ -n "$book" ]]; then
  [[ -d "$tex_dir" ]] || die "no existe el directorio del libro: $tex_dir"
  [[ -f "$tex_dir/chapters.tex" ]] || die "falta $tex_dir/chapters.tex"
fi

mkdir -p "$build_dir" "$dist_dir"

compile_tex="$main_tex"
latexmk_jobname_args=()
pdflatex_jobname_args=()

if [[ -n "$book" || -n "$includeonly_list" ]]; then
  wrapper="$build_dir/$jobname.__wrapper__.tex"
  {
    [[ -n "$book" ]] && printf '\\def\\LibroTexDir{%s}\n' "$tex_dir"
    [[ -n "$includeonly_list" ]] && printf '\\def\\IncludeOnlyList{%s}\n' "$includeonly_list"
    printf '\\input{%s}\n' "$main_tex"
  } >"$wrapper"
  compile_tex="$wrapper"
  latexmk_jobname_args=(-jobname="$jobname")
  pdflatex_jobname_args=(-jobname "$jobname")
fi

if [[ "$watch" -eq 1 ]]; then
  have latexmk || die "--watch requiere 'latexmk'."
  latexmk \
    -pdf \
    -pvc \
    -interaction=nonstopmode \
    -halt-on-error \
    -file-line-error \
    "${latexmk_jobname_args[@]}" \
    -outdir="$build_dir" \
    "$compile_tex"
  exit 0
fi

if have latexmk; then
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
