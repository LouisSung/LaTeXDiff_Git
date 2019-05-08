#!/bin/bash
# Copyright (c) 2019 LouisSung.
# All rights reserved.
# Version v1.1

# === Get options ===
OPTIONS="\
./$(basename "$0") [-h] [-t] [-j]:
 \e[1m\e[3m[-h]\e[0m    Show usage
 \e[1m\e[3m[-t]\e[0m    Run Texmaker only (default)
 \e[1m\e[3m[-j]\e[0m    Run JabRef only
 \e[1m\e[3m[-t -j]\e[0m Run both Texmaker and JabRef"
USAGE="\
\e[1;33mUSAGE\e[0m: \e[1mRun editors. Only run \e[3mTexmaker\e[0m\e[1m with \e[3mENVs\e[0m\e[1m to support subfolders by default\e[0m

$OPTIONS"

FLAG_T=false; FLAG_J=false

while getopts ':htj' option; do
  case "$option" in
    h) echo -e "$USAGE"; exit;;
    t) FLAG_T=true;;
    j) FLAG_J=true;;
   \?) echo -e "\e[1;31mError\e[0m: Illegal option '\e[1;33m-$OPTARG\e[0m'\n$OPTIONS" >&2; exit 1;;
  esac
done; shift $((OPTIND-1))

# === Run Editor ===
if ! $FLAG_J || $FLAG_T; then
    # export tex, bib, and bst path to env
    export TEXINPUTS=.//:
    export BIBINPUTS=.//:
    export BSTINPUTS=.//:

    # run texmaker in the background
    texmaker &>/dev/null &
fi
if $FLAG_J; then
    # run jabref in the background and redirect outputs to /dev/null
    jabref &>/dev/null &
fi
