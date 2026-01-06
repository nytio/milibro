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
  scripts/build_epub.sh [opciones] [main.tex]

Opciones:
  --book NAME        Genera dist/NAME.epub desde tex/books/NAME (preferente tex4ebook; fallback pandoc)
  --book-dir DIR     Genera dist/<basename>.epub desde DIR
  --books-dir DIR    Base de libros (default: tex/books)

Variables:
  BOOK=...           Igual que --book
  BOOK_DIR=...       Igual que --book-dir
  BOOKS_DIR=...      Igual que --books-dir
  EPUB_FORMAT=...    epub2|epub3 (solo tex4ebook)
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
epub_format="${EPUB_FORMAT:-epub3}"

tex_dir="tex"
if [[ -n "$book_dir" ]]; then
  tex_dir="$book_dir"
  [[ -z "$book" ]] && book="$(basename "$book_dir")"
elif [[ -n "$book" ]]; then
  tex_dir="$books_dir/$book"
fi

[[ -f "$main_tex" ]] || die "no existe el archivo: $main_tex"
if [[ -n "$book" ]]; then
  [[ -d "$tex_dir" ]] || die "no existe el directorio del libro: $tex_dir"
  [[ -f "$tex_dir/chapters.tex" ]] || die "falta $tex_dir/chapters.tex"
fi

jobname="$(basename "$main_tex" .tex)"
if [[ -n "$book" ]]; then
  jobname="$book"
fi

build_dir="$build_root"
if [[ -n "$book" ]]; then
  build_dir="$build_root/$book"
fi

mkdir -p "$build_dir" "$dist_dir"

compile_tex="$main_tex"
if [[ -n "$book" ]]; then
  # Nota: tex4ebook usa el nombre del archivo como jobname; el wrapper debe llamarse "$jobname.tex".
  wrapper="$build_dir/$jobname.tex"
  {
    printf '\\def\\LibroTexDir{%s}\n' "$tex_dir"
    printf '\\input{%s}\n' "$main_tex"
  } >"$wrapper"
  compile_tex="$wrapper"
fi

cleanup_root_side_effects() {
  shopt -s nullglob
  rm -f -- \
    "$jobname".4ct \
    "$jobname".4tc \
    "$jobname".aux \
    "$jobname".css \
    "$jobname".dvi \
    "$jobname".html \
    "$jobname".opf \
    "$jobname".idv \
    "$jobname".lg \
    "$jobname".log \
    "$jobname".ncx \
    "$jobname".tmp \
    "$jobname".xref \
    "$jobname"*.html \
    "$jobname"*.xhtml \
    content.opf
  rm -rf -- "$jobname"-epub
  rm -rf -- "$jobname"-epub3
}

if command -v tex4ebook >/dev/null 2>&1; then
  work_dir="$build_dir/epub"
  rm -rf "$work_dir"
  mkdir -p "$work_dir"

  tex4ebook -f "$epub_format" -d "$work_dir" "$compile_tex"
  [[ -f "$work_dir/$jobname.epub" ]] || die "no se generó el EPUB esperado: $work_dir/$jobname.epub"
  cp -f "$work_dir/$jobname.epub" "$dist_dir/$jobname.epub"
  cleanup_root_side_effects

  printf 'EPUB listo: %s/%s.epub\n' "$dist_dir" "$jobname"

  open_epub "$dist_dir/$jobname.epub"
  exit 0
fi

if command -v pandoc >/dev/null 2>&1; then
  work_dir="$build_dir/epub"
  mkdir -p "$work_dir"
  flattened_tex="$work_dir/$jobname.flattened.tex"

  if have python3; then
    python3 "$script_dir/flatten_tex.py" "$compile_tex" "$flattened_tex"
  else
    warn "no se encontró 'python3'; pandoc puede ignorar \\input/\\include."
    cp -f "$compile_tex" "$flattened_tex"
  fi

  pandoc_resource_path=".:img:tex"
  [[ -n "$book" ]] && pandoc_resource_path="$pandoc_resource_path:$tex_dir"
  pandoc_args=(-s --toc --from=latex --resource-path="$pandoc_resource_path" -o "$dist_dir/$jobname.epub")
  cover_img=""
  for c in img/portada.jpg img/portada.jpeg img/portada.png; do
    [[ -f "$c" ]] && cover_img="$c" && break
  done
  [[ -n "$cover_img" ]] && pandoc_args+=(--epub-cover-image="$cover_img")
  meta_file=""
  for m in "$tex_dir/metadata.yaml" "$tex_dir/metadata.yml" tex/metadata.yaml tex/metadata.yml metadata.yaml metadata.yml; do
    [[ -f "$m" ]] && meta_file="$m" && break
  done
  [[ -n "$meta_file" ]] && pandoc_args+=(--metadata-file="$meta_file")
  bib_file="$tex_dir/referencias.bib"
  if [[ -f "$bib_file" ]]; then
    pandoc_args+=(--citeproc --bibliography="$bib_file")
  fi
  pandoc "${pandoc_args[@]}" "$flattened_tex"
  printf 'EPUB listo: %s/%s.epub\n' "$dist_dir" "$jobname"

  open_epub "$dist_dir/$jobname.epub"
  exit 0
fi

echo "Error: no se encontró 'tex4ebook' ni 'pandoc' en PATH." >&2
exit 1
