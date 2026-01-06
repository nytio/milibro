#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_common.sh
source "$script_dir/_common.sh"

cd "$REPO_ROOT"

books_dir="${BOOKS_DIR:-tex/books}"

usage() {
  cat <<'EOF' >&2
Uso:
  scripts/list_books.sh

Variables:
  BOOKS_DIR=...      Base de libros (default: tex/books)

Salida:
  Imprime un libro por línea (valor válido para BOOK=...).
EOF
}

case "${1:-}" in
  "" ) ;;
  -h|--help) usage; exit 0 ;;
  *) die "argumento desconocido: $1 (usa --help)" ;;
esac

[[ -d "$books_dir" ]] || die "no existe el directorio de libros: $books_dir"

shopt -s nullglob
found=0
for dir in "$books_dir"/*/; do
  book="$(basename "$dir")"
  [[ -f "$dir/chapters.tex" ]] || continue
  printf '%s\n' "$book"
  found=1
done

if [[ "$found" -eq 0 ]]; then
  warn "no se encontraron libros válidos en: $books_dir"
  warn "crea uno con: make new-book BOOK='mi-libro'"
fi

