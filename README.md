# Tutorial for LaTeXDiff_Git
## About
### - Why
This tutorial is mainly for the course - *English for Science and Technology*, CS, NTHU.  
However, it doesn't restrict to this course but also for gernal purpose, either.  

### - What
Scripts including `*.sh` and `*.py` are written for *Bash* and *Python3* on ***Ubuntu 18.04 LTS*** respectively.  
These scripts aim to shorten your time on checking differences between each (git commit) version.  

### - How
The '.git/' in project-root folder will be cloned twice to do *git checkout -f* and *latexdiff* to prevent messing up your working.  
All files in subfolders will temporarily moved to 'diff-root folder' in order to do *latexdiff* during the process.  
  
`0_init.sh`: To set up required environment, including git config and package installation  
`1_gen_paper.sh`: To generate paper `.pdf` file from `.tex` using *pdflatex* and *bibtex*  
`2_gen_diff.sh`: To execute `gen_diff.py` with *pipenv* support  
`3_run_editor.sh`: To run JabRef or start *texmaker* with ENVs to support subfolders  
`diff/gen_diff.py`: To generate diff `.pdf` file between commits using *latexdiff* and *git*  

### - When
`0_init.sh`: For git-config part, run once for different projects; otherwise, once and for all  
`1_gen_paper.sh`: Each time you want to upadate pdf result  
`2_gen_diff.sh`: After git-commit with specific keywords in commit message  
`3_run_editor.sh`: Each time for running texmaker if using subfolders  
`diff/gen_diff.py`: Just sit and wait, i.e., do not run it manually  

### - Help
Pass `-h` as an argument to scripts to get further options, e.g., `0_init.sh -h`  
Demo video recording with subtitles in both en and zh_TW is also available on [YouTube](https://www.youtube.com/watch?v=YkKgXd8ifAQ&cc_load_policy=1).  

### - Constraints
In this project, there are some constrains so that you could avoid process all of the commits.  
Only commits that meet the following constraints will be processed:  
1. On `master` branch; therefore, allow you to have *detail commits* on the other branches.  
2. Message start with `"Edit"` and `"Review"`; therefore, allow you to have *non-edit commits*, e.g., update readme.  

Note that these constraints could be changed by given correspond options, i.e., `-b BRANCH` and `-k KEYWORD`.  

### - Limitation
Due to the limitation of *latexdiff* and latex itself, some recommendations are offered:  
1. Do not having files with *same name* in *different folders*.  
`E.g., 'abc/file.tex' and 'xyz/file.tex' must not be in the same project`  
2. *Comments* in latex won't be treated as *differences*, use it carefully.  
`Both comments followed by '%' and between '\iffalse \fi' won't be processed`  
`Refer commit '0c572b3' and file 'diff/5-Zapdos-Review_author.pdf' in this repository`  

### - License
This project is licensed upder the MIT License (aka MadeInTaiwan License ฅ• ω •ฅ).  
So feel free to modify it to your own version if needed.  
Also feel free to contact me if having any comments.  

## Environment Setup
### 1. Code clone
```bash
git clone https://github.com/LouisSung/LaTeXDiff_Git
cd LaTeXDiff_Git/
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
# Prerequisite: Python3, (pip3, Pipenv), and GitPython
# Target: diff/([1-9][0-9]*-USER-COMMIT_MSG.pdf)*
./2_gen_diff.sh
```

### - Run Editor
```bash
# Prerequisite: Texmaker (and JabRef)
./3_run_editor.sh
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
#### Build steps
*Quick Build* > *BibTeX* > *Quick Build* > *Quick Build*  
(Do not use *LaTeX*, use *Quick Build* or *PDFLaTeX* instead)  

#### Use 'build' folder
Options > Configure Texmaker > Commands  
1. Select the 'Use a "build" subdirectory for output files' checkbox  
2. Add [ build/ ] to Bib(la)tex field, i.e., `bibtex build/%.aux`   
<img src="https://i.imgur.com/UYGjnaf.png" width="400"/>  

#### Enable spell checking
Options > Configure Texmaker > Editor  
1. Fill in `/usr/share/hunspell/en_US.dic` to 'Spelling dictionary' field  
<img src="https://i.imgur.com/0Nglk6W.png" width="400"/>  

### - JabRef
#### Add new entry to BibTeX database
Both of following ways work:  
1. Ctrl + N  
2. Click the *New BibTeX entry* icon  
3. BibTeX > New entry  
<img src="https://i.imgur.com/cFeBytw.png" width="400"/>  
