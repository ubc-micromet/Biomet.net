import os
import re
import TzFuncs
import argparse
import datetime
import pandas as pd
from glob import glob
import readConfig as rCfg

template = ['config_files/gsheet_to_binary.yml','config_files/dat_to_binary.yml']
os.chdir(os.path.split(__file__)[0])

class writeBinaryTraces():
    def __init__(self,tasks=template):
        self.config = rCfg.set_user_configuration(tasks)
        for name,task in self.config['tasks'].items():
            if 'prefix' in task['site']: self.prefix = task['site']['prefix']
            else: self.prefix=''
            if 'suffix' in task['site']: self.suffix = task['site']['suffix']
            else: self.suffix=''
            self.stage = self.config['stage'][task['stage']]
            self.siteID = task['site']['ID']
            if name.endswith('gsheet'):
                self.readGoogleSheet(task)
            else:
                self.readGenericAscii(task)
    
    def readGenericAscii(self,task):
        if 'recursiveSearch' in task:
            if 'fileNameMatch' in task['recursiveSearch']:
                fileNameMatch = '*'+task['recursiveSearch']['fileNameMatch']+'*'+task['recursiveSearch']['fileExtension']
            else:
                fileNameMatch = '*'+task['recursiveSearch']['fileExtension']
            search_path = os.path.abspath(os.path.join(self.config['rootDir'][task['recursiveSearch']['rootDir']],task['recursiveSearch']['subDir'],'**',fileNameMatch))
            fileList = glob(search_path, recursive=True)
        else:
            fileList = task['fileList']
        
        Data = pd.DataFrame()
        if task['formatting']['header'] == 'None':task['formatting']['header']=None
        for file in fileList:
            if 'autoDate' in task['formatting']:
                df = pd.read_csv(file,header=task['formatting']['header'])
                df.columns = df.columns.get_level_values(0)
                df['datetime'] = pd.to_datetime(df[task['formatting']['autoDate']])
                df.set_index('datetime',inplace=True)
                df = df.drop(columns=[task['formatting']['autoDate']])
            else:
                TimeStamp = task['formatting']['timestamp']
                df = pd.read_csv(file,header=task['formatting']['header'])
                if 'subtables' in task:
                    full_df = pd.DataFrame()
                    for subtable in task['subtables'].values():
                        sub_df = df.loc[df[0] == subtable['ID']]
                        rn = {i:name for i,name in enumerate(subtable['columns'])}
                        sub_df = sub_df.rename(columns=rn)
                        # drop any dangling/unwanted columns named with an integer
                        drop = [i for i in sub_df.columns if type(i) == int]
                        sub_df = sub_df.drop(columns = drop)
                        sub_df = self.parseTimeStamp(sub_df,TimeStamp)
                        full_df = pd.concat([full_df,sub_df])
                df = full_df
            Data = pd.concat([df,Data])
        if 'exclude' in task:
            Data = Data.drop(columns=task['exclude'])
        Data = Data.resample(self.config['dbase_metadata']['timestamp']['resolution']).last()
        self.writeByYear(Data)
        

    def readGoogleSheet(self,task):
        TimeStamp = task['formatting']['timestamp']
        # Read the sheet
        Data = pd.read_html(task['link'],header=task['formatting']['header'])[task['subtable_id']]
        Data = self.parseTimeStamp(Data,TimeStamp,task['site']['lat_lon'])
        # Google sheets don't handle dates well, so best practice is to have separate columns for year,month,day, etc.
        Data = Data.drop(columns=['1'])
        if 'aggregate' in task:
            Data = Data.agg(task['aggregate']['statistics'],axis=1)
            Data.columns = [task['aggregate']['variable_name']+'_'+nm for nm in Data.columns]
        self.writeByYear(Data)

    def parseTimeStamp(self,Data,TimeStamp,lat_lon=None):
        if 'format' not in TimeStamp:
            Data['datetime'] = pd.to_datetime(Data[TimeStamp['date_cols']]).dt.round(self.config['dbase_metadata']['timestamp']['resolution'])
        else:
            Data['datetime'] = ''
            for i,col in enumerate(TimeStamp['date_cols']):
                if 'zFillDates' in TimeStamp:
                    if i > 1:
                        Data.loc[Data[col]==2400,col] = 2359
                    Data['datetime'] = Data['datetime'].str.cat(Data[col].astype(str).str.zfill(len(col)),sep='')
            Data['datetime'] = pd.to_datetime(Data['datetime'],format=TimeStamp['format']).dt.round(self.config['dbase_metadata']['timestamp']['resolution'])
        Data = Data.drop(columns=TimeStamp['date_cols'])
        Data.set_index('datetime',inplace=True)
        if 'is_dst' in TimeStamp and TimeStamp['is_dst'] == True:
            tzf = TzFuncs.Tzfuncs(lat_lon=lat_lon,DST=True)
            tzf.convert(Data.index)
            Data = Data.set_index(tzf.Standard_Time)
        return(Data)

    def writeByYear(self,Data):
        # write binary files by year following the Biomet format with a matlab datenum index
        for y in Data.index.year.unique():
            dout = os.path.abspath(os.path.join(self.config['rootDir']['Database'],str(y),self.siteID,self.stage))
            os.makedirs(dout,exist_ok=True)
            Year = pd.DataFrame(data={'datetime':pd.date_range(start = f'{y}01010030',end=f'{y+1}01010001',freq='30T')})
            Year.set_index('datetime',inplace=True)
            Year = Year.join(Data)
            timeVector = self.config['dbase_metadata']['timestamp']['name']
            Year[timeVector] = self.toMatlabTimeVector(Year.index)
            for traceName in Year.columns:
                if traceName == timeVector:
                    dtype = self.config['dbase_metadata']['timestamp']['dtype']
                else:
                    dtype = self.config['dbase_metadata']['traces']['dtype']
                Trace = Year[traceName].astype(dtype).values
                traceName = self.prefix+re.sub(r'\W+', '_', traceName)+self.suffix
                with open(f'{dout}/{traceName}','wb') as out:
                    print(f'Writing: {dout}/{traceName}')
                    Trace.tofile(out)
                
    
    def toMatlabTimeVector(self,datetime_in):
            unix_base = datetime.datetime(1970,1,1,0,0)
            matlab_base = self.config['dbase_metadata']['timestamp']['base']
            seconds = (datetime_in-datetime_in.floor('D')).seconds/(24*60*60)
            return((datetime_in-unix_base).days+matlab_base+seconds)

# If called from command line ...
if __name__ == '__main__':
    
    CLI=argparse.ArgumentParser()
            
    CLI.add_argument(
        "--tasks", 
        nargs='+',
        type=str,
        default=template,
        )
      
    # Parse the args and make the call
    args = CLI.parse_args()

    # Call 
    writeBinaryTraces(args.tasks)
    