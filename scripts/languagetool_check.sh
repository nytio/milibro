#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_common.sh
source "$script_dir/_common.sh"

cd "$REPO_ROOT"

lt_url="${LT_URL:-http://localhost:8081/v2/check}"
lt_language="${LT_LANGUAGE:-es}"
lt_level="${LT_LEVEL:-default}"
lt_connect_timeout="${LT_CONNECT_TIMEOUT:-2}"
lt_timeout="${LT_TIMEOUT:-20}"
lt_fail_on_issues="${LT_FAIL_ON_ISSUES:-0}"

usage() {
  cat <<'EOF' >&2
Uso:
  scripts/languagetool_check.sh [archivos...]

Por defecto revisa:
  tex/capitulo*.tex tex/backmatter.tex

Requiere:
  - LanguageTool Server en localhost (por defecto: http://localhost:8081)
  - curl, detex, python3

Variables:
  LT_URL=http://localhost:8081/v2/check
  LT_LANGUAGE=es
  LT_LEVEL=default|picky
  LT_CONNECT_TIMEOUT=2
  LT_TIMEOUT=20
  LT_FAIL_ON_ISSUES=0|1

Ejemplos:
  scripts/languagetool_check.sh tex/capitulo1.tex
  LT_LEVEL=picky scripts/languagetool_check.sh
  FILES="tex/capitulo1.tex tex/backmatter.tex" make languagetool
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 2
fi

files=("$@")
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

require_cmd curl
require_cmd detex
require_cmd python3

tmp_dir="$(mktemp -d)"
trap 'rm -rf -- "$tmp_dir"' EXIT

had_issues=0
only="${LT_ONLY:-}"

for f in "${files[@]}"; do
  [[ -f "$f" ]] || die "no existe: $f"

  prefix_txt="$tmp_dir/$(basename "$f").detex1.txt"
  text_txt="$tmp_dir/$(basename "$f").lt.txt"
  map_json="$tmp_dir/$(basename "$f").map.json"
  resp_json="$tmp_dir/$(basename "$f").resp.json"

  detex -l -n -s -1 "$f" >"$prefix_txt"
  python3 "$script_dir/languagetool_prepare.py" "$prefix_txt" "$text_txt" "$map_json"

  curl -sS \
    --connect-timeout "$lt_connect_timeout" \
    --max-time "$lt_timeout" \
    --data "language=$lt_language" \
    --data "level=$lt_level" \
    --data-urlencode "text@$text_txt" \
    "$lt_url" >"$resp_json" || die "falló la consulta a LanguageTool en $lt_url"

  format_args=(--source "$f" --text "$text_txt" --map "$map_json" --json "$resp_json")
  [[ -n "$only" ]] && format_args+=(--only "$only")
  set +e
  python3 "$script_dir/languagetool_format.py" "${format_args[@]}"
  rc=$?
  set -e
  if [[ "$rc" -eq 1 ]]; then
    had_issues=1
  elif [[ "$rc" -ne 0 ]]; then
    die "falló el formateo de resultados de LanguageTool para $f (código $rc)"
  fi
done

if [[ "$had_issues" -eq 1 && "$lt_fail_on_issues" != "0" ]]; then
  exit 1
fi
exit 0
