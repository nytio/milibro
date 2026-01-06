#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"

die() {
  echo "Error: $*" >&2
  exit 1
}

warn() {
  echo "Aviso: $*" >&2
}

have() {
  command -v "$1" >/dev/null 2>&1
}

require_cmd() {
  local cmd="$1"
  have "$cmd" || die "no se encontró '$cmd' en PATH."
}

is_gui_session() {
  [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]
}

open_file_if_possible() {
  local file="$1"
  local viewer="${2:-}"

  [[ "${OPEN_VIEWER:-1}" == "0" ]] && return 0
  is_gui_session || return 0

  if [[ -n "$viewer" ]]; then
    have "$viewer" && ("$viewer" "$file" >/dev/null 2>&1 &) && return 0
    return 0
  fi

  return 1
}

open_pdf() {
  local pdf="$1"
  local preferred="${PDF_VIEWER:-}"
  open_file_if_possible "$pdf" "$preferred" && return 0
  for v in atril evince okular xdg-open; do
    have "$v" && ("$v" "$pdf" >/dev/null 2>&1 &) && return 0
  done
  return 0
}

open_epub() {
  local epub="$1"
  local preferred="${EPUB_VIEWER:-}"
  open_file_if_possible "$epub" "$preferred" && return 0
  for v in fbreader ebook-viewer xdg-open; do
    have "$v" && ("$v" "$epub" >/dev/null 2>&1 &) && return 0
  done
  return 0
}

