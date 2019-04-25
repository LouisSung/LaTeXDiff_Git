# Copyright © 2019 LouisSung.
# All rights reserved.
# Version 1.0

echo -e "\e[1;36mGenerate Paper PDF\e[0m"

# export tex, bib, and bst path to env
export TEXINPUTS=.//:
export BIBINPUTS=.//:
export BSTINPUTS=.//:

BUILD_DIR='build/'
PAPER='Paper'

if [[ -n $(find ./ -name '*.bib') ]]; then    # build BibTex if exist
    pdflatex -output-directory=$BUILD_DIR $PAPER.tex > /dev/null
    bibtex $BUILD_DIR$PAPER.aux > /dev/null
    pdflatex -output-directory=$BUILD_DIR $PAPER.tex > /dev/null
fi

pdflatex -output-directory=$BUILD_DIR $PAPER.tex > /dev/null

# print important msg only
echo "\
log
   | ** Conference Paper **
   | Before submitting the final camera ready copy, remember to:
   | 
   |  1. Manually equalize the lengths of two columns on the last page
   |  of your paper;
   | 
   |  2. Ensure that any PostScript and/or PDF output post-processing
   |  uses only Type 1 fonts and that every step in the generation
   |  process uses the appropriate paper size."

echo -e "\e[1;36mDone\e[0m"
