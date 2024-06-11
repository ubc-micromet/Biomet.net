# Read configuration file(s) for python based tasks
# Intended to be called by other scripts, not called by user directly
# Written by June Skeeter

import os
import sys
import yaml # Note: you need to install the "pyyaml" package, e.g., pip install pyyaml
import argparse

os.chdir(os.path.split(__file__)[0])

def set_user_configuration(user_defined=[]):
    # Parse the config settings
    with open('config_files/config.yml') as yml:
        config = yaml.safe_load(yml)
        if os.path.isfile('config_files/user_path_definitions.yml'):
            with open('config_files/user_path_definitions.yml') as yml:
                config.update(yaml.safe_load(yml))
        else:
            sys.exit(f"Missing {'config_files/user_path_definitions.yml'}")

    # Import the user specified configurations (exit if they don't exist)
    config['tasks'] = {}
    for req in user_defined:
        if os.path.isfile(req):
            with open(req) as yml:
                config['tasks'].update(yaml.safe_load(yml))
        else:
            sys.exit(f"Missing {req}")
    return(config)

# If called from command line ...
if __name__ == '__main__':
    
    CLI=argparse.ArgumentParser()

    CLI.add_argument(
        "--tasks", 
        nargs='+',
        type=str,
        default=[],
        )

    # Parse the args and make the call
    args = CLI.parse_args()

    set_user_configuration(args.tasks)