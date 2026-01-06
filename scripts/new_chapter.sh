#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_common.sh
source "$script_dir/_common.sh"

cd "$REPO_ROOT"

title="${1:-}"
slug="${2:-}"

[[ -n "$title" ]] || die "uso: scripts/new_chapter.sh \"Título del capítulo\" [slug]"

if [[ -z "$slug" ]]; then
  slug="$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')"
fi

max_n=0
shopt -s nullglob
for f in tex/capitulo*.tex; do
  bn="$(basename "$f")"
  n="${bn#capitulo}"
  n="${n%.tex}"
  [[ "$n" =~ ^[0-9]+$ ]] || continue
  (( n > max_n )) && max_n="$n"
done
next_n=$((max_n + 1))

chapter_file="tex/capitulo${next_n}.tex"
chapters_list="tex/chapters.tex"

[[ -f "$chapter_file" ]] && die "ya existe: $chapter_file"
[[ -f "$chapters_list" ]] || die "no existe: $chapters_list"

cat >"$chapter_file" <<EOF
\\chapter{$title}
\\label{chap:$slug}

EOF

printf '\\milibroChapter{%s}\n' "capitulo${next_n}" >>"$chapters_list"

printf 'Capítulo creado: %s\n' "$chapter_file"
printf 'Incluido en: %s\n' "$chapters_list"
