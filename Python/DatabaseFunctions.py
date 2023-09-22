import os
import numpy as np
import pandas as pd
import configparser
import argparse
import datetime

class Dbase():
    def __init__(self,ini):
        self.ini = configparser.ConfigParser()
        self.ini.read('ini_files/BiometPy.ini')
        self.ini.read(ini)
        self.find_Sites()

    def find_Sites(self):
        start = 2014
        end = datetime.datetime.now().year+1

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
        
    def sub(self,val):
        for path in self.ini['Paths'].keys():
            val = val.replace(path.upper(),self.ini['Paths'][path])
        v = val.replace('YEAR',str(self.Year)).replace('SITE',self.Site)
        return(v)


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

    def FullYear(self):
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


class MakeTraces(Dbase):
    def __init__(self,ini='ini_files/WriteTraces.ini'):
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
        self.FullYear()

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
        # Read the file - if the first row is corrupted, it will be dropped
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
        
class GSheetDump(Dbase):
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
        self.dateIndex()
        if self.ini[self.Site_File]['Exclude'] != '':
            colFilter = self.Metadata.filter(self.ini[self.Site_File]['Exclude'].split(','))
            self.Metadata.drop(colFilter,inplace=True,axis=1)
            colFilter = self.Data.filter(self.ini[self.Site_File]['Exclude'].split(','))
            self.Data.drop(colFilter,inplace=True,axis=1)
        self.FullYear()

class MakeCSV(Dbase):
    def __init__(self,Sites=None,Years=None,ini='ini_files/ReadTraces.ini'):
        super().__init__(ini)

        for Site in Sites:
            self.Site = Site
            for Request in self.ini['Output']['Requests'].split(','):
                print(f'Creating .csv files for {Site}: {Request}')
                self.Request = Request
                if self.ini[self.Request]['by_Year']=='False':
                    self.AllData = pd.DataFrame()
                for Year in Years:
                    self.Year = Year
                    if os.path.exists(self.sub(self.ini['Paths']['database'])+self.ini[self.Request]['Stage']):
                        self.readDB()
                    else:
                        pass
                if self.ini[self.Request]['by_Year']=='False':
                    self.write_csv()
                    
    def readDB(self):
        self.getTime()
        if self.skip_Flag == False:
            self.traces = self.ini[self.Request]['Traces'].split(',')
            D_traces = self.readTrace()
            self.Data = pd.DataFrame(index=self.Time_Trace,data=D_traces)
            self.Data[self.ini[self.Request]['timestamp']] = self.Data.index.floor('Min').strftime(self.ini[self.Request]['timestamp_FMT'])
            self.traces.insert(0,self.ini[self.Request]['timestamp'])
            self.renames = {}
            for renames in self.ini[self.Request]['Rename'].split(','):
                r = renames.split('|')
                if len(r)>1:
                    self.renames[r[0]]=r[1]
            self.Data = self.Data.rename(columns=self.renames)
            if self.ini[self.Request]['by_Year']=='True':
                self.AllData = self.Data
                self.write_csv()
            else:
                self.AllData = pd.concat([self.AllData,self.Data])

    def getTime(self):
        Timestamp = self.ini['Database']['timestamp']
        Timestamp_alt = self.ini['Database']['timestamp']
        filename = self.sub(self.ini['Paths']['database'])+self.ini[self.Request]['Stage']+Timestamp
        filename_alt = self.sub(self.ini['Paths']['database'])+self.ini[self.Request]['Stage']+Timestamp_alt
        if os.path.isfile(filename)+os.path.isfile(filename_alt) == 0:
            self.skip_Flag = True
        else:
            try:
                with open(filename, mode='rb') as file:
                    Time_Trace = np.fromfile(file, self.ini['Database']['timestamp_dtype'])
            except:
                with open(filename_alt, mode='rb') as file:
                    Time_Trace = np.fromfile(file, self.ini['Database']['timestamp_dtype'])
                pass
            if self.ini['Database']['timestamp_fmt'] == 'datenum':
                base = float(self.ini['Database']['datenum_base'])
                unit = self.ini['Database']['datenum_base_unit']
                self.Time_Trace_Num = Time_Trace+0
                self.Time_Trace = pd.to_datetime(Time_Trace-base,unit=unit).round('T')
            else:
                # Datenum is depreciated and we should consider upgrading
                warning = 'Revise code for new timestamp format'
                sys.exit(warning)
            self.skip_Flag=False

    def readTrace(self):
        D_traces = {}
        for Trace_Name in self.traces:
            filename = self.sub(self.ini['Paths']['database'])+self.ini[self.Request]['Stage']+Trace_Name
            try:
                with open(filename, mode='rb') as file:
                    trace = np.fromfile(file, self.ini['Database']['trace_dtype'])
            except:
                print(f'Trace does not exist {filename} , proceeding without')
                trace = np.empty(self.Time_Trace.shape[0])
                trace[:] = np.nan
                pass
            D_traces[Trace_Name]=trace
        return (D_traces)

    def write_csv(self):
        if self.AllData.empty:
            print(f'No data to write for{self.Site}: {self.Year}')
        else:
            output_path = self.sub(self.ini[self.Request]['Output_Paths'])
            if os.path.exists(output_path)==False:
                os.makedirs(output_path)
            output_path = output_path+self.Request+'.csv'
            self.addUnits()
            self.AllData.set_index(self.ini[self.Request]['timestamp'],inplace=True)
            self.AllData.to_csv(output_path)
        
    def addUnits(self):
        if self.ini[self.Request]['Units_in_Header'].lower() == 'true':
            units = self.ini[self.Request]['Units'].split(',')
            units.insert(0,self.ini[self.Request]['timestamp_Units'])
            unit_dic = {t:u for t,u in zip(self.traces,units)}
            for key,val in self.renames.items():
                unit_dic[val] = unit_dic.pop(key)
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
        MakeTraces()