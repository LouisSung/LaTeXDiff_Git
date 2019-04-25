EXECUTE="\e[1;36m>>>\e[0m"
yes_or_no (){
    while true; do
        read -e -p "$1" -i "$2" yn
        case $yn in
            [Yy] ) echo "y"; break;;
            [Nn] ) echo "n"; break;;
            * ) echo "Err: Please answer y/n." >&2;;    # echo to stderr
        esac
    done
}

# === For Git config ===
while true; do
    read -e -p "Enter user name for git: " name; [[ ! -z $name ]] && break; done
echo -e "$EXECUTE git config user.name \"$name\""
git config user.name "$name"

while true; do
    read -e -p "Enter user email for git: " email; [[ ! -z $email ]] && break; done
echo -e "$EXECUTE git config user.email $email"
git config user.email $email

echo -e "$EXECUTE git config pull.rebase true"    # to use "git pull --rebase" by default
git config pull.rebase true

# === For LaTeX ===
if [ $(yes_or_no "Install TexLive-Science (SW distribution for TeX) [Y/n]? " "y") = "y" ]; then
    echo -e "$EXECUTE sudo apt install texlive-science"
    sudo apt install texlive-science; fi
if [ $(yes_or_no "Install Lx-atexdiff (To generate diff PDFs) [Y/n]? " "y") = "y" ]; then
    echo -e "$EXECUTE sudo apt install latexdiff"
	sudo apt install latexdiff; fi
if [ $(yes_or_no "Install Texmaker (Open-source LaTeX editor) [Y/n]? " "y") = "y" ]; then
    echo -e "$EXECUTE sudo apt install texmaker"
	sudo apt install texmaker; fi
# === For Python ===
if [ $(yes_or_no "Install pip3 (The Python Package Installer) [y/N]? " "n") = "y" ]; then
    echo -e "$EXECUTE sudo apt install python3-pip"
	sudo apt install python3-pip; fi
if [ $(yes_or_no "Install Pipenv (Virtual environment for Python) [y/N]? " "n") = "y" ]; then
    echo -e "$EXECUTE pip3 install pipenv"
	python3 -m pip install --user pipenv; fi
# === For Pipenv init ===
if [ $(yes_or_no "Init pipenv (For gen_diff.py) [Y/n]? " "y") = "y" ]; then
    echo -e "$EXECUTE pipenv install"
	cd diff/; python3 -m pipenv install; cd ../; fi
