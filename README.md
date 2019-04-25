# Tutorial for LaTeX Diff 
## About
### - Why
This tutorial is mainly for the course - *English for Science and Technology*, CS, NTHU.  
However, it doesn't restrict to this course but also for gernal purpose.  

### - What
Scripts including `.sh` and `.py` are written for *Bash* and *Python3* on Ubuntu respectively.  
These scripts aim to shorten your time on checking differences between each (git commit) version.  

### - How
The whole folder will be clone twice and do *git checkout -f* and *latexdiff* to prevent messing up your working.  
Most of files in subfolders will temporarily moved to 'diff-root folder' in order to do *latexdiff* during the process.
  
`0_init.sh`: To set up required environment, including git config and package installation  
`1_gen_paper.sh`: To generate normal `.pdf` file from `.tex` using *pdflatex* and *bibtex*  
`2_gen_diff.sh`: To execute `gen_diff.py` with *pipenv* support  
`3_run_texmaker.sh`: To start *texmaker* with ENVs, which make texmaker able to support subfolders  
`diff/gen_diff.py`: To generate diff `.pdf` file between commits using *latexdiff* and *git*  


### - When
`0_init.sh`: For git-config part, run once for different projects; otherwise, once and for all  
`1_gen_paper.sh`: Each time you want to upadate pdf result  
`2_gen_diff.sh`: After git-commit with specific keywords in commit message  
`3_run_texmaker.sh`: Each time for running texmaker if using subfolders  
`diff/gen_diff.py`: Just sit and wait, i.e., don't have to run it manually  

### - Constraints
In this project, there are some constrains so that you could avoid process all of the commits.  
Only commits that meet the following constraints will be processed:  
1. On `master` branch; therefore, allow you to have *detail commits* on the other branches then merge them back.  
2. Message start with `"Edit"` and `"Review"`; therefore, allow you to have *non-edit commits*, e.g., update readme.  

### - Limitation
Due to the limitation of *latexdiff* and latex itself, some recommendations are offered:  
1. Do not having the files with *same name* in *different folders*.  
`E.g., '123/file.tex' and '456/file.tex' shouldn't be in the same project`  
2. *Comments* in latex won't be treated as *differences*, use it carefully.  
`Both comments followed by '%' and between '\iffalse \fi' won't be processed`  
`Refer commit '0c572b3' and file 'diff/5-Zapdos-Review_author.pdf' in this repository`  

### - License
This project is licensed upder the MIT License (aka MadeInTaiwan License ฅ• ω •ฅ).  
So feel free to modify it to your own version if needed.  
Also feel free to contact me if having any comment.  

## Environment Setup
### 1. Code clone
```bash
git clone https://github.com/LouisSung/LaTeX_Diff
cd LaTeX_Diff/
```

### 2. Run init script
```bash
./0_init.sh
```
```yaml
Reset user config (name and email)? [Y/n]    # default Y; prees Enter to continue
- Enter user name for git:
- Enter user email for git:
Reset (origin) remote? [Y/n]
- Enter remote url:
- Add secondary push remote? [y/N]    # default N, add if needed
-  Enter secondary remote url:
Set other configs (git graph and pull --rebase)? [Y/n]

Install TexLive-Science (SW distribution for TeX)? [Y/n]
Install Latexdiff (To generate diff PDFs)? [Y/n]
Install Texmaker (Open-source LaTeX editor)? [Y/n]
Install pip3 (The Python Package Installer)? [y/N]    # install if needed 
Install Pipenv (Virtual environment for Python)? [y/N]    # install if needed
Init pipenv (For gen_diff.py)? [Y/n]
```

## Commands
### - Generate Paper PDF
```bash
# Prerequisite: TexLive-Science
# Target: build/Paper.pdf
./1_gen_paper.sh
```

### - Generate Diff PDFs
```bash
# Prerequisite: python3, pip3, pipenv, and gitpython
# Target: diff/([1-9][0-9]*-USER-COMMIT_MSG.pdf)*
./2_gen_diff.sh
```

### - Start Texmaker
```bash
# Prerequisite: Texmaker
./3_run_texmaker.sh
```

### - List Commit Logs
```bash
git graph    # should set alias (via init script)
# For example:
#  * 8d96138 - (7 days ago) Edit introduction - Zapdos
#  * 28f8338 - (7 days ago) Edit title and author - Articuno
#  * 32156c9 - (7 days ago) Init - LouisSung
```

## Editors
### - Texmaker
#### Use 'build' folder
Options > Configure Texmaker > Commands  
1. Check 'Use a "build" subdirectory for output files'  
2. Add *build/* to Bib(la)tex field, i.e., `bibtex build/%.aux`  
<img src="https://i.imgur.com/UYGjnaf.png" width="400"/>  

#### Use spell checking
Options > Configure Texmaker > Editor  
1. Fill in `/usr/share/hunspell/en_US.dic` to Spelling dictionary field  
<img src="https://i.imgur.com/0Nglk6W.png" width="400"/>  

### - Jabref
#### Add new entry to BibTex database
Both of following ways work:  
1. Ctrl + N  
2. Click the *New BibTeX entry* icon  
3. BibTeX > New entry  
<img src="https://i.imgur.com/cFeBytw.png" width="400"/>  
