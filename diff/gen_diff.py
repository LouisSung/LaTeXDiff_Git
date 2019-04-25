"""LaTeX Diff PDF Generator

This script allows the user to generate diff-pdf
in order to distinguish between each version and user.

Commits on mater branch and start with 'Edit' and 'Review' will be processed.

This script requires 'git', 'latexdiff', and 'pdflatex' package.
"""
import binascii, git, os, shutil, subprocess, sys

# Parameters
os.chdir("../")    # move to parent dir
MAX_AUTHORS = 2
dir_diff = "diff/"
tex_paper = "Paper.tex"

# Preprocess target folders and file names
_dir_tmp = binascii.b2a_hex(os.urandom(16)).decode()    # tmp name for folders
dir_new = dir_diff + _dir_tmp + "/"
dir_old = dir_diff + _dir_tmp[::-1] + "/"
tex_new, tex_old = dir_new + tex_paper, dir_old + tex_paper

# Temporarily copy files
_ignore = shutil.ignore_patterns("build", "diff", "Pipfile*", ".gitignore")
for d in (dir_new, dir_old):
    shutil.copytree(src="./", dst=d, ignore=_ignore, copy_function=shutil.copy)

# Get repositories and commits
repo_new, repo_old = git.Repo(dir_new), git.Repo(dir_old)
commit = list(repo_new.iter_commits("master"))
commit.reverse()
_authors = {}

# Generate diff pdf
print("Start")
serial_num = 0
for i in range(len(commit)-1):
    print("\033[1mCommit ID\033[0m: " + str(i+1), end="")
    # check author
    author = commit[i+1].author
    if author not in _authors:
        _authors[author] = len(_authors) + 1

    # check commit message
    commit_msg = commit[i+1].message.splitlines()[0].replace(" ", "_")[:24]
    if not commit_msg.startswith(("Edit", "Review")):
        print(" -> Pass")
        continue
    else:
        serial_num += 1
        print(" -> \033[1;33m{0}-{1}.pdf\033[0m".format(serial_num, author)
              + "; \033[1mCommit message\033[0m: " + commit_msg)

    # checkout each version
    repo_new.git.checkout("-f", commit[i+1])
    repo_old.git.checkout("-f", commit[i])

    # specify target files
    tex_diff = "{0}{1}-{2}-{3}.tex".format(dir_new, serial_num,
                                           author, commit_msg)
    pdf_diff = tex_diff[:-3] + "pdf"

    # execute latexdiff and pdflatex
    with open(tex_diff, "w") as w_diff, open(os.devnull, "w") as null:
        subprocess.run(["latexdiff", "--flatten", tex_old, tex_new,
                        "-p", "{0}._p{1}.tex".format(
                            dir_diff, min(_authors[author], MAX_AUTHORS))
                        ], stdout=w_diff, stderr=null)
        # the first execution is for citation
        subprocess.run(["pdflatex", "-output-directory=" + dir_new, tex_diff],
                       stdout=null)
        subprocess.run(["pdflatex", "-output-directory=" + dir_new, tex_diff],
                       stdout=null)

    try:
        shutil.move(pdf_diff, dir_diff)
    except Exception as e:    # i.e., file already exists
        sys.stderr.write("\033[1;31mErr:\033[0;31m " + str(e) + "\033[0m\n")

# Remove tmp files
print("Complete")
shutil.rmtree(dir_new)
shutil.rmtree(dir_old)
