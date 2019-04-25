echo -e "\e[1;36mGenerate Diff PDFs\e[0m"

cd diff/
python3 -m pipenv run python gen_diff.py
cd ../

echo -e "\e[1;36mDone\e[0m"
