# Python Code for UBC Micromet

## Example Call

**Note** depending on how your computer is setup, you can call python in different ways (py, py3, python).  On vinimet for example, you use python instead of py

Read data from all google sheets listed in '\ini_files\WriteTraces_GSheets.ini' and write to the database

```
py .\DatabaseFunctions.py --Task GSheetDump

```

Create biomet.csv files for sites for 2024:

```
python .\DatabaseFunctions.py --Task CSVDump --Sites BBS --Years 2024

```

Create biomet.csv files for all years for BB:

```
py .\DatabaseFunctions.py --Task CSVDump --Sites BB

```

## Contents

1. DatabaseFunctions.py

2. ExtractNARR.py

3. TzFuncs.py

# Setup

For best results, you should use Python 3.10 or higher and run this code in a virtual environment

* Its is not explicitly required to use virtual environments, but it is good practice to ensure all dependencies are met and you don't corrupt your base Python installation
* The root folder "Biomet.Net/Python" has a "requirement.txt" which lists the packages installed in the virtual environment
    * To install the packages, you can follow the steps listed below
    * It is best to do this in a dedicated virtual environment so you don't run into any conflicts with pre-existing installations in your main python environment.
    * See the instructions below to create a generic virtual environment with pip
## Create a virtual environment

### Using Visual Studio (VS) Code

If you have VS Code installed, with the python extension, you can:

1. Open the Biomet.Net\Python folder in VS Code
2. Hit ctrl + shift + p > and select "Create Python Environment"
    * Use Venv, not conda
3. You will be prompted to select dependencies to install
    * Select "requirements.txt" form the menu.  This will automatically install all required packages for you.

### Windows setup

This assumes you have Biomet.Net in "C:\"

1. cd C:\Biomet.Net\Python\

2. py -m venv .venv

3. .\.venv\Scripts\activate

4. pip install -r .\requirements.txt

### macOS/Linux setup

This assumes you have Biomet.Net in "/home/"

1. cd /home/Biomet.Net/Python/

2. python3 -m venv .venv

3. source ./.venv/bin/activate

4. pip install -r ./requirements.txt

# Creating a New Application

1. Create a new program or open an existing one in Biomet.Net\Python

2. Write/update code and install any necessary packages.  **Make sure** you work in the .venv

3. Update the README.md file :D

4. If any new packages are installed for a given application and you plan to push it to github, you can update the "requirements.txt" file with this command from within the MicrometPy folder:

    * pip freeze > requirements.txt

    * If it fails, try this instead:

        * python -m pip freeze > requirements.txt

5. Push to you own branch of Biomet.Net on github then submit a pull request


