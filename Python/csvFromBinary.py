# Create a CSV file from the binary database 
# Written by June Skeeter

# Basic test-call from command line:
    # py csvFromBinary.py --siteID BBS --dateRange "2023-06-01 00:00" "2024-05-31 23:59"
# Call with user defined request file (s)
    # py csvFromBinary.py --siteID BBS --dateRange "2023-06-01 00:00" "2024-05-31 23:59" --requests C:/path_to/request1.yml C:/path_to/request2.yml
# Can also call from other python scripts, using this general syntax:
    # import csvFromBinary as cfb
    # cfb.makeCSV(siteID="BBS",dateRange=["2023-06-01 00:00","2024-05-31 23:59"],requests=["config_files/csv_requests_template.yml"])

# Default behavior (for now) is to read second stage files

# Setup the config files for your environment accordingly before running

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
        if os.path.isfile('config_files/user_path_definitions.yml'):
            with open('config_files/user_path_definitions.yml') as yml:
                config.update(yaml.safe_load(yml))
        else:
            sys.exit(f"Missing {'config_files/user_path_definitions.yml'}")

    # Import the user specified configurations (exit if they don't exist)
    config['requests'] = {}
    for req in user_defined:
        if os.path.isfile(req):
            with open(req) as yml:
                config['requests'].update(yaml.safe_load(yml))
        else:
            sys.exit(f"Missing {req}")

    return(config)

# Create the csv
# args with "None" value provide option to overwrite default
def makeCSV(siteID,dateRange,requests=['config_files/csv_requests_template.yml'],stage=None,outputPath=None):
    print(f'Initializing requests for {siteID} over:', dateRange) 
    config = set_user_configuration(requests)
    Range_index = pd.DatetimeIndex(dateRange)
    
    # Use default if user does not provide alternative
    if outputPath is None:
        outputPath = config['RootDirs']['Outputs']

    # Years to process
    Years = range(Range_index.year.min(),Range_index.year.max()+1)
    # Root directory of the database
    root = config['RootDirs']['Database']
    for name,details in config['requests'].items():

        if stage is not None:
            details['stage']=stage
        
        # Create a dict of traces
        traces={}
        # Create a list of column header - unit tuples
        # Only used if units_in_header set to True
        columns_tuple = []
        # Create a blank dataframe
        df = pd.DataFrame()
        
        file = f"{siteID}/{details['stage']}/{config['dbase_metadata']['timestamp']['name']}"
        tv = np.concatenate(
            [np.fromfile(f"{root}{YYYY}/{file}",config['dbase_metadata']['timestamp']['dtype']) for YYYY in Years],
            axis=0)
        DT = pd.to_datetime(tv-config['dbase_metadata']['timestamp']['base'],unit=config['dbase_metadata']['timestamp']['base_unit']).round('S')

        for time_trace,formatting in details['formatting']['time_vectors'].items():
            traces[time_trace] = DT.floor('Min').strftime(formatting['fmt'])
            # Add name-unit pairs to column header list
            columns_tuple.append(
                (formatting['output_name'],
                formatting['units'])
                )
        # Loop through race list for request
        for trace_name,trace_info in details['traces'].items():
            # if exists (over full period) output
            try:
                file = f"{siteID}/{details['stage']}/{trace_name}"
                trace = [np.fromfile(f"{root}{YYYY}/{file}",config['dbase_metadata']['traces']['dtype']) for YYYY in Years]
                traces[trace_name]=np.concatenate(trace,axis=0)
            # give NaN if traces does not exist
            except:
                print(f"{trace_name} missing, outputting NaNs")
                traces[trace_name]=np.empty(tv.shape)*np.nan
             # Add name-unit pairs to column header list
            columns_tuple.append((trace_info['output_name'],trace_info['units']))
        # dump traces to dataframe
        df = pd.DataFrame(data=traces,index=DT)
        # limit to requested timeframe
        df = df.loc[((df.index>=Range_index.min())&(df.index<= Range_index.max()))]

        # Apply optional resampling 
        # Add units to header (preferred) or exclude (dangerous)
        if details['formatting']['units_in_header'] == True:
            df.columns = pd.MultiIndex.from_tuples(columns_tuple)
        else:
            df.columns = [c[0] for c in columns_tuple]

        if 'resample' in details['formatting']:
            ### Finish stuff here
            aggregation = details['formatting']['resample']['agg'].split(',')
            # Text and numeric data must be treated differently
            # For text dates, get the first value
            txt = df.columns[:len(details['formatting']['time_vectors'].keys())]
            rsmp = df[txt].resample(details['formatting']['resample']['freq']).agg('first')
            rsmp=rsmp.T.set_index(np.repeat('', rsmp.shape[1]), append=True).T

            # For numeric data, aggregate as desired
            num = df.columns[len(details['formatting']['time_vectors'].keys()):]
            rsmp2 = df[num].resample(details['formatting']['resample']['freq']).agg(aggregation)
            df = rsmp.join(rsmp2)
            # Drop aggregation defs if excluding units    
            if details['formatting']['units_in_header'] == False:
                df.columns = df.columns.get_level_values(0)

        # Set specified NaN value or drop from dataset
        if details['formatting']['na_value'] is None:
            df = df.dropna()
        else:
            df = df.fillna(details['formatting']['na_value'])

        # Format filename and save output
        dates = Range_index.strftime('%Y%m%d%H%M')
        fn = f"{siteID}_{name}_{dates[0]}_{dates[1]}"
        df.to_csv(f"{outputPath}/{fn}.csv",index=False)

        print(f'See output: {outputPath}/{fn}.csv')
    print('All requests completed successfully')

# If called from command line ...
if __name__ == '__main__':
    
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
    default=[(pd.Timestamp.now()-pd.Timedelta(days=30)).strftime('%Y%m%d'),
             pd.Timestamp.now().strftime('%Y%m%d')],
    )
        
    CLI.add_argument(
    "--requests", 
    nargs='+',
    type=str,
    default=['config_files/csv_requests_template.yml'],
    )
      
    CLI.add_argument(
    "--outputPath", 
    nargs='?',
    type=str,
    default=None,
    )

    # Parse the args and make the call
    args = CLI.parse_args()
    makeCSV(args.siteID,args.dateRange,args.requests,args.outputPath)