"""LaTeX Diff PDF Generator

This script allows the user to generate diff-pdf
in order to distinguish between each version and user.

Commits on mater branch and start with 'Edit' and 'Review' will be processed.

This script requires 'git', 'latexdiff', 'bibtex', and 'pdflatex' package.
"""
import binascii, git, os, shutil, subprocess

__author__ = "Louis Sung"
__copyright__ = "Copyright © 2019 LouisSung. All rights reserved."

# Parameters
os.chdir("../")    # move to parent dir
MAX_AUTHORS = 2
dir_diff = "diff/"
tex_paper = "Paper.tex"

# Preprocess target folders and file names
_tmp = binascii.b2a_hex(os.urandom(4)).decode()    # tmp name for folders
(dir_new, dir_old) = dir_diff + _tmp + "/", dir_diff + _tmp[::-1] + "/"
(tex_new, tex_old) = dir_new + tex_paper, dir_old + tex_paper

# Temporarily copy files
_ignore = shutil.ignore_patterns("build", "diff", "Pipfile*", ".gitignore")
for d in (dir_new, dir_old):
    shutil.copytree(src="./", dst=d, ignore=_ignore, copy_function=shutil.copy)

# Get repositories and commits
(repo_new, repo_old) = git.Repo(dir_new), git.Repo(dir_old)
commit = list(repo_new.iter_commits("master"))
commit.reverse()
_authors = {}

# Generate diff pdf
print("Start")
(serial_num, _digits) = 0, len(str(len(commit)))
for i in range(len(commit)-1):
    print("\033[1mCommit {}\033[0m".format(str(i+1).zfill(_digits)), end="")
    # check author
    author = commit[i+1].author
    if author not in _authors:
        _authors[author] = len(_authors) + 1

    # check commit message
    commit_msg = commit[i+1].message.splitlines()[0].replace(" ", "_")[:24]
    if not commit_msg.startswith(("Edit", "Review")):
        print(" -> Pass; \033[1mCommit message\033[0m: " + commit_msg)
        continue
    else:
        serial_num += 1
        print(" -> \033[1;33m{0}-{1}.pdf\033[0m".format(serial_num, author)
              + "; \033[1mCommit message\033[0m: " + commit_msg)
        preamble = "{0}._p{1}.tex".format(
            dir_diff, min(_authors[author], MAX_AUTHORS))

    # checkout each version
    repo_new.git.checkout("-f", commit[i+1])
    repo_old.git.checkout("-f", commit[i])

    # specify target files
    file_diff = "{0}-{1}-{2}".format(serial_num, author, commit_msg)

    # execute latexdiff and pdflatex
    with open(os.devnull, "w") as null:
        # generate old & new bbl files
        subprocess.run("cd {0}; pdflatex {1}".format(
            dir_new, tex_paper), shell=True, stdout=null)
        subprocess.run("cd {0}; bibtex {1}".format(
            dir_new, tex_paper[:-3] + "aux"), shell=True, stdout=null)
        subprocess.run("cd {0}; pdflatex {1}".format(
            dir_old, tex_paper), shell=True, stdout=null)
        subprocess.run("cd {0}; bibtex {1}".format(
            dir_old, tex_paper[:-3] + "aux"), shell=True, stdout=null)

        # generate diff tex
        with open(dir_new + file_diff + ".tex", "w") as w_diff:
            subprocess.run("latexdiff --flatten -p {0} {1} {2}".format(
                "{0}._p{1}.tex".format(
                    dir_diff, min(_authors[author], MAX_AUTHORS)),
                tex_old, tex_new), shell=True, stdout=w_diff, stderr=null)

        # generate diff pdf
        subprocess.run("cd {0}; pdflatex -interaction=nonstopmode {1}".format(
            dir_new, file_diff + ".tex"), shell=True, stdout=null)
        subprocess.run("cd {0}; pdflatex -interaction=nonstopmode {1}".format(
            dir_new, file_diff + ".tex"), shell=True, stdout=null)

    try:
        shutil.move(dir_new + file_diff + ".pdf", dir_diff)
    except Exception as e:    # i.e., file already exists
        print("\033[1;31mWarning:\033[0;31m " + str(e) + "\033[0m")

# Remove tmp files
print("Complete")
shutil.rmtree(dir_new)
shutil.rmtree(dir_old)
