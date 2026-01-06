#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_common.sh
source "$script_dir/_common.sh"

cd "$REPO_ROOT"

main_tex="${1:-${MAIN_TEX:-milibro.tex}}"
build_dir="${BUILD_DIR:-build}"
dist_dir="${DIST_DIR:-dist}"
jobname="$(basename "$main_tex" .tex)"
epub_format="${EPUB_FORMAT:-epub3}"

mkdir -p "$build_dir" "$dist_dir"

[[ -f "$main_tex" ]] || die "no existe el archivo: $main_tex"

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

  tex4ebook -f "$epub_format" -d "$work_dir" "$main_tex"
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
    python3 "$script_dir/flatten_tex.py" "$main_tex" "$flattened_tex"
  else
    warn "no se encontró 'python3'; pandoc puede ignorar \\input/\\include."
    cp -f "$main_tex" "$flattened_tex"
  fi

  pandoc_args=(-s --toc --from=latex --resource-path=.:img:tex -o "$dist_dir/$jobname.epub")
  cover_img=""
  for c in img/portada.jpg img/portada.jpeg img/portada.png; do
    [[ -f "$c" ]] && cover_img="$c" && break
  done
  [[ -n "$cover_img" ]] && pandoc_args+=(--epub-cover-image="$cover_img")
  [[ -f metadata.yaml ]] && pandoc_args+=(--metadata-file=metadata.yaml)
  if [[ -f tex/referencias.bib ]]; then
    pandoc_args+=(--citeproc --bibliography=tex/referencias.bib)
  fi
  pandoc "${pandoc_args[@]}" "$flattened_tex"
  printf 'EPUB listo: %s/%s.epub\n' "$dist_dir" "$jobname"

  open_epub "$dist_dir/$jobname.epub"
  exit 0
fi

echo "Error: no se encontró 'tex4ebook' ni 'pandoc' en PATH." >&2
exit 1
