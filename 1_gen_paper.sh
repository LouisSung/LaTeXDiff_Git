echo -e "\e[1;36mGenerate Paper PDF\e[0m"

if [ ! -f "build/Paper.aux" ]; then    # make sure to ref citation for the first build
    pdflatex -output-directory=build/ Paper.tex > /dev/null; fi

pdflatex -output-directory=build/ Paper.tex > /dev/null
# print important msg only
printf "** Conference Paper **
Before submitting the final camera ready copy, remember to:

 1. Manually equalize the lengths of two columns on the last page
 of your paper;

 2. Ensure that any PostScript and/or PDF output post-processing
 uses only Type 1 fonts and that every step in the generation
 process uses the appropriate paper size.
"

echo -e "\e[1;36mDone\e[0m"
