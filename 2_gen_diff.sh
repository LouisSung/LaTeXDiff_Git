#!/bin/bash
# Copyright (c) 2019 LouisSung.
# All rights reserved.
# Version v1.1

# === Get options ===
OPTIONS="\
./$(basename "$0") [-h] [-p PY] [-t DIR] [-m TEX] [-k KEYWORD]
                [-b BR] [-a MAX_AU] [-c COMMIT_NUM=1] [-v (1/2/3/4/5/6/7)]:
 \e[1m\e[3m[-h]\e[0m               Show usage
 \e[1m\e[3m[-p PY=diff/gdpy]\e[0m  Change python script path (e.g., '-p zzz/gen_diff.py')
 \e[1m\e[3m[-t DIR=diff/]\e[0m     Change target directory (e.g., '-t abc/'; must end with '/')
 \e[1m\e[3m[-m TEX=Paper]\e[0m     Change Main Tex file (e.g., '-m xyz' use xyz.tex as Main)
 \e[1m\e[3m[-k KEYWORD]\e[0m       Add start word for commit msg (e.g., '-k Add -k Update')
 \e[1m\e[3m[-b BR=master]\e[0m     Set branch for generating diff PDFs
 \e[1m\e[3m[-a MAX_AU=2]\e[0m      Set max author num (require preamble '._p*.tex' for laxdiff)
 \e[1m\e[3m[-c COMMIT_NUM=1]\e[0m  Set start commit num (e.g., '-c 3' starts from 3rd commit)
 \e[1m\e[3m[-v]\e[0m               Verbose mode, show all outputs (for debug)
 \e[1m\e[3m[-v 1/2/3/4/5/6/7]\e[0m Verbose mode for specific command:
                      [1: new-pdflatex, 2: new-bibtex,
                       3: old-pdflatex, 4: old-bibtex,
                       5: latexdiff, 6: diff-pdflatex, 7: diff-paflatex]
                    Set mutiple times if needed, e.g., '-v 2 -v 5 -v 6'"
USAGE="\
\e[1;33mUSAGE\e[0m: \e[1mExecute diff/gen_diff.py (to generate diff PDFs) with pipenv support\e[0m

$OPTIONS"

PY_SCRIPT_DIR='diff/'
PY_SCRIPT='gen_diff.py'
MAX_AUTHOR='2'

while getopts ':hp:t:m:k:b:a:c:v:' option; do
  case "$option" in
    h) echo -e "$USAGE"; exit;;
    p) PY_SCRIPT_DIR=$(dirname $OPTARG)/; PY_SCRIPT=$(basename $OPTARG)
       if [ -f $PY_SCRIPT_DIR$PY_SCRIPT ]
       then echo "Using diff script: $PY_SCRIPT_DIR$PY_SCRIPT"; ARG_P=" -p $PY_SCRIPT_DIR$PY_SCRIPT"
       else echo "Diff script '$PY_SCRIPT_DIR$PY_SCRIPT' not found !"; exit 1; fi;;
    t) ARG_T=" -t $OPTARG"
       if [ "${OPTARG: -1}" != '/' ]; then echo "Dir must end with '/'"; exit 1
       elif [ -d $OPTARG ]; then echo "Target dir: $OPTARG"
       else echo "Dir '$OPTARG' not found !"; exit 1; fi;;
    m) if [ ${OPTARG: -4} == ".tex" ]; then OPTARG=${OPTARG:: -4}; fi; MAIN_PAPER=$OPTARG
       if [ ! -f "$MAIN_PAPER.tex" ]; then echo "File '$MAIN_PAPER.tex' not found !"; exit 1
       else echo "Main Tex: $MAIN_PAPER.tex"; fi;;
    k) KEYWORD="$KEYWORD,$OPTARG";;
    b) ARG_B=" -b $OPTARG"; echo "Process on branch: $OPTARG";;
    a) MAX_AUTHOR=$OPTARG; ARG_A=" -a $MAX_AUTHOR"; echo "Max author number: $MAX_AUTHOR";;
    c) ARG_C=" -c $OPTARG"; echo "Start from commit: $OPTARG";;
    v) case $OPTARG in
         1) V_NUM=$V_NUM'1';; 2) V_NUM=$V_NUM'2';; 3) V_NUM=$V_NUM'3';; 4) V_NUM=$V_NUM'4';;
         5) V_NUM=$V_NUM'5';; 6) V_NUM=$V_NUM'6';; 7) V_NUM=$V_NUM'7';;
         -h|-p|-t|-m|-k|-b|-a|-c|-v) V_NUM='1234567'
                                     OPTIND=$OPTIND-1;;   # for option after '-v with no argument'
         *) echo "Shoud be either '-v 1', ..., '-v 7'"; exit 1;;
       esac;;
    :) if [ $OPTARG == 'v' ]; then V_NUM='1234567'
       else echo -e "\e[1;31mError\e[0m: Missing argument for '\e[1;33m-$OPTARG\e[0m'\n$OPTIONS" >&2; fi;;
   \?) echo -e "\e[1;31mError\e[0m: Illegal option '\e[1;33m-$OPTARG\e[0m'\n$OPTIONS" >&2; exit 1;;
  esac
done; shift $((OPTIND-1))
if [ ! -z $KEYWORD ]; then echo "Add keyword: ${KEYWORD:1}"; ARG_K=" -k $KEYWORD"; fi
if [ ! -z $V_NUM ]; then echo "Verbose output: $V_NUM"; ARG_V=" -v '$V_NUM"; fi
for i in `seq 1 $MAX_AUTHOR`; do if [[ ! -n $(find $PY_SCRIPT_DIR -maxdepth 1 -name "._p$i.tex") ]]
    then echo "Preamble for author $i ($PY_SCRIPT_DIR._p$i.tex) not found !"; exit 1; fi; done

# === Generate diff PDFs ===
echo -e "\e[1;36mGenerate Diff PDFs\e[0m"

ORIGIN_DIR=$PWD
cd $PY_SCRIPT_DIR
python3 -m pipenv run python $PY_SCRIPT$ARG_P$ARG_T$ARG_M$ARG_K$ARG_B$ARG_A$ARG_C$ARG_V
cd $ORIGIN_DIR

echo -e "\e[1;36mDone\e[0m"
