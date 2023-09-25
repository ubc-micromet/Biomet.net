import os
import numpy as np
import pandas as pd
import configparser
import argparse
import datetime
import shutil
import pathlib
import sys

class DatabaseFunctions():
    def __init__(self,ini):
        self.ini = configparser.ConfigParser()
        self.ini.read('ini_files/BiometPy.ini')
        self.ini.read(ini)
        self.Year = datetime.datetime.now().year
        self.find_Sites()

    def find_Sites(self):
        start = 2014
        end = self.Year+1

        Root = self.ini['Paths']['database'].split('SITE')[0]
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
        
    def sub(self,s):
        for path in self.ini['Paths'].keys():
            s = s.replace(path.upper(),self.ini['Paths'][path])
        for key,value in {'YEAR':self.Year,'SITE':self.site_name}.items():
            if key in s:
                s = s.replace(key,str(value))
        return(s)

    def dateIndex(self):
        Date_cols = [i for i in self.ini[self.Site_File]['Date_Cols'].split(',')]
        if self.ini[self.Site_File]['Date_Fmt'] == 'Auto':
            Date_col = Date_cols[0]
            self.Data[Date_col] = pd.DatetimeIndex(self.Data[Date_col])
            self.Data = self.Data.set_index(Date_col)
        else:
            self.Data['Timestamp'] = ''
            for col in self.ini[self.Site_File]['Date_Cols'].split(','):
                ix = self.ini[self.Site_File]['Header_list'].split(',').index(col)
                unit = self.ini[self.Site_File]['Header_units'].split(',')[ix]
                if unit.upper() == 'HHMM':
                    self.Data.loc[self.Data[col]==2400,col]=0
                self.Data['Timestamp'] = self.Data['Timestamp'].str.cat(self.Data[col].astype(str).str.zfill(len(unit)),sep='')
            self.Data['Timestamp'] = pd.to_datetime(self.Data['Timestamp'],format=self.ini[self.Site_File]['Date_Fmt'])
            self.Data = self.Data.set_index('Timestamp')

        self.Aggregate()
        self.Data=self.Data.resample('30T').first()

    def Aggregate(self):
        if self.ini[self.Site_File]['aggregate']!='':
            self.Data = self.Data.agg(self.ini[self.Site_File]['aggregate'].split(','),axis=1)

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
        self.write_dir = self.ini['Paths']['database'].replace('YEAR',str(self.y)).replace('SITE',self.site_name)+self.ini[self.Site_File]['subfolder']
        if os.path.isdir(self.write_dir)==False:
            print('Creating new directory at:\n', self.write_dir)
            os.makedirs(self.write_dir)

        for T in self.Year.columns:
            if T == self.ini['Database']['timestamp']:
                fmt = self.ini['Database']['timestamp_dtype']
            else:
                fmt = self.ini['Database']['trace_dtype']
            Trace = self.Year[T].astype(fmt).values
            if self.ini[self.Site_File]['prefix']!='' and T != self.ini['Database']['timestamp']:
                T = self.ini[self.Site_File]['prefix'] + '_' + T
            if self.ini[self.Site_File]['suffix']!='' and T != self.ini['Database']['timestamp']:
                T += '_' + self.ini[self.Site_File]['suffix']
            with open(f'{self.write_dir}/{T}','wb') as out:
                Trace.tofile(out)

    def copy_raw_data_files(self,dir=None,file=None,format='dat'):
        copy_to = self.sub(self.ini['Paths']['sites'])
        if os.path.isdir(copy_to) == False:
            print('Warning: ',copy_to,' Does not exist.  Ensure this is the correct location to save then create the folder before proceeding.')
            sys.exit()
        elif os.path.isdir(f"{copy_to}/{self.ini[self.Site_File]['subfolder']}") == False:
            os.makedirs(f"{copy_to}/{self.ini[self.Site_File]['subfolder']}")
        copy_to = f"{copy_to}/{self.ini[self.Site_File]['subfolder']}"

        if format == 'dat':
            fname = pathlib.Path(dir+'/'+file)
            mod_time = datetime.datetime.fromtimestamp(fname.stat().st_mtime).strftime("%Y%m%dT%H%M")
            shutil.copy(f"{dir}/{file}",f"{copy_to}/{self.Site_File}_{mod_time}.dat")
            with open(f"{copy_to}/{self.Site_File}_README.md",'w+') as readme:

                str = f'# README\n\nLast update{datetime.datetime.now().strftime("%Y-%m-%d %H:%M")}'
                str += '\n\n' +self.ini[self.Site_File]['readme']
                readme.write(str)

        elif format == 'csv':
            file.to_csv(f"{copy_to}/{self.Site_File}.csv")

            with open(f"{copy_to}/{self.Site_File}_README.md",'w+') as readme:

                str = f'# README\n\nLast update{datetime.datetime.now().strftime("%Y-%m-%d %H:%M")}'
                str += '\n\n' +self.ini[self.Site_File]['readme']
                readme.write(str)

class MakeTraces(DatabaseFunctions):
    def __init__(self,ini='ini_files/WriteTraces_BBS.ini'):
        super().__init__(ini)
        for self.Site_File in self.ini['Input']['Files'].split(','):
            self.site_name = self.ini[self.Site_File]['Site']
            self.findFiles()

    def findFiles(self):
        patterns = self.ini[self.Site_File]['path_patterns'].split(',')
        self.Data = pd.DataFrame()
        self.Metadata = pd.DataFrame()
        for dir,_,files in os.walk(self.ini['Paths']['datadump'].replace('SITE',self.site_name)):
            for file in (files):
                fn = f"{dir}/{file}"
                if len([p for p in patterns if p not in fn])==0:
                    if self.ini['Input']['copy_to_sites'] == 'True':
                        self.copy_raw_data_files(dir=dir,file=file)
                    if self.ini[self.Site_File]['subtable_id'] == '':
                        self.readSingle(fn)
                    else:
                        self.readSubTables(fn)
        self.dateIndex()
        if self.ini[self.Site_File]['Exclude'] != '':
            colFilter = self.Metadata.filter(self.ini[self.Site_File]['Exclude'].split(','))
            self.Metadata.drop(colFilter,inplace=True,axis=1)  
            colFilter = self.Data.filter(self.ini[self.Site_File]['Exclude'].split(','))
            self.Data.drop(colFilter,inplace=True,axis=1)
        self.padFullYear()

    def readSingle(self,fn):
        if self.ini[self.Site_File]['Header_Row'] != '':
            header = pd.read_csv(fn,skiprows=int(self.ini[self.Site_File]['Header_Row']),nrows=int(self.ini[self.Site_File]['First_Data_Row'])-int(self.ini[self.Site_File]['Header_Row']))
            self.Metadata = pd.concat([self.Metadata,header],axis=0)
            headers = header.columns
        else:
            headers = self.ini[self.Site_File]['Header_list'].split(',')
            units = self.ini[self.Site_File]['Header_units'].split(',')
            header = pd.DataFrame(columns=headers)
            header.iloc[0] = units
            self.Metadata = pd.concat([self.Metadata,header],axis=0)
        Data = pd.read_csv(fn,skiprows=int(self.ini[self.Site_File]['First_Data_Row']),header=None)
        Data.columns=headers
        self.Data = pd.concat([self.Data,Data],axis=0)

    def readSubTables(self,fn):
        try:
            Data = pd.read_csv(fn,header=None,na_values=[-6999,6999])
        except:
            Data = pd.read_csv(fn,header=None,na_values=[-6999,6999],skiprows=1)
            First = pd.read_csv(fn,header=None,na_values=[-6999,6999],nrows=1)
            pass
        for subtable_id,headers,units in zip(self.ini[self.Site_File]['subtable_id'].split('|'),self.ini[self.Site_File]['Header_list'].split('|'),self.ini[self.Site_File]['Header_units'].split('|')):
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
        for self.Site_File in self.ini['Input']['Files'].split(','):
            self.site_name = self.ini[self.Site_File]['Site']
            self.readSheet()

    def readSheet(self):
        self.Metadata=pd.DataFrame()
        i = int(self.ini[self.Site_File]['subtable_id'])
        self.Data = pd.read_html(self.ini[self.Site_File]['path_patterns'],
                     skiprows=int(self.ini[self.Site_File]['Header_Row']))[i]
        
        if self.ini['Input']['copy_to_sites'] == 'True':
            self.copy_raw_data_files(file=self.Data,format='csv')
        self.dateIndex()
        if self.ini[self.Site_File]['Exclude'] != '':
            colFilter = self.Metadata.filter(self.ini[self.Site_File]['Exclude'].split(','))
            self.Metadata.drop(colFilter,inplace=True,axis=1)
            colFilter = self.Data.filter(self.ini[self.Site_File]['Exclude'].split(','))
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
                for self.Year in Years:
                    self.dpath = self.sub(self.ini['Paths']['database'])+self.ini[self.Request]['stage']+'/'
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
            output_path = output_path+self.Request+'.csv'
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
    file_path = os.path.split(__file__)[0]
    os.chdir(file_path)

    CLI=argparse.ArgumentParser()
    # CLI.add_argument(
    # "--ini",  # name on the CLI - drop the `--` for positional/required parameters
    # nargs=1,  # 0 or more values expected => creates a list
    # type=str,
    # default='WriteTraces.ini',  # default if nothing is provided
    # )
    
    CLI.add_argument(
        "--func",  # name on the CLI - drop the `--` for positional/required parameters
        nargs=1,  # 0 or more values expected => creates a list
        type=str,
        default='Read',  # default if nothing is provided
        )
        
    args = CLI.parse_args()
    if args.func == 'Read':
        MakeCSV()
    elif args.func == 'Write':
        MakeTraces()
    elif args.func == 'GSheetDump':
        GSheetDump()