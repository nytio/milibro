#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_common.sh
source "$script_dir/_common.sh"

cd "$REPO_ROOT"

mode="list"
lang="${SPELL_LANG:-es}"

usage() {
  cat <<'EOF' >&2
Uso:
  scripts/spellcheck.sh [--list|--check] [archivos...]

Por defecto revisa:
  tex/capitulo*.tex tex/backmatter.tex

Variables:
  SPELL_LANG=es          Idioma (aspell/hunspell)
  ASPELL_PERSONAL=...    Diccionario personal (por defecto: notes/aspell.es.pws si existe)
  SPELL_FILTER_NOISE=1   Filtra ruido típico (números romanos, etc.)

Ejemplos:
  scripts/spellcheck.sh --list
  scripts/spellcheck.sh --check tex/capitulo1.tex
  FILES="tex/capitulo1.tex tex/backmatter.tex" make spellcheck
EOF
}

files=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --list) mode="list"; shift ;;
    --check) mode="check"; shift ;;
    -h|--help) usage; exit 2 ;;
    --) shift; break ;;
    -*) die "opción desconocida: $1" ;;
    *) files+=("$1"); shift ;;
  esac
done

if [[ ${#files[@]} -eq 0 ]]; then
  if [[ -n "${FILES:-}" ]]; then
    # shellcheck disable=SC2206
    files=($FILES)
  else
    shopt -s nullglob
    files=(tex/capitulo*.tex tex/backmatter.tex)
  fi
fi

[[ ${#files[@]} -gt 0 ]] || die "no hay archivos para revisar."

aspell_personal="${ASPELL_PERSONAL:-}"
if [[ -z "$aspell_personal" && -f notes/aspell.es.pws ]]; then
  aspell_personal="notes/aspell.es.pws"
fi

misspell_tmp="$(mktemp)"
trap 'rm -f -- "$misspell_tmp"' EXIT

filter_noise() {
  if [[ "${SPELL_FILTER_NOISE:-1}" == "0" ]]; then
    cat
    return 0
  fi
  if have rg; then
    rg -v '^[IVXLCDM]+$' || true
    return 0
  fi
  grep -E -v '^[IVXLCDM]+$' || true
}

run_list_for_file() {
  local file="$1"
  [[ -f "$file" ]] || die "no existe: $file"
  if have aspell; then
    if aspell --lang="$lang" dump master >/dev/null 2>&1; then
      if [[ -n "$aspell_personal" ]]; then
        aspell --lang="$lang" --mode=tex --personal="$aspell_personal" list <"$file"
      else
        aspell --lang="$lang" --mode=tex list <"$file"
      fi
      return 0
    fi
    warn "aspell está instalado pero no hay diccionario para '$lang' (p.ej. paquete 'aspell-es')."
  fi

  if have hunspell; then
    dict="${HUNSPELL_DICT:-es_ES}"
    if printf "prueba\n" | hunspell -d "$dict" -l >/dev/null 2>&1; then
      hunspell -d "$dict" -t "$file" | awk 'NF{print $1}'
      return 0
    fi
    warn "hunspell está instalado pero no hay diccionario '$dict'."
  fi

  if [[ -f "$script_dir/languagetool_check.sh" ]]; then
    warn "sin diccionarios aspell/hunspell; usando LanguageTool local para ortografía (requiere servidor en localhost)."
    LT_ONLY=misspelling FILES="$file" bash "$script_dir/languagetool_check.sh"
    return 0
  fi

  die "no se encontró un backend para revisión ortográfica."
}

if [[ "$mode" == "check" ]]; then
  if ! have aspell || ! aspell --lang="$lang" dump master >/dev/null 2>&1; then
    die "modo --check requiere 'aspell' con diccionario '$lang' (p.ej. 'aspell-es')."
  fi
  for f in "${files[@]}"; do
    [[ -f "$f" ]] || die "no existe: $f"
    if [[ -n "$aspell_personal" ]]; then
      aspell --lang="$lang" --mode=tex --personal="$aspell_personal" check "$f"
    else
      aspell --lang="$lang" --mode=tex check "$f"
    fi
  done
  exit 0
fi

for f in "${files[@]}"; do
  echo "== $f =="
  run_list_for_file "$f" | filter_noise | sort -u | tee -a "$misspell_tmp"
  echo
done

echo "== Resumen (únicos) =="
filter_noise <"$misspell_tmp" | sort -u || true
