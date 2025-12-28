SHELL := /usr/bin/env bash

MAIN_TEX := milibro.tex
BUILD_DIR := build
DIST_DIR := dist
SCRIPTS_DIR := scripts

.PHONY: all pdf epub dist clean dirs

all: pdf

dirs:
	@mkdir -p "$(BUILD_DIR)" "$(DIST_DIR)"

pdf: dirs
	@BUILD_DIR="$(BUILD_DIR)" DIST_DIR="$(DIST_DIR)" OPEN_VIEWER=1 bash "$(SCRIPTS_DIR)/build_pdf.sh" "$(MAIN_TEX)"

epub: dirs
	@BUILD_DIR="$(BUILD_DIR)" DIST_DIR="$(DIST_DIR)" OPEN_VIEWER=1 bash "$(SCRIPTS_DIR)/build_epub.sh" "$(MAIN_TEX)"

dist: pdf epub

clean:
	@MAIN_TEX="$(MAIN_TEX)" BUILD_DIR="$(BUILD_DIR)" DIST_DIR="$(DIST_DIR)" bash "$(SCRIPTS_DIR)/clean.sh"
