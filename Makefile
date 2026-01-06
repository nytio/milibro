SHELL := /usr/bin/env bash

MAIN_TEX := milibro.tex
BUILD_DIR := build
DIST_DIR := dist
SCRIPTS_DIR := scripts
OPEN_VIEWER ?= 1
EPUB_FORMAT ?= epub3

.PHONY: all help doctor pdf epub dist clean dirs check watch new-chapter spellcheck languagetool

all: pdf

help:
	@printf '%s\n' \
	  "Uso:" \
	  "  make pdf                 Compila a dist/milibro.pdf" \
	  "  make epub                Genera dist/milibro.epub (tex4ebook o pandoc)" \
	  "  make dist                pdf + epub" \
	  "  make check               Compila y valida refs/archivos faltantes" \
	  "  make watch               Recompila en caliente (requiere latexmk)" \
	  "  make new-chapter TITLE=  Crea tex/capituloN.tex y lo incluye" \
	  "  make spellcheck          Revisión ortográfica (aspell/hunspell)" \
	  "  make languagetool        Revisión de estilo (LanguageTool local)" \
	  "  make clean               Limpia build/ y auxiliares" \
	  "  make doctor              Verifica herramientas en PATH" \
	  "" \
	  "Variables útiles:" \
	  "  OPEN_VIEWER=0            No abrir visor (PDF/EPUB)" \
	  "  EPUB_FORMAT=epub2|epub3  Formato para tex4ebook" \
	  "  FILES=\"...\"              Limita archivos (spellcheck/languagetool)"

doctor:
	@bash "$(SCRIPTS_DIR)/doctor.sh"

dirs:
	@mkdir -p "$(BUILD_DIR)" "$(DIST_DIR)"

pdf: dirs
	@BUILD_DIR="$(BUILD_DIR)" DIST_DIR="$(DIST_DIR)" OPEN_VIEWER="$(OPEN_VIEWER)" bash "$(SCRIPTS_DIR)/build_pdf.sh" "$(MAIN_TEX)"

epub: dirs
	@BUILD_DIR="$(BUILD_DIR)" DIST_DIR="$(DIST_DIR)" OPEN_VIEWER="$(OPEN_VIEWER)" EPUB_FORMAT="$(EPUB_FORMAT)" bash "$(SCRIPTS_DIR)/build_epub.sh" "$(MAIN_TEX)"

dist: pdf epub

check: dirs
	@BUILD_DIR="$(BUILD_DIR)" DIST_DIR="$(DIST_DIR)" OPEN_VIEWER=0 bash "$(SCRIPTS_DIR)/check.sh" "$(MAIN_TEX)"

watch: dirs
	@if command -v latexmk >/dev/null 2>&1; then \
	  latexmk -pdf -pvc -interaction=nonstopmode -halt-on-error -file-line-error -outdir="$(BUILD_DIR)" "$(MAIN_TEX)"; \
	else \
	  echo "Error: 'latexmk' es requerido para watch (instala TeX Live/latexmk)."; \
	  exit 1; \
	fi

clean:
	@MAIN_TEX="$(MAIN_TEX)" BUILD_DIR="$(BUILD_DIR)" DIST_DIR="$(DIST_DIR)" bash "$(SCRIPTS_DIR)/clean.sh"

new-chapter:
	@if [[ -z "$(TITLE)" ]]; then \
	  echo "Uso: make new-chapter TITLE='Título del capítulo' [SLUG=mi-slug]"; \
	  exit 1; \
	fi
	@bash "$(SCRIPTS_DIR)/new_chapter.sh" "$(TITLE)" "$(SLUG)"

spellcheck:
	@FILES="$(FILES)" bash "$(SCRIPTS_DIR)/spellcheck.sh"

languagetool:
	@FILES="$(FILES)" bash "$(SCRIPTS_DIR)/languagetool_check.sh"
