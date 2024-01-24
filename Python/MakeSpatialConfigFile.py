
from io import TextIOWrapper
import configparser
import argparse
import zipfile
import os

def from_GHG(site_code,file,start_year,output_path):
    GHG_metadata = configparser.ConfigParser()
    with zipfile.ZipFile(file, 'r') as ghgZip:
        # Read the metadata file
        file_list = ghgZip.namelist()
        for file in file_list:
            if file.endswith('.metadata') and file.endswith('biomet.metadata') == False:
                f = TextIOWrapper(ghgZip.open(file), 'utf-8')
                GHG_metadata.read_file(f)
        for file in file_list:
            if file.endswith('.data') and file.endswith('biomet.data') == False:
                with ghgZip.open(file) as Data_file:
                    Header = '[Data_Header]\n'+''.join(next(Data_file).decode('utf-8') for _ in range(int(GHG_metadata['FileDescription']['header_rows'])-1))+'\n'
                GHG_metadata.read_string(Header)
            
    template = configparser.ConfigParser()
    template.read('ini_files/templates/site_configurations.ini')
    template.add_section(site_code)
    for key, val in template['Site'].items():
        template['Site'][key] = eval(val)
    items = template.items('Site')
    for item in items:
        template.set(site_code,str(item[0]),str(item[1]))
    template.remove_section('Site')

    # with open(f'ini_files/site_configurations/{site_code}.ini','w+') as file:
    with open(f'{output_path}{site_code}.ini','w+') as file:
        template.write(file)
         
if __name__ == '__main__':


    CLI=argparse.ArgumentParser()
    
    CLI.add_argument(
        "--site", 
        nargs=1,  
        type=str,
        default='None',  
        )
        

    CLI.add_argument(
        "--GHG",  
        nargs=1, 
        type=str,
        default='None', 
        )
    
    args = CLI.parse_args()
        
    if args.site != 'None' and args.GHG != 'None':
        from_GHG(args.site[0],args.GHG[0])