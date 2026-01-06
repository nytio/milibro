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
  scripts/new_chapter.sh [opciones] "Título del capítulo" [slug]

Opciones:
  --book NAME        Crea el capítulo dentro de tex/books/NAME
  --book-dir DIR     Crea el capítulo dentro de DIR
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
    -h|--help) usage; exit 2 ;;
    --) shift; break ;;
    -*) die "opción desconocida: $1" ;;
    *) break ;;
  esac
done

title="${1:-}"
slug="${2:-}"

[[ -n "$title" ]] || die "uso: scripts/new_chapter.sh \"Título del capítulo\" [slug]"

tex_dir="tex"
if [[ -n "$book_dir" ]]; then
  tex_dir="$book_dir"
elif [[ -n "$book" ]]; then
  tex_dir="$books_dir/$book"
else
  die "falta BOOK o BOOK_DIR. Uso: make new-chapter BOOK='mi-libro' TITLE='Título del capítulo'"
fi
[[ -d "$tex_dir" ]] || die "no existe el directorio del libro: $tex_dir"

if [[ -z "$slug" ]]; then
  slug="$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"
fi

max_n=0
shopt -s nullglob
for f in "$tex_dir"/capitulo*.tex; do
  bn="$(basename "$f")"
  n="${bn#capitulo}"
  n="${n%.tex}"
  [[ "$n" =~ ^[0-9]+$ ]] || continue
  (( n > max_n )) && max_n="$n"
done
next_n=$((max_n + 1))

chapter_file="$tex_dir/capitulo${next_n}.tex"
chapters_list="$tex_dir/chapters.tex"

[[ -f "$chapter_file" ]] && die "ya existe: $chapter_file"
[[ -f "$chapters_list" ]] || die "no existe: $chapters_list"

cat >"$chapter_file" <<EOF
\\chapter{$title}
\\label{chap:$slug}

EOF

printf '\\milibroChapter{%s}\n' "capitulo${next_n}" >>"$chapters_list"

printf 'Capítulo creado: %s\n' "$chapter_file"
printf 'Incluido en: %s\n' "$chapters_list"
