#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_common.sh
source "$script_dir/_common.sh"

cd "$REPO_ROOT"

books_dir="${BOOKS_DIR:-tex/books}"
book="${BOOK:-}"
force=0

usage() {
  cat <<'EOF' >&2
Uso:
  scripts/new_book.sh [opciones]

Opciones:
  --book NAME        Crea tex/books/NAME copiando plantillas desde tex/
  --books-dir DIR    Base de libros (default: tex/books)
  --force            Sobrescribe si ya existe

Variables:
  BOOK=...           Igual que --book
  BOOKS_DIR=...      Igual que --books-dir
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --book) book="${2:-}"; shift 2 ;;
    --books-dir) books_dir="${2:-}"; shift 2 ;;
    --force) force=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) die "opción desconocida: $1" ;;
    *) die "argumento inesperado: $1" ;;
  esac
done

[[ -n "$book" ]] || die "falta BOOK. Uso: scripts/new_book.sh --book mi-libro"
[[ "$book" =~ ^[a-zA-Z0-9._-]+$ ]] || die "BOOK inválido: usa solo letras/números/punto/guion/guion_bajo."

src_dir="tex"
dst_dir="$books_dir/$book"
templates=(
  backmatter.tex
  capitulo1.tex
  chapters.tex
  frontmatter.tex
  metadata.yaml
  metadatos.tex
  preambulo.tex
  referencias.bib
)

mkdir -p "$books_dir"

if [[ -e "$dst_dir" && "$force" -ne 1 ]]; then
  die "ya existe: $dst_dir (usa --force para sobrescribir)"
fi
mkdir -p "$dst_dir"

for f in "${templates[@]}"; do
  [[ -f "$src_dir/$f" ]] || die "falta plantilla: $src_dir/$f"
  if [[ "$force" -eq 1 ]]; then
    cp -f "$src_dir/$f" "$dst_dir/$f"
  else
    [[ -e "$dst_dir/$f" ]] && die "ya existe: $dst_dir/$f (usa --force)"
    cp "$src_dir/$f" "$dst_dir/$f"
  fi
done

printf 'Libro creado: %s\n' "$dst_dir"
printf 'Siguiente paso: make pdf BOOK=%s\n' "$book"
