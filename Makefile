SHELL := /usr/bin/env bash

MAIN_TEX := tex/milibro.tex
BUILD_DIR := build
DIST_DIR := dist
SCRIPTS_DIR := scripts
OPEN_VIEWER ?= 1
EPUB_FORMAT ?= epub3
INCLUDEONLY ?=
BOOK ?=
BOOKS_DIR ?= tex/books

.PHONY: all help list doctor pdf epub dist clean dirs check watch new-book new-chapter spellcheck languagetool

all: pdf

help:
	@printf '%s\n' \
	  "Uso:" \
	  "  make list                Enlista libros válidos (para usar con BOOK=...)" \
	  "  make pdf                 Compila a dist/<libro>.pdf (usa BOOK=...)" \
	  "  make epub                Genera dist/<libro>.epub (usa BOOK=...)" \
	  "  make dist                pdf + epub" \
	  "  make check               Compila y valida refs/archivos faltantes (usa BOOK=...)" \
	  "  make watch               Recompila en caliente (requiere latexmk)" \
	  "  make new-book BOOK=      Crea tex/books/BOOK desde plantillas en tex/" \
	  "  make new-chapter BOOK=mi-libro TITLE=  Crea capituloN.tex en el libro" \
	  "  make spellcheck          Revisión ortográfica (aspell/hunspell)" \
	  "  make languagetool        Revisión de estilo (LanguageTool local)" \
	  "  make clean               Limpia build/ y auxiliares" \
	  "  make doctor              Verifica herramientas en PATH" \
	  "" \
	  "Variables útiles:" \
	  "  OPEN_VIEWER=0            No abrir visor (PDF/EPUB)" \
	  "  EPUB_FORMAT=epub2|epub3  Formato para tex4ebook" \
	  "  INCLUDEONLY=capitulo1    Compila solo esos capítulos (separados por coma)" \
	  "  BOOK=mi-libro            Selecciona libro en tex/books/mi-libro" \
	  "  FILES=\"...\"              Limita archivos (spellcheck/languagetool)"

list: dirs
	@BOOKS_DIR="$(BOOKS_DIR)" bash "$(SCRIPTS_DIR)/list_books.sh"

doctor:
	@bash "$(SCRIPTS_DIR)/doctor.sh"

dirs:
	@mkdir -p "$(BUILD_DIR)" "$(DIST_DIR)" "$(BOOKS_DIR)"

pdf: dirs
	@BUILD_DIR="$(BUILD_DIR)" DIST_DIR="$(DIST_DIR)" OPEN_VIEWER="$(OPEN_VIEWER)" INCLUDEONLY="$(INCLUDEONLY)" BOOK="$(BOOK)" BOOKS_DIR="$(BOOKS_DIR)" bash "$(SCRIPTS_DIR)/build_pdf.sh" "$(MAIN_TEX)"

epub: dirs
	@BUILD_DIR="$(BUILD_DIR)" DIST_DIR="$(DIST_DIR)" OPEN_VIEWER="$(OPEN_VIEWER)" EPUB_FORMAT="$(EPUB_FORMAT)" BOOK="$(BOOK)" BOOKS_DIR="$(BOOKS_DIR)" bash "$(SCRIPTS_DIR)/build_epub.sh" "$(MAIN_TEX)"

dist: pdf epub

check: dirs
	@BUILD_DIR="$(BUILD_DIR)" DIST_DIR="$(DIST_DIR)" OPEN_VIEWER=0 INCLUDEONLY="$(INCLUDEONLY)" BOOK="$(BOOK)" BOOKS_DIR="$(BOOKS_DIR)" bash "$(SCRIPTS_DIR)/check.sh" "$(MAIN_TEX)"

watch: dirs
	@BOOK="$(BOOK)" BOOKS_DIR="$(BOOKS_DIR)" INCLUDEONLY="$(INCLUDEONLY)" BUILD_DIR="$(BUILD_DIR)" DIST_DIR="$(DIST_DIR)" OPEN_VIEWER="$(OPEN_VIEWER)" bash "$(SCRIPTS_DIR)/build_pdf.sh" --watch "$(MAIN_TEX)"

clean:
	@MAIN_TEX="$(MAIN_TEX)" BUILD_DIR="$(BUILD_DIR)" DIST_DIR="$(DIST_DIR)" BOOK="$(BOOK)" BOOKS_DIR="$(BOOKS_DIR)" bash "$(SCRIPTS_DIR)/clean.sh"

new-book: dirs
	@if [[ -z "$(BOOK)" ]]; then \
	  echo "Uso: make new-book BOOK='mi-libro'"; \
	  exit 1; \
	fi
	@BOOK="$(BOOK)" BOOKS_DIR="$(BOOKS_DIR)" bash "$(SCRIPTS_DIR)/new_book.sh"

new-chapter:
	@if [[ -z "$(BOOK)" ]]; then \
	  echo "Uso: make new-chapter BOOK='mi-libro' TITLE='Título del capítulo' [SLUG=mi-slug]"; \
	  exit 1; \
	fi
	@if [[ -z "$(TITLE)" ]]; then \
	  echo "Uso: make new-chapter BOOK='mi-libro' TITLE='Título del capítulo' [SLUG=mi-slug]"; \
	  exit 1; \
	fi
	@BOOK="$(BOOK)" BOOKS_DIR="$(BOOKS_DIR)" bash "$(SCRIPTS_DIR)/new_chapter.sh" "$(TITLE)" "$(SLUG)"

spellcheck:
	@FILES="$(FILES)" BOOK="$(BOOK)" BOOKS_DIR="$(BOOKS_DIR)" bash "$(SCRIPTS_DIR)/spellcheck.sh"

languagetool:
	@FILES="$(FILES)" BOOK="$(BOOK)" BOOKS_DIR="$(BOOKS_DIR)" bash "$(SCRIPTS_DIR)/languagetool_check.sh"
