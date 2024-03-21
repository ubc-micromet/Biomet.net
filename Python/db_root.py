# Find the database root path
# Written by June Skeeter March 2024

import os
import sys
import yaml
# To find database_default from inside (the root) of a project folder
def get_matlab_default(fn):
    # Read .m file as "text"
    with open(fn,encoding='utf8') as db:
        config = db.read()
        config = config.split('if ispc')[1].split('elseif ismac')
        # Identify system, translate Matlab to Python, and evaluate
        if sys.platform == 'win32':
            exec(config[0].replace('%','#').replace(' ','').replace('\\','/'))
        elif sys.platform == 'darwin':
            exec(config[1].replace('%','#').replace(' ','').replace('\\','/'))
    return(x)

def get_config(fn='_config.yml'):
    with open(fn) as f:
        config = yaml.safe_load(f)
    return(config['Database']['root'])

os.chdir('C:/Users/User')

config_fn = '_config.yml'
matlab_fn = 'biomet_database_default.m'

# 1 Search for _config.yml in root of Project Folder
if os.path.isfile(config_fn):
    db_root = get_config(config_fn)

# 2 Search for matalab default in root of project folder
elif os.path.isfile('Matlab/'+matlab_fn):
    db_root = get_matlab_default('Matlab/'+matlab_fn)

# 3 Search environment variables for UBC_PC_Setup
# Repeat 1 & 2, prompt for input as last resort
else:
    pth = [v for v in os.environ.values() if 'UBC_PC_Setup' in v]
    if len(pth)>0:
        if os.path.isfile(pth[0]+config_fn):
            db_root = get_config(pth[0]+config_fn)
        elif os.path.isfile(pth[0]+matlab_fn):
            db_root = get_matlab_default(pth[0]+matlab_fn)
    else:
        db_root = input('No default database path found, input path to database:')

