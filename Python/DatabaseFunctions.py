import os
import yaml
import db_root as db
import numpy as np
import pandas as pd
import datetime as dt
import argparse
import datetime
import shutil
import pathlib
import sys
import TzFuncs
import time
import json



class DatabaseFunctions():

    def __init__(self,ini=[]):
        self.db_root = db.db_root
        self.db_ini = db.db_ini
        print('Initialized using db_root: ', self.db_root)
        # Read base config 
        with open(f'{self.db_ini}_config.yml') as f:
            self.ini = yaml.safe_load(f)
            print(f'Loaded {self.db_ini}_config.yml')
        # Read user provided configuration(s)
        for f_in in ini:
            if os.path.isfile(f'{self.db_ini}{f_in}'):
                with open(f'{self.db_ini}{f_in}') as f:
                    yml_in = {f_in.split('.')[0]:yaml.safe_load(f)}
                    self.ini.update(yml_in)
                    print(f'Loaded {self.db_ini}{f_in}')
        self.find_Sites()

    def find_Sites(self):
        self.years_by_site = {}
        for f in os.listdir(self.db_ini):
            if f.startswith('_') == False:
                self.years_by_site[f] = []
        for y in os.listdir(self.db_root):
            if y[0].isdigit():
                for site in self.years_by_site.keys():
                    if os.path.isdir(f'{self.db_root}/{y}/{site}'):
                        self.years_by_site[site].append(y)

    def read_db(self,siteID,Years,stage,trace_names):
        tv_info = self.ini['Database']['Timestamp']
        tr_info = self.ini['Database']['Traces']
        tv = [np.fromfile(f'{self.db_root}{y}/{siteID}/{stage}/{tv_info["name"]}',tv_info['dtype']) for y in Years]
        tv = np.concatenate(tv,axis=0)
        DT = pd.to_datetime(tv-tv_info['base'],unit=tv_info['base_unit']).round('S')
        traces={}        
        for f in trace_names:
            try:
                trace = [np.fromfile(f'{self.db_root}{y}/{siteID}/{stage}/{f}',tr_info['dtype']) for y in Years]
                traces[f]=np.concatenate(trace,axis=0)
            except:
                traces[f]=np.empty(tv.shape)*np.nan
        self.data = pd.DataFrame(data=traces,index=DT)

        
    def sub(self,s):
        for path in self.ini['Shortcuts'].keys():
            s = s.replace(path.upper(),self.ini['Shortcuts'][path])
        for key,value in {'YEAR':self.Year,'SITEID':self.siteID}.items():
            if key in s:
                s = s.replace(key,str(value))
        return(s)

    def dateIndex(self):
        date_cols = [i for i in self.ini[self.batch]['date_cols'].split(',')]
        if self.ini[self.batch]['date_Fmt'] == 'Auto':
            Date_col = date_cols[0]
            self.Data[Date_col] = pd.DatetimeIndex(self.Data[Date_col])
            self.Data = self.Data.set_index(Date_col)
        elif self.ini[self.batch]['date_Fmt'] != '':
            self.Data['Timestamp'] = ''
            for col in self.ini[self.batch]['date_cols'].split(','):
                try:
                    ix = self.ini[self.batch]['Header_list'].split(',').index(col)
                    unit = self.ini[self.batch]['Header_units'].split(',')[ix]
                    if unit.upper() == 'HHMM':
                        self.Data.loc[self.Data[col]==2400,col]=0
                    self.Data['Timestamp'] = self.Data['Timestamp'].str.cat(self.Data[col].astype(str).str.zfill(len(unit)),sep='')
                except:
                    self.Data['Timestamp'] = self.Data['Timestamp'].str.cat(self.Data[col].astype(str),sep='')
                self.Data = self.Data.drop(col,axis=1)
            self.Data['Timestamp'] = pd.to_datetime(self.Data['Timestamp'],format=self.ini[self.batch]['date_Fmt'])
            self.Data = self.Data.set_index('Timestamp')
        if self.ini[self.batch]['is_dst'] == 'True':
            lat_lon=[float(self.ini[self.siteID]['latitude']),float(self.ini[self.siteID]['longitude'])]
            tzf = TzFuncs.Tzfuncs(lat_lon=lat_lon,DST=True)
            tzf.convert(self.Data.index)
            self.Data = self.Data.set_index(tzf.Standard_Time)

        self.Aggregate()
        self.Data=self.Data.resample('30T').first()

    def Aggregate(self):
        if self.ini[self.batch]['aggregate']!='':
            self.Data = self.Data.agg(self.ini[self.batch]['aggregate'].split(','),axis=1)

    def padFullYear(self):
        for self.y in self.Data.index.year.unique():
            self.Year = pd.DataFrame(data={'Timestamp':pd.date_range(start = f'{self.y}01010030',end=f'{self.y+1}01010001',freq='30T')})
            self.Year = self.Year.set_index('Timestamp')
            self.Year = self.Year.join(self.Data)
            
            d_1970 = datetime.datetime(1970,1,1,0,0)
            self.Year['Floor'] = self.Year.index.floor('D')
            self.Year['Secs'] = ((self.Year.index-self.Year['Floor']).dt.seconds/ (24.0 * 60.0 * 60.0))
            self.Year['Days'] = ((self.Year.index-d_1970).days+int(self.ini['Database']['datenum_base']))

            self.Year[self.ini['Database']['timestamp']] = self.Year['Secs']+self.Year['Days']
            self.Year = self.Year.drop(columns=['Floor','Secs','Days'])
            self.Write_Trace()

    def Write_Trace(self):
        self.write_dir = self.sub(f'{self.db_root}/YEAR/SITE/')+self.ini[self.batch]['subfolder']
        if os.path.isdir(self.write_dir)==False:
            print('Creating new directory at:\n', self.write_dir)
            os.makedirs(self.write_dir)

        for T in self.Year.columns:
            if T == self.ini['Database']['timestamp']:
                fmt = self.ini['Database']['timestamp_dtype']
            else:
                fmt = self.ini['Database']['trace_dtype']
            try:
                Trace = self.Year[T].astype(fmt).values
                del_chars = '()<>:"\|?'
                for c in del_chars:
                    T = T.replace(c,'')
                T = T.replace('*','star').replace('/','_')
                if self.ini[self.batch]['prefix']!='' and T != self.ini['Database']['timestamp']:
                    T = self.ini[self.batch]['prefix'] + '_' + T
                if self.ini[self.batch]['suffix']!='' and T != self.ini['Database']['timestamp']:
                    T += '_' + self.ini[self.batch]['suffix']
                with open(f'{self.write_dir}/{T}','wb') as out:
                    Trace.tofile(out)
            except:
                print(f'Could not write column: {T}')

    def copy_raw_data_files(self,dir=None,file=None,format='dat'):
        copy_to = self.sub(self.ini['Paths']['sites'])
        if os.path.isdir(copy_to) == False:
            print('Warning: ',copy_to,' Does not exist.  Ensure this is the correct location to save then create the folder before proceeding.')
            sys.exit()
        elif os.path.isdir(f"{copy_to}/{self.ini[self.batch]['subfolder']}") == False:
            os.makedirs(f"{copy_to}/{self.ini[self.batch]['subfolder']}")
        copy_to = f"{copy_to}/{self.ini[self.batch]['subfolder']}"

        if format == 'dat':
            fname = pathlib.Path(dir+'/'+file)
            mod_time = datetime.datetime.fromtimestamp(fname.stat().st_mtime).strftime("%Y%m%dT%H%M")
            shutil.copy(f"{dir}/{file}",f"{copy_to}/{self.batch}_{mod_time}.dat")
            with open(f"{copy_to}/{self.batch}_README.md",'w+') as readme:

                str = f'# README\n\nLast update{datetime.datetime.now().strftime("%Y-%m-%d %H:%M")}'
                str += '\n\n' +self.ini[self.batch]['readme']
                readme.write(str)

        elif format == 'csv':
            file.to_csv(f"{copy_to}/{self.batch}.csv")

            with open(f"{copy_to}/{self.batch}_README.md",'w+') as readme:

                str = f'# README\n\nLast update{datetime.datetime.now().strftime("%Y-%m-%d %H:%M")}'
                str += '\n\n' +self.ini[self.batch]['readme']
                readme.write(str)

class MakeCSV(DatabaseFunctions):
    def __init__(self,Sites=None,Years=[dt.datetime.now().year],ini=[]):
        super().__init__(ini)
        T1 = time.time()
        if Sites is None:
            Sites = self.years_by_site.keys()
        for self.siteID in Sites:
            for req in ini:
                req = req.split('.')[0]
                stage = self.ini[req]["stage"]
                traces = list(self.ini[req]['Traces'].keys())
                print(f'Creating {req} for {self.siteID}')
                self.read_db(self.siteID,Years,stage,traces)

                if self.ini[req]['by_year']:
                    Start = self.data.index-pd.Timedelta(30,'m')
                    for self.Year in Years:
                        self.write_csv(self.data.loc[Start.year==self.Year].copy(),self.ini[req])
                    
    def write_csv(self,df,config):
        if df.empty:
            print(f'No data to write for {self.siteID}: {self.Year}')
        else:
            df[config['timestamp']['output_name']] = df.index.floor('Min').strftime(config['timestamp']['timestamp_fmt'])
            output_path = self.sub(config['output_path'])
            if os.path.exists(output_path)==False:
                os.makedirs(output_path)
            output_path = self.sub(output_path+config['filename'])
            print(output_path)
            if config['units_in_header'].lower() == 'true':
                unitDict = {key:config['Traces'][key]['Units'] for key in config['Traces'].keys()}
                unitDict[config['timestamp']['output_name']] = config['timestamp']['timestamp_units']
                df = pd.concat([pd.DataFrame(index=[-1],data=unitDict),df])
            df=df.fillna(config['na_value'])
            df.to_csv(output_path,index=False)
        
            

class MakeTraces(DatabaseFunctions):
    # Accepts an ini file that prompt a search of the datadump folder - or a pandas dataframe with a datetime index
    def __init__(self,ini='ini_files/WriteTraces.ini',DataTable=None):
        super().__init__(ini)        
        if DataTable is None:
            for self.batch in self.ini['Input']['file_batches'].split(','):
                print('Processing: ',self.batch)
                self.siteID = self.ini[self.batch]['Site']
                self.findFiles()
                self.Process()
        else:
            self.batch = self.ini['Input']['file_batches'].split(',')[0]
            self.siteID = self.ini[self.batch]['Site']
            self.Data = DataTable
            self.Process()
    
    def Process(self):
        self.dateIndex()
        if self.ini[self.batch]['Exclude'] != '':
            colFilter = self.Metadata.filter(self.ini[self.batch]['Exclude'].split(','))
            self.Metadata.drop(colFilter,inplace=True,axis=1)  
            colFilter = self.Data.filter(self.ini[self.batch]['Exclude'].split(','))
            self.Data.drop(colFilter,inplace=True,axis=1)
        self.padFullYear()


    def findFiles(self):
        file_patterns = self.ini[self.batch]['filename'].split(',')
        self.Data = pd.DataFrame()
        self.Metadata = pd.DataFrame()
        if self.ini[self.batch]['search_dir'] in [k for k in self.ini['Paths'].keys()]:
            search_dir = self.ini['Paths'][self.ini[self.batch]['search_dir']].replace('SITE',self.siteID) + self.ini[self.batch]['restrict_search_to']
            print(self.ini[self.batch]['search_dir'].replace('SITE',self.siteID) )
        else:
            search_dir = self.ini[self.batch]['search_dir']# Call to sub fuction could be added here
        for dir,_,files in os.walk(search_dir):
            for file in (files):
                fn = f"{dir}/{file}"
                if len([p for p in file_patterns if p not in fn])==0:
                    print(fn)
                    if self.ini['Input']['copy_to_sites'] == 'True':
                        self.copy_raw_data_files(dir=dir,file=file)
                    if self.ini[self.batch]['subtable_id'] == '':
                        self.readSingle(fn)
                    else:
                        self.readSubTables(fn)

    def readSingle(self,fn):
        if self.ini[self.batch]['Header_Row'] != '':
            header = pd.read_csv(fn,skiprows=int(self.ini[self.batch]['Header_Row']),nrows=int(self.ini[self.batch]['First_Data_Row'])-int(self.ini[self.batch]['Header_Row']))
            self.Metadata = pd.concat([self.Metadata,header],axis=0)
            headers = header.columns
        else:
            headers = self.ini[self.batch]['Header_list'].split(',')
            units = self.ini[self.batch]['Header_units'].split(',')
            header = pd.DataFrame(columns=headers)
            header.iloc[0] = units
            self.Metadata = pd.concat([self.Metadata,header],axis=0)
        Data = pd.read_csv(fn,skiprows=int(self.ini[self.batch]['First_Data_Row']),header=None)
        Data.columns=headers
        self.Data = pd.concat([self.Data,Data],axis=0)

    def readSubTables(self,fn):
        try:
            Data = pd.read_csv(fn,header=None,na_values=[-6999,6999])
        except:
            try:
                Data = pd.read_csv(fn,header=None,na_values=[-6999,6999],skiprows=1)
                First = pd.read_csv(fn,header=None,na_values=[-6999,6999],nrows=1)
            except:
                print(f'\n\nWarinng: Could not read {fn} Check for errors.  It it is a cr10x file, make sure all columns are present.  Outputs from two programs in one file will cuase problems!\n\n')
            pass
        for subtable_id,headers,units in zip(self.ini[self.batch]['subtable_id'].split('|'),self.ini[self.batch]['Header_list'].split('|'),self.ini[self.batch]['Header_units'].split('|')):
            headers = headers.split(',')
            units = units.split(',')
            if Data.shape[1]<len(headers):
                headers = headers[:Data.shape[1]]
                units = units[:Data.shape[1]]
            header = pd.DataFrame(columns=headers,data=[units],index=[0])
            header.iloc[0] = units
            
            self.col_num = headers.index('subtable_id')
            Subtable = Data.loc[Data[self.col_num].astype(str)==subtable_id]
            Subtable = Subtable[Subtable.columns[0:len(headers)]]
            drop = []
            for i,v in enumerate(headers):
                if v == '_':
                    drop.append(i)
            try:
                header = header.drop(columns=['_'])
            except:
                pass
            self.Metadata = pd.concat([self.Metadata,header],axis=0)
            Subtable = Subtable.drop(columns=drop)
            Subtable.columns=header.columns
            self.Data = pd.concat([self.Data,Subtable],axis=0)
        
class GSheetDump(DatabaseFunctions):
    def __init__(self, ini='ini_files/WriteTraces_Gsheets.ini'):
        super().__init__(ini)
        for self.batch in self.ini['Input']['file_batches'].split(','):
            self.siteID = self.ini[self.batch]['Site']
            self.readSheet()

    def readSheet(self):
        self.Metadata=pd.DataFrame()
        i = int(self.ini[self.batch]['subtable_id'])
        self.Data = pd.read_html(self.ini[self.batch]['filename'],
                     skiprows=int(self.ini[self.batch]['Header_Row']))[i]
        
        if self.ini['Input']['copy_to_sites'] == 'True':
            self.copy_raw_data_files(file=self.Data,format='csv')
        self.dateIndex()
        if self.ini[self.batch]['Exclude'] != '':
            colFilter = self.Metadata.filter(self.ini[self.batch]['Exclude'].split(','))
            self.Metadata.drop(colFilter,inplace=True,axis=1)
            colFilter = self.Data.filter(self.ini[self.batch]['Exclude'].split(','))
            self.Data.drop(colFilter,inplace=True,axis=1)
        self.padFullYear()


if __name__ == '__main__':
    T1 = time.time()
    file_path = os.path.split(__file__)[0]
    os.chdir(file_path)

    CLI=argparse.ArgumentParser()

    CLI.add_argument(
        "--Task",
        nargs='*',
        type=str,
        default=['Help'],
        )
    
    CLI.add_argument(
        "--Sites",
        nargs='*',
        type=str,
        default=None,
        )
    
    CLI.add_argument(
        "--Years",
        nargs='*',
        type=int,
        default=None,
        )
    
    CLI.add_argument(
        "--ini",
        nargs='*',
        type=str,
        default=None,
        )
        
    args = CLI.parse_args()
    # if args.Task == 'Help' or 'Help' in args.Task:
    
    ini_defaults = {
        'Help':'N\A',
        'CSVDump':'ini_files/Write_CSV_Files.ini',
        'Write':'ini_files/WriteTraces.ini',
        'GSheetDump':'ini_files/WriteTraces_Gsheets.ini'
    }
    
    for i,Task in enumerate(args.Task):
        print(Task)
        if args.ini is None:
            ini = ini_defaults[Task]
        else:
            ini = args.ini
        if args.Years is not None:
            Years = np.arange(min(args.Years),max(args.Years)+1)
        else:
            Years = None

        if Task == 'CSVDump':
            MakeCSV(args.Sites,Years,ini=ini)
        elif Task == 'Write':
            MakeTraces(ini=ini)
        elif Task == 'GSheetDump':
            GSheetDump(ini=ini)
        elif Task == 'Help':
            print('Help: \n')
            print("--Task: options ('CSVDump', 'Write', or 'GSheetDump')")
            print("--Sites: Leave blank to run all sites or give a list of sites delimited by spaces, e.g., --Sites BB BB2 BBS )\n Only applies if Task == Read")
            print("--Years: Leave blank to run all years or give a list of years delimited by spaces, e.g., --Years 2020 2021 )\n Only applies if Task == Read")
            print("--ini: Leave blank to run default or give a list of ini files corresponding to each Task")
    print('Request completed.  Time elapsed: ',np.round(time.time()-T1,2),' seconds')