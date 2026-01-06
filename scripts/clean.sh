#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_common.sh
source "$script_dir/_common.sh"

cd "$REPO_ROOT"

books_dir="${BOOKS_DIR:-tex/books}"
book="${BOOK:-}"
book_dir="${BOOK_DIR:-}"

usage() {
  cat <<'EOF' >&2
Uso:
  scripts/clean.sh [opciones] [main.tex]

Opciones:
  --book NAME        Limpia build/NAME (conserva otros libros) y temporales de NAME en raíz
  --book-dir DIR     Igual que --book usando <basename(DIR)>
  --books-dir DIR    Base de libros (default: tex/books)

Variables:
  BOOK=...           Igual que --book
  BOOK_DIR=...       Igual que --book-dir
  BOOKS_DIR=...      Igual que --books-dir
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --book) book="${2:-}"; shift 2 ;;
    --book-dir) book_dir="${2:-}"; shift 2 ;;
    --books-dir) books_dir="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) die "opción desconocida: $1" ;;
    *) break ;;
  esac
done

main_tex="${1:-${MAIN_TEX:-tex/milibro.tex}}"
build_root="${BUILD_DIR:-build}"
dist_dir="${DIST_DIR:-dist}"

if [[ -n "$book_dir" && -z "$book" ]]; then
  book="$(basename "$book_dir")"
fi
jobname="$(basename "$main_tex" .tex)"
[[ -n "$book" ]] && jobname="$book"

[[ -n "$build_root" && "$build_root" != "/" && "$build_root" != "." ]] || die "BUILD_DIR inválido: $build_root"
mkdir -p "$build_root" "$dist_dir"

if [[ -n "$book" ]]; then
  rm -rf -- "$build_root/$book"
else
  find "$build_root" -mindepth 1 -maxdepth 1 ! -name '.gitkeep' -exec rm -rf -- {} +
fi

shopt -s nullglob

# Auxiliares típicos (raíz).
if [[ -n "$book" ]]; then
  root_aux=(
    "$jobname".aux "$jobname".log "$jobname".toc "$jobname".out "$jobname".fls
    "$jobname".fdb_latexmk "$jobname".synctex.gz "$jobname".bbl "$jobname".blg
    "$jobname".bcf "$jobname".run.xml "$jobname".xdv "$jobname".lof "$jobname".lot
    "$jobname".nav "$jobname".snm "$jobname".vrb "$jobname".ilg "$jobname".ind
    "$jobname".idx "$jobname".xdy
  )
  rm -f -- "${root_aux[@]}"
else
  # Sin BOOK, se limpia la raíz completa (útil para tests con plantillas).
  root_aux=(
    *.aux *.log *.toc *.out *.fls *.fdb_latexmk *.synctex.gz *.bbl *.blg *.bcf
    *.run.xml *.xdv *.lof *.lot *.nav *.snm *.vrb *.ilg *.ind *.idx *.xdy
  )
  rm -f -- "${root_aux[@]}"
fi

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
