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
  scripts/check.sh [opciones] [main.tex]

Opciones:
  --book NAME        Compila y valida el libro tex/books/NAME (salida dist/NAME.pdf)
  --book-dir DIR     Compila y valida el libro ubicado en DIR
  --books-dir DIR    Base de libros (default: tex/books)

Variables:
  BOOK=...           Igual que --book
  BOOK_DIR=...       Igual que --book-dir
  BOOKS_DIR=...      Igual que --books-dir
  INCLUDEONLY=...    capitulo1,capitulo2
EOF
}

pass_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --book|--book-dir|--books-dir)
      pass_args+=("$1" "${2:-}")
      [[ "$1" == "--book" ]] && book="${2:-}"
      [[ "$1" == "--book-dir" ]] && book_dir="${2:-}"
      [[ "$1" == "--books-dir" ]] && books_dir="${2:-}"
      shift 2
      ;;
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

build_dir="$build_root"
[[ -n "$book" ]] && build_dir="$build_root/$book"

OPEN_VIEWER=0 BUILD_DIR="$build_root" DIST_DIR="$dist_dir" INCLUDEONLY="${INCLUDEONLY:-}" bash "$script_dir/build_pdf.sh" "${pass_args[@]}" "$main_tex"

log="$build_dir/$jobname.log"
[[ -f "$log" ]] || die "no se encontró el log esperado: $log"

search_log() {
  local pattern="$1"
  if have rg; then
    rg -n "$pattern" "$log" >/dev/null 2>&1
    return $?
  fi
  grep -E -n "$pattern" "$log" >/dev/null 2>&1
}

failed=0
if search_log "undefined references|There were undefined references|LaTeX Warning: Reference"; then
  echo "Problema: referencias indefinidas en $log" >&2
  failed=1
fi

if search_log "undefined citations|There were undefined citations|LaTeX Warning: Citation|Package biblatex Warning: Please \\(re\\)run Biber"; then
  echo "Problema: citas/bibliografía incompleta en $log" >&2
  failed=1
fi

if search_log "Input index file .*\\.idx not found|Usage: makeindex|makeindex.*returned with code"; then
  echo "Problema: índice analítico falló (makeindex) en $log" >&2
  failed=1
fi

if search_log 'LaTeX Warning: File `[^`]+` not found|! LaTeX Error: File `[^`]+` not found'; then
  echo "Problema: archivos faltantes (imágenes/inputs) en $log" >&2
  failed=1
fi

if have pdfinfo && [[ -f "$dist_dir/$jobname.pdf" ]]; then
  if have rg; then
    pdfinfo "$dist_dir/$jobname.pdf" | rg -n "Page size|Pages" || true
  else
    pdfinfo "$dist_dir/$jobname.pdf" | grep -E -n "Page size|Pages" || true
  fi
fi

if have pdffonts && [[ -f "$dist_dir/$jobname.pdf" ]]; then
  if have rg; then
    pdffonts "$dist_dir/$jobname.pdf" | tail -n +3 | awk '{print $4}' | rg -q "^no$" && \
      echo "Aviso: hay fuentes no embebidas en $dist_dir/$jobname.pdf (revisa 'pdffonts')." >&2
  else
    pdffonts "$dist_dir/$jobname.pdf" | tail -n +3 | awk '{print $4}' | grep -q "^no$" && \
      echo "Aviso: hay fuentes no embebidas en $dist_dir/$jobname.pdf (revisa 'pdffonts')." >&2
  fi
fi

if [[ "$failed" -eq 1 ]]; then
  exit 1
fi

printf 'Check OK: %s/%s.pdf\n' "$dist_dir" "$jobname"
