import os
import numpy as np
import pandas as pd
import configparser
import argparse
import datetime
import shutil
import pathlib
import sys
import TzFuncs
import time

class DatabaseFunctions():

    def __init__(self,ini=''):
        # Parse the ini files then find all site-years in the database
        self.ini = configparser.ConfigParser()
        self.ini.read('ini_files/BiometPy.ini')
        self.ini.read(ini)
        self.Year = datetime.datetime.now().year
        self.find_Sites()

    def find_Sites(self):
        start = 2014
        end = self.Year+1

        Root = self.ini['Paths']['database_read'].split('SITE')[0]
        self.years_by_site = {}
        for year in range(start,end):
            if os.path.isdir(Root.replace('YEAR',str(year))):
                Dirs = os.listdir(Root.replace('YEAR',str(year)))
                for site in Dirs:
                    if site.startswith('.') or site.startswith('_'):
                        pass
                    else:
                        if site not in self.ini['Exceptions']['not_sites']:
                            if site in self.years_by_site:
                                self.years_by_site[site].append(year)
                            else:
                                self.years_by_site[site] = [year]
        for site_name in self.years_by_site.keys():
            if os.path.isfile(f'ini_files/site_configurations/{site_name}.ini'):
                self.ini.read(f'ini_files/site_configurations/{site_name}.ini')
            else:
                print(f'{site_name} config file does not exist. Skpping')
        
    def sub(self,s):
        for path in self.ini['Paths'].keys():
            s = s.replace(path.upper(),self.ini['Paths'][path])
        for key,value in {'YEAR':self.Year,'SITE':self.site_name}.items():
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
                ix = self.ini[self.batch]['Header_list'].split(',').index(col)
                unit = self.ini[self.batch]['Header_units'].split(',')[ix]
                if unit.upper() == 'HHMM':
                    self.Data.loc[self.Data[col]==2400,col]=0
                self.Data['Timestamp'] = self.Data['Timestamp'].str.cat(self.Data[col].astype(str).str.zfill(len(unit)),sep='')
            self.Data['Timestamp'] = pd.to_datetime(self.Data['Timestamp'],format=self.ini[self.batch]['date_Fmt'])
            self.Data = self.Data.set_index('Timestamp')
        if self.ini[self.batch]['is_dst'] == 'True':
            lat_lon=[float(self.ini[self.site_name]['latitude']),float(self.ini[self.site_name]['longitude'])]
            tzf = TzFuncs.Tzfuncs(lat_lon=lat_lon,DST=True)
            tzf.convert(self.Data.index)
            self.Data = self.Data.set_index(tzf.Standard_Time)

        self.Aggregate()
        self.Data=self.Data.resample('30T').first()

    def Aggregate(self):
        if self.ini[self.batch]['aggregate']!='':
            self.Data = self.Data.agg(self.ini[self.batch]['aggregate'].split(','),axis=1)

    def readBinary(self,file,dtype):
        file = self.dpath+file
        if os.path.isfile(file):
            with open(file, mode='rb') as f:
                trace = np.fromfile(f, dtype)
                return(trace)
            
    def readTimeVector(self):
        clean_tv = self.readBinary(self.ini['Database']['timestamp'],self.ini['Database']['timestamp_dtype'])
        if clean_tv is None:
            clean_tv = self.readBinary(self.ini['Database']['timestamp_alt'],self.ini['Database']['timestamp_dtype'])
        if clean_tv is not None:
            base = float(self.ini['Database']['datenum_base'])
            unit = self.ini['Database']['datenum_base_unit']
            self.Time_Trace = pd.to_datetime(clean_tv-base,unit=unit).round('T')
        else:
            print('Warning - time vector does not exist - generating anyway, double check the inputs / outputs')
            self.Time_Trace = pd.date_range(start='2022-01-01 00:30',end='2023-01-01',freq='30T')
    
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
        self.write_dir = self.ini['Paths']['database_write'].replace('YEAR',str(self.y)).replace('SITE',self.site_name)+self.ini[self.batch]['subfolder']
        if os.path.isdir(self.write_dir)==False:
            print('Creating new directory at:\n', self.write_dir)
            os.makedirs(self.write_dir)

        for T in self.Year.columns:
            if T == self.ini['Database']['timestamp']:
                fmt = self.ini['Database']['timestamp_dtype']
            else:
                fmt = self.ini['Database']['trace_dtype']
            Trace = self.Year[T].astype(fmt).values
            if self.ini[self.batch]['prefix']!='' and T != self.ini['Database']['timestamp']:
                T = self.ini[self.batch]['prefix'] + '_' + T
            if self.ini[self.batch]['suffix']!='' and T != self.ini['Database']['timestamp']:
                T += '_' + self.ini[self.batch]['suffix']
            with open(f'{self.write_dir}/{T}','wb') as out:
                Trace.tofile(out)

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

class MakeTraces(DatabaseFunctions):
    # Accepts an ini file that prompt a search of the datadump folder - or a pandas dataframe with a datetime index
    def __init__(self,ini='ini_files/WriteTraces.ini',DataTable=None):
        super().__init__(ini)        
        if DataTable is None:
            for self.batch in self.ini['Input']['file_batches'].split(','):
                print('Processing: ',self.batch)
                self.site_name = self.ini[self.batch]['Site']
                self.findFiles()
                self.Process()
        else:
            self.batch = self.ini['Input']['file_batches'].split(',')[0]
            self.site_name = self.ini[self.batch]['Site']
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
        search_dir = self.ini['Paths']['datadump'].replace('SITE',self.site_name) + self.ini[self.batch]['restrict_search_to']
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
            Data = pd.read_csv(fn,header=None,na_values=[-6999,6999],skiprows=1)
            First = pd.read_csv(fn,header=None,na_values=[-6999,6999],nrows=1)
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
            self.site_name = self.ini[self.batch]['Site']
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

class MakeCSV(DatabaseFunctions):
    def __init__(self,Sites=None,Years=None,ini='ini_files/ReadTraces.ini'):
        super().__init__(ini)
        if Sites is None:
            Sites = self.years_by_site.keys()
        for self.site_name in Sites:
            for self.Request in self.ini['Output']['requests'].split(','):
                if Years is not None:
                    self.years_by_site[self.site_name] = Years
                print(f'Creating .csv files for {self.site_name}: {self.Request}')
                self.AllData = pd.DataFrame()
                for self.Year in self.years_by_site[self.site_name]:
                    self.dpath = self.sub(self.ini['Paths']['database_read'])+self.ini[self.Request]['stage']+'/'
                    if os.path.exists(self.dpath):
                        self.readYear()
                self.write_csv()
                    
    def readYear(self):
        self.readTimeVector()
        self.Data = pd.DataFrame(index=self.Time_Trace,data=self.readTraces())
        self.Data[self.ini[self.Request]['timestamp']] = self.Data.index.floor('Min').strftime(self.ini[self.Request]['timestamp_FMT'])
        for renames in self.ini[self.Request]['rename'].split(','):
            r = renames.split('|')
            if len(r)>1:
                self.Data = self.Data.rename(columns={r[0]:r[1]})
        self.AllData = pd.concat([self.AllData,self.Data])

    def readTraces(self):
        D_traces = {}
        for Trace_Name in self.ini[self.Request]['traces'].split(','):
            trace = self.readBinary(Trace_Name,self.ini['Database']['trace_dtype'])
            if trace is not None:
                D_traces[Trace_Name]=trace
        return (D_traces)
    
    def write_csv(self):
        if self.AllData.empty:
            print(f'No data to write for{self.site_name}: {self.Year}')
        else:
            output_path = self.sub(self.ini[self.Request]['output_paths'])
            if os.path.exists(output_path)==False:
                os.makedirs(output_path)
            output_path = output_path+self.Request+'_'+self.site_name+'.csv'
            self.addUnits()
            self.AllData.set_index(self.ini[self.Request]['timestamp'],inplace=True)
            self.AllData.to_csv(output_path)
        
    def addUnits(self):
        if self.ini[self.Request]['units_in_header'].lower() == 'true':
            units = self.ini[self.Request]['units'].split(',')
            units.append(self.ini[self.Request]['timestamp_units'])
            unit_dic = {t:u for t,u in zip(self.AllData.columns,units)}
            self.AllData = pd.concat([pd.DataFrame(index=[-1],data=unit_dic),self.AllData])
            

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
        type=str,
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
        'Read':'ini_files/ReadTraces.ini',
        'Write':'ini_files/WriteTraces.ini',
        'GSheetDump':'ini_files/WriteTraces_Gsheets.ini'
    }
    
    for i,Task in enumerate(args.Task):
        if args.ini is None:
            ini = ini_defaults[Task]
        else:
            ini = args.ini

        if Task == 'Read':
            MakeCSV(args.Sites,args.Years,ini=ini)
        elif Task == 'Write':
            MakeTraces(ini=ini)
        elif Task == 'GSheetDump':
            GSheetDump(ini=ini)
        elif Task == 'Help':
            print('Help: \n')
            print("--Task: options ('Read', 'Write', or 'GSheetDump')")
            print("--Sites: Leave blank to run all sites or give a list of sites delimited by spaces, e.g., --Sites BB BB2 BBS )\n Only applies if Task == Read")
            print("--Years: Leave blank to run all years or give a list of years delimited by spaces, e.g., --Years 2020 2021 )\n Only applies if Task == Read")
            print("--ini: Leave blank to run default or give a list of ini files corresponding to each Task")
    print('Request completed.  Time elapsed: ',np.round(time.time()-T1,2),' seconds')