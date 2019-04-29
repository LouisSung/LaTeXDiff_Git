#!/bin/bash
# Copyright (c) 2019 LouisSung.
# All rights reserved.
# Version v1.1

# === Get options ===
OPTIONS="\
./$(basename "$0") [-h] [-b DIR] [-m TEX] [-p] [-s] [-v (1/2/3/4)]:
 \e[1m\e[3m[-h]\e[0m            Show usage
 \e[1m\e[3m[-b DIR=build/]\e[0m Change build directory (e.g., '-b abc/'; must end with '/')
 \e[1m\e[3m[-m TEX=Paper]\e[0m  Change Main Tex file (e.g., '-m xyz' use xyz.tex as Main)
 \e[1m\e[3m[-p]\e[0m            Prune, keep .pdf only (i.e., rm .aux, .bbl, .blg, .log, .out)
 \e[1m\e[3m[-s]\e[0m            Silent mode, with no output
 \e[1m\e[3m[-v]\e[0m            Verbose mode, show all outputs (for debug)
 \e[1m\e[3m[-v 1/2/3/4]\e[0m    Verbose mode for specific command:
                   [1: pdflatex, 2: bibtex, 3: pdflatex, 4: pdflatex]
                 Set mutiple times if needed, e.g., '-v 1 -v 2 -v 4'"
USAGE="\
\e[1;33mUSAGE\e[0m: \e[1mGenerate normal .pdf file from .tex \
using \e[3mpdflatex\e[0m\e[1m and \e[3mbibtex\e[0m
 
$OPTIONS"

BUILD_DIR='build/'
MAIN_PAPER='Paper'
FLAG_P=false; FLAG_S=false
FLAG_O1=false; FLAG_O2=false; FLAG_O3=false; FLAG_O4=false

while getopts ':hb:m:psv:' option; do
  case "$option" in
    h) echo -e "$USAGE"; exit;;
    b) BUILD_DIR=$OPTARG
       if [ "${BUILD_DIR: -1}" != '/' ]; then echo "Dir must end with '/'"; exit 1
       elif [ -d $BUILD_DIR ]; then echo "Build dir: $BUILD_DIR"
       else echo "Dir '$BUILD_DIR' not found !"; exit 1; fi;;
    m) if [ ${OPTARG: -4} == ".tex" ]; then OPTARG=${OPTARG:: -4}; fi; MAIN_PAPER=$OPTARG
       if [ ! -f "$MAIN_PAPER.tex" ]; then echo "File '$MAIN_PAPER.tex' not found !"; exit 1
       else echo "Main Tex: $MAIN_PAPER.tex"; fi;;
    p) FLAG_P=true; echo 'Prune matafiles';;
    s) FLAG_S=true;;
    v) case $OPTARG in
         1) FLAG_O1=true;; 2) FLAG_O2=true;; 3) FLAG_O3=true;; 4) FLAG_O4=true;;
         -h|-b|-m|-p|-s|-v) FLAG_O1=true; FLAG_O2=true; FLAG_O3=true; FLAG_O4=true
                            OPTIND=$OPTIND-1;;   # for option after '-v with no argument'
         *) echo "Shoud be either '-v 1', '-v 2', '-v 3', or '-v 4'"; exit 1;;
       esac;;
    :) if [ $OPTARG == 'v' ]; then FLAG_O1=true; FLAG_O2=true; FLAG_O3=true; FLAG_O4=true; fi;;
   \?) echo -e "\e[1;31mError\e[0m: Illegal option '\e[1;33m-$OPTARG\e[0m'\n$OPTIONS" >&2; exit 1;;
  esac
done; shift $((OPTIND-1))
if $FLAG_S; then FLAG_O1=false; FLAG_O2=false; FLAG_O3=false; FLAG_O4=false; echo 'Silent mode'
elif $FLAG_O1 || $FLAG_O2 || $FLAG_O3 || $FLAG_O4; then echo 'Verbose mode'; fi

# === Compile .tex and .bib ===
echo -e "\e[1;36mGenerate Paper PDF\e[0m"
# export tex, bib, and bst path to ENV
export TEXINPUTS=.//:
export BIBINPUTS=.//:
export BSTINPUTS=.//:

# compilation process: (pdflatex -> bibtex -> pdflatex ->) pdflatex
if [[ -n $(find ./ -name '*.bib') ]]; then    # build BibTex if exist
    if $FLAG_O1; then pdflatex -output-directory=$BUILD_DIR $MAIN_PAPER.tex
    else pdflatex -output-directory=$BUILD_DIR $MAIN_PAPER.tex >/dev/null; fi
    if $FLAG_O2; then bibtex $BUILD_DIR$MAIN_PAPER.aux
    else bibtex $BUILD_DIR$MAIN_PAPER.aux >/dev/null; fi
    if $FLAG_O3; then pdflatex -output-directory=$BUILD_DIR $MAIN_PAPER.tex
    else pdflatex -output-directory=$BUILD_DIR $MAIN_PAPER.tex >/dev/null; fi
fi
if $FLAG_O4; then pdflatex -output-directory=$BUILD_DIR $MAIN_PAPER.tex
else pdflatex -output-directory=$BUILD_DIR $MAIN_PAPER.tex >/dev/null; fi

# delete matafile if '-p' option is set
if $FLAG_P; then for ext in aux bbl blg log out; do rm -f $BUILD_DIR$(basename $MAIN_PAPER).$ext;done; fi

# === Print IEEE msg ===
# print only if not in silent mode and not print outputs from pdflatex (already in pdflatex's log)
if ! ($FLAG_S || $FLAG_O1 || $FLAG_O3 || $FLAG_O4); then
  echo "\
** Conference Paper **
Before submitting the final camera ready copy, remember to:

1. Manually equalize the lengths of two columns on the last page
of your paper;

2. Ensure that any PostScript and/or PDF output post-processing
uses only Type 1 fonts and that every step in the generation
process uses the appropriate paper size."
fi

echo -e "\e[1;36mDone\e[0m"
