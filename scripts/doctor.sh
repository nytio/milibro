#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_common.sh
source "$script_dir/_common.sh"

cd "$REPO_ROOT"

strict=0
lang="${SPELL_LANG:-es}"
lt_url="${LT_URL:-http://localhost:8081/v2/check}"

usage() {
  cat <<'EOF' >&2
Uso:
  scripts/doctor.sh [--strict]

Por defecto:
  - Falla solo si no puedes compilar PDF (no hay latexmk ni pdflatex).
  - Reporta (sin fallar) el estado de EPUB/ortografía/LanguageTool.

Opciones:
  --strict   También falla si no puedes generar EPUB (no hay tex4ebook ni pandoc).

Variables:
  SPELL_LANG=es
  LT_URL=http://localhost:8081/v2/check
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) strict=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "opción desconocida: $1" ;;
  esac
done

status_line() {
  local label="$1"
  local ok="$2"
  local detail="${3:-}"
  if [[ "$ok" -eq 1 ]]; then
    printf '[OK]      %s%s\n' "$label" "${detail:+ — $detail}"
  else
    printf '[FALTA]   %s%s\n' "$label" "${detail:+ — $detail}"
  fi
}

echo "== milibro doctor =="
echo

pdf_ok=0
if have latexmk; then
  pdf_ok=1
  status_line "PDF" 1 "latexmk"
elif have pdflatex; then
  pdf_ok=1
  status_line "PDF" 1 "pdflatex (sin latexmk)"
else
  status_line "PDF" 0 "instala TeX Live (latexmk o pdflatex)"
fi

epub_ok=0
if have tex4ebook; then
  epub_ok=1
  status_line "EPUB" 1 "tex4ebook"
elif have pandoc; then
  epub_ok=1
  status_line "EPUB" 1 "pandoc (fallback)"
else
  status_line "EPUB" 0 "instala tex4ebook o pandoc"
fi

if have aspell; then
  if aspell --lang="$lang" dump master >/dev/null 2>&1; then
    status_line "Ortografía" 1 "aspell ($lang)"
  else
    status_line "Ortografía" 0 "aspell sin diccionario ($lang) (p.ej. aspell-es)"
  fi
elif have hunspell; then
  dict="${HUNSPELL_DICT:-es_ES}"
  if printf "prueba\n" | hunspell -d "$dict" -l >/dev/null 2>&1; then
    status_line "Ortografía" 1 "hunspell ($dict)"
  else
    status_line "Ortografía" 0 "hunspell sin diccionario ($dict)"
  fi
else
  status_line "Ortografía" 0 "aspell o hunspell"
fi

lt_cmds_ok=1
for c in curl detex python3; do
  if ! have "$c"; then
    lt_cmds_ok=0
  fi
done
if [[ "$lt_cmds_ok" -eq 1 ]]; then
  status_line "LanguageTool" 1 "cliente OK (LT_URL=$lt_url)"
else
  status_line "LanguageTool" 0 "requiere curl + detex + python3"
fi

echo
echo "Siguiente paso típico:"
echo "  make pdf"

if [[ "$pdf_ok" -ne 1 ]]; then
  exit 1
fi
if [[ "$strict" -eq 1 && "$epub_ok" -ne 1 ]]; then
  exit 1
fi
exit 0

