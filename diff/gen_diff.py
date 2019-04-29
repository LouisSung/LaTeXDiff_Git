"""LaTeX Diff PDF Generator

This script allows the user to generate diff-pdf
in order to distinguish between each version and user.

Commits on mater branch and start with 'Edit' and 'Review' will be processed.

This script requires 'git', 'latexdiff', 'bibtex', and 'pdflatex' package.
"""
try:
    import binascii, git, os, pathlib, shutil, subprocess, sys
except ModuleNotFoundError:
    import subprocess
    subprocess.run(["pipenv", "install"])
    import binascii, git, os, pathlib, shutil, sys

__author__ = "Louis Sung"
__copyright__ = "Copyright © 2019 LouisSung. All rights reserved."
__license__ = "MIT"
__version__ = "1.1"

# Get all args and move to project-root
_args = dict(zip(sys.argv[1::2], sys.argv[2::2]))    # read options into dict
dir_preamble = os.getcwd() + "/"
if "-p" in _args:
    (_py_path, _py_depth) = os.path.dirname(_args["-p"]), 0
    while(_py_path not in (".", "")):
        (_py_path, _py_depth) = os.path.dirname(_py_path), _py_depth + 1
    if _py_depth > 0:
        os.chdir("../" * _py_depth)
else:
    os.chdir("../")    # default in folder diff/

# Parameters
dir_target = _args.get("-t", "diff/")
tex_paper = _args.get("-m", "Paper") + ".tex"
KEYWORD = _args.get("-k", "").split(",") + ["Edit", "Review"]
KEYWORD = [x for x in KEYWORD if x != ""]    # remove empty string
ITER_BRANCH = _args.get("-b", "master")
MAX_AUTHORS = int(_args.get("-a", "2"))
START_COMMIT_NUM = int(_args.get("-c", "1")) - 1
set_env = "export TEXINPUTS=.//:;export BIBINPUTS=.//:;export BSTINPUTS=.//:"

# Preprocess target folders and file names
_tmp = binascii.b2a_hex(os.urandom(4)).decode()    # tmp name for folders
(dir_new, dir_old) = dir_target + _tmp + "/", dir_target + _tmp[::-1] + "/"
(tex_new, tex_old) = dir_new + tex_paper, dir_old + tex_paper

# Copy repository temporarily
for d in (dir_new, dir_old):
    shutil.copytree(src="./.git/", dst=d + ".git/")

# Get repositories and commits
(repo_new, repo_old) = git.Repo(dir_new), git.Repo(dir_old)
commit = list(repo_new.iter_commits(ITER_BRANCH))
commit.reverse()
_authors = {}

# Generate diff pdf
print("Start")
(serial_num, _digits) = 0, len(str(len(commit)))
for i in range(len(commit)-1):
    print("\033[1mCommit {}\033[0m".format(str(i+1).zfill(_digits)), end="")
    # check author and remove all no-alnum char
    author = "".join(x for x in str(commit[i+1].author) if x.isalnum())
    if author not in _authors:
        _authors[author] = len(_authors) + 1

    # check commit message
    commit_msg = "".join(x if x.isalnum() else "_"
                         for x in commit[i+1].message.splitlines()[0])[:24]
    if not commit_msg.startswith(tuple(KEYWORD)):
        print(" -> Pass; \033[1mCommit message\033[0m: " + commit_msg)
        continue
    else:
        serial_num += 1
        print(" -> \033[1;33m{0}-{1}.pdf\033[0m".format(serial_num, author)
              + "; \033[1mCommit message\033[0m: " + commit_msg)
        preamble = "{0}._p{1}.tex".format(
            dir_preamble, min(_authors[author], MAX_AUTHORS))
    if i < START_COMMIT_NUM:
        continue

    # checkout each version
    repo_new.git.checkout("-f", commit[i+1])
    repo_old.git.checkout("-f", commit[i])

    # specify target files
    file_diff = "{0}-{1}-{2}".format(serial_num, author, commit_msg)

    # execute latexdiff and pdflatex
    with open(os.devnull, "w") as null:
        if "-v" in _args:
            o = [sys.stdout if str(i+1) in _args["-v"] else null
                 for i in range(7)]
        else:
            o = [null]*7
        # generate old & new bbl files
        subprocess.run("cd {0}; {1}; pdflatex {2}".format(
            dir_new, set_env, tex_paper), shell=True, stdout=o[0])
        subprocess.run("cd {0}; {1}; bibtex {2}".format(
            dir_new, set_env, tex_paper[:-3] + "aux"), shell=True, stdout=o[1])
        subprocess.run("cd {0}; {1}; pdflatex {2}".format(
            dir_old, set_env, tex_paper), shell=True, stdout=o[2])
        subprocess.run("cd {0}; {1}; bibtex {2}".format(
            dir_old, set_env, tex_paper[:-3] + "aux"), shell=True, stdout=o[3])

        # generate diff tex
        with open(dir_new + file_diff + ".tex", "w") as w_diff:
            # move all files to tmp-root directory
            for d in (dir_new, dir_old):
                for ext in ("tex", "cls", "bbl"):
                    for file in pathlib.Path(d).rglob("*." + ext):
                        if str(file.parent) != d[:-1]:
                            shutil.move(os.path.join(str(file)),
                                        os.path.join(d, file.name))
            subprocess.run("latexdiff --flatten -p {0} {1} {2} {3}".format(
                preamble, tex_old, tex_new, "" if o[4] == null else "-V"),
                shell=True, stdout=w_diff, stderr=o[4])

        # generate diff pdf
        subprocess.run("cd {0}; pdflatex -interaction=nonstopmode {1}".format(
            dir_new, file_diff + ".tex"), shell=True, stdout=o[5])
        subprocess.run("cd {0}; pdflatex -interaction=nonstopmode {1}".format(
            dir_new, file_diff + ".tex"), shell=True, stdout=o[6])

    try:
        shutil.move(dir_new + file_diff + ".pdf", dir_target)
    except Exception as e:    # i.e., file already exists
        print("\033[1;31mWarning:\033[0;31m " + str(e) + "\033[0m")

# Remove tmp files
print("Complete")
shutil.rmtree(dir_new)
shutil.rmtree(dir_old)
