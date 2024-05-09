# Create a CSV file from the binary database 
# Written by June Skeeter
# Basic test-call from command line:
    # py csvFromBinary.py --siteID BBS --dateRange "2023-06-01 00:00" "2024-05-31 23:59"
# Call with user defined request file (s)
    # py csvFromBinary.py --siteID BBS --dateRange "2023-06-01 00:00" "2024-05-31 23:59" --requests C:/path_to/request1.yml C:/path_to/request2.yml
# Can also call from other python scripts, using this general syntax:
    # import csvFromBinary as cfb
    # cfb.makeCSV(siteID="BBS",dateRange=["2023-06-01 00:00","2024-05-31 23:59"],requests=["config_files/csv_requests_template.yml"])


import os
import sys
import yaml # Note: you need to install the "pyyaml" package, e.g., pip install pyyaml
import argparse
import numpy as np
import pandas as pd

os.chdir(os.path.split(__file__)[0])

def set_user_configuration(user_defined=[]):
    # Parse the config settings
    with open('config_files/config.yml') as yml:
        config = yaml.safe_load(yml)

    # Append the user path configuration
    user_defined.append('config_files/user_path_definitions.yml')

    # Import the user specified configurations (exit if they don't exist)
    for req in user_defined:
        if os.path.isfile(req):
            with open(req) as yml:
                config.update(yaml.safe_load(yml))
        else:
            sys.exit(f"Missing {req}")
    return(config)

# Create the csv
def makeCSV(siteID,dateRange,requests=['csv_requests_template.yml']):
    print(f'Initializing requests for {siteID} over:', dateRange) 
    config = set_user_configuration(requests)
    Range_index = pd.DatetimeIndex(dateRange)
     
    # Years to process
    Years = range(Range_index.year.min(),Range_index.year.max()+1)
    # Root directory of the database
    root = config['RootDirs']['Database']
    for name,details in config['requests'].items():
        
        # Create a dict of traces
        traces={}
        # Create a list of column header - unit tuples
        # Only used if units_in_header set to True
        columns = []
        # Create a blank dataframe
        df = pd.DataFrame()
        
        file = f"{siteID}/{details['stage']}/{config['dbase_metadata']['timestamp']['name']}"
        tv = np.concatenate(
            [np.fromfile(f"{root}{YYYY}/{file}",config['dbase_metadata']['timestamp']['dtype']) for YYYY in Years],
            axis=0)
        DT = pd.to_datetime(tv-config['dbase_metadata']['timestamp']['base'],unit=config['dbase_metadata']['timestamp']['base_unit']).round('S')
        traces['timestamp'] = DT.floor('Min').strftime(details['formatting']['timestamp']['fmt'])
        # Add name-unit pairs to column header list
        columns.append(
            (details['formatting']['timestamp']['output_name'],
             details['formatting']['timestamp']['units'])
             )
        # Loop through race list for request
        for trace_name,trace_info in details['traces'].items():
            # if exists (over full period) output
            try:
                file = f"{siteID}/{details['stage']}/{trace_name}"
                trace = [np.fromfile(f"{root}{YYYY}/{file}",config['dbase_metadata']['traces']['dtype']) for YYYY in Years]
                traces[trace_info['output_name']]=np.concatenate(trace,axis=0)
            # give NaN if traces does not exist
            except:
                print(f"{trace_name} missing, outputting NaNs")
                traces[trace_info['output_name']]=np.empty(tv.shape)*np.nan
             # Add name-unit pairs to column header list
            columns.append((trace_info['output_name'],trace_info['units']))
        # dump traces to dataframe
        df = pd.DataFrame(data=traces,index=DT)
        # limit to requested timeframe
        df = df.loc[((df.index>=Range_index.min())&(df.index<= Range_index.max()))]
        # Add units to header (preferred) or exclude (dangerous)
        if details['formatting']['units_in_header'] == True:
            df.columns = pd.MultiIndex.from_tuples(columns)
        else:
            df.columns = [c[0] for c in columns]
        # Use specified NaN value
        df = df.fillna(details['formatting']['na_value'])

        # Format filename and save output
        dates = Range_index.strftime('%Y%m%d%H%M')
        fn = f"{siteID}_{name}_{dates[0]}_{dates[1]}"
        outputPath = config['RootDirs']['Outputs']
        df.to_csv(f"{outputPath}/{fn}.csv",index=False)

        print(f'See output: {outputPath}/{fn}.csv')
    print('All requests completed successfully')

# If called from command line ...
if __name__ == '__main__':
    
    # Parse the arguments
    CLI=argparse.ArgumentParser()
    
    CLI.add_argument(
    "--siteID", 
    nargs="?",# Use "?" to limit to one argument instead of list of arguments
    type=str,
    default='BB',
    )

    CLI.add_argument(
    "--dateRange", 
    nargs='+', # 1 or more values expected => creates a list
    type=str,
    default=[],
    )
        
    CLI.add_argument(
    "--requests", 
    nargs='+',
    type=str,
    default=['config_files/csv_requests_template.yml'],
    )

    args = CLI.parse_args()
    makeCSV(args.siteID,args.dateRange,args.requests)