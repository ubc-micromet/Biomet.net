import os
import numpy as np
import pandas as pd
import netCDF4 as nc
import urllib.request
import geopandas as gpd
import argparse
import folium
import configparser
from scipy.interpolate import RBFInterpolator
import datetime
import TzFuncs

import DatabaseFunctions


class PointSample():
    
    def __init__(self,Years,Write_to_Database='ini_files/templates/WriteTraces_NARR.ini',verbose=0,Update_On_Day=3,Limit_to_Sites = []):
        Today = datetime.datetime.now()
        self.ini = configparser.ConfigParser()
        self.ini.read('ini_files/BiometPy.ini')
        self.ini.read(Write_to_Database)
        self.verbose = verbose
        self.writer = configparser.ConfigParser()
        self.writer.read(Write_to_Database)

        self.parseSpatial(Limit_to_Sites)
        Vars = self.ini['Downloads']['NARR_var_names'].split(',')
        for self.var_name in Vars:
            for self.year in Years:
                if self.year >=1979 & self.year <= datetime.datetime.now().year:
                    if ((Today.year == self.year and Today.month > 1) or (Today.year-1 == self.year and Today.month == 1)) and Today.day==Update_On_Day:
                        Update=True
                    else:
                        Update=False
                    self.check(Update)
                    self.extractBySite()      

    def parseSpatial(self,Limit_to_Sites):
        # WKT description of the NARR LCC projection
        # Source: https://spatialreference.org/ref/sr-org/8214/
        NARR_LCC = '+proj=lcc +lat_1=50 +lat_0=50 +lon_0=-107 +k_0=1 +x_0=5632642.22547 +y_0=4612545.65137 +a=6371200 +b=6371200 +units=m +no_defs'
        All_Sites = pd.DataFrame()
        for file in os.listdir('ini_files/site_configurations/'):
            self.ini.read('ini_files/site_configurations/'+file)
            Site_code = file.split('.ini')[0]
            if len(Limit_to_Sites) == 0 or Site_code in Limit_to_Sites:
                df = pd.DataFrame(data=dict(self.ini[Site_code]),index=[Site_code])
                for c in df.columns:
                    try:
                        df[c]=df[c].astype('float64')
                    except:
                        pass
                All_Sites = pd.concat([All_Sites,df])
        self.All_Sites = gpd.GeoDataFrame(All_Sites, geometry=gpd.points_from_xy(All_Sites.longitude, All_Sites.latitude), crs="EPSG:4326")
        self.All_Sites = self.All_Sites.to_crs(NARR_LCC)

    def extractBySite(self):
        for self.Site_code in self.All_Sites.loc[self.All_Sites['start_year']<=self.year].index:
            print(f'Estimating {self.var_name} for {self.year} at {self.Site_code}')
            self.Site = self.All_Sites.loc[self.All_Sites.index==self.Site_code]

            self.out_dir = f'{self.ini["Downloads"]["nc_path"]}/{self.Site_code}'
            if os.path.isdir(self.out_dir) is False: os.makedirs(self.out_dir)

            if os.path.isfile(f'{self.out_dir}/{self.var_name}.csv'):
                self.Trace = pd.read_csv(f'{self.out_dir}/{self.var_name}.csv',parse_dates=[self.writer['NARR']['date_cols']],index_col=self.writer['NARR']['date_cols'])
            else:
                self.Trace = pd.DataFrame()
            self.estimate_values()
                
            self.Trace = self.Trace[self.Trace.index.duplicated(keep = 'last')==False].sort_index()
            self.Trace.to_csv(f'{self.out_dir}/{self.var_name}.csv')

            # Filter out hanging date (NARR data is in UTC, depending on timezone, some data points will be in previous year)
            CT = self.Trace.groupby(self.Trace.index.year).count()[self.var_name]
            
            Traces_to_Write = self.Trace.loc[self.Trace.index.year.isin(CT.loc[CT>8].index)].copy()
            
            self.writer['NARR']['path_patterns']=self.var_name+',NARR'
            self.writer['NARR']['site']=self.Site_code
            
            with open('_Temp/Write_NARR.ini', 'w') as configfile: 
                self.writer.write(configfile)
            DatabaseFunctions.MakeTraces(os.getcwd()+'/_Temp/Write_NARR.ini',Traces_to_Write)


    def check(self,Update=True):
        fn = f'{self.var_name}_{self.year}.nc'
        if os.path.exists(f'{self.ini["Downloads"]["nc_path"]}/{self.var_name}_{self.year}.nc') == False:
            print(f'Could not find {self.var_name}_{self.year}.nc locally, downloading dataset')
            self.download()
        elif Update==True:
            print(f'Downloading update for {self.var_name}_{self.year}.nc')
            self.download()            
        self.read(fn)
    
    def download(self):
        # Downloads annual NARR data for a desired variable
        url = self.ini["Downloads"]["NARR_URL"].replace('_YEAR_',str(self.year)).replace('_VAR_NAME_',self.var_name)
        urllib.request.urlretrieve(url, f'{self.ini["Downloads"]["nc_path"]}/{self.var_name}_{self.year}.nc')

    def read(self,fn):        
        ds = nc.Dataset(f'{self.ini["Downloads"]["nc_path"]}/{fn}')
        self.lon = np.ma.getdata(ds.variables['lon'][:])
        self.lat = np.ma.getdata(ds.variables['lat'][:])
        self.x = np.ma.getdata(ds.variables['x'][:])
        self.y = np.ma.getdata(ds.variables['y'][:])
        self.time = ds.variables['time']
        self.time = nc.num2date(self.time[:], self.time.units,calendar = 'standard',only_use_cftime_datetimes=False)
        # self.time = pd.to_datetime(self.time)+timedelta(hours=tz_offset)
        self.var = np.ma.getdata(ds.variables[self.var_name][:])
        if self.verbose == 1:
            print(ds)

    def estimate_values(self,pad = 2,freq = '30T'):
        # Estimates values of the variable of interest for point (or area) locations, passed as a geodataframe (self.Site)
        # Gets the smallest set of grid points containing the bounding box of the self.Site + "pad" grid points in each direction
        # Values are interpolated spatially using a radial bias function and saved to a dataframe for each point
        # Then values for each point are linearly interpolated resampled to the desired temporal resolution 
        # Saved to Outputs/NARR_interpolated_{self.var_name}_{self.year}.csv'
        
        bbox = self.Site.total_bounds
        
        self.x_bounds = [np.where(self.x<bbox[0])[0][-(pad)],np.where(self.x>bbox[2])[0][pad]]
        self.y_bounds = [np.where(self.y<bbox[1])[0][-(pad)],np.where(self.y>bbox[3])[0][pad]]

        lon_box = self.lon[self.y_bounds[0]:self.y_bounds[1],self.x_bounds[0]:self.x_bounds[1]]
        lat_box = self.lat[self.y_bounds[0]:self.y_bounds[1],self.x_bounds[0]:self.x_bounds[1]]

        m = folium.Map(location=[self.Site.latitude.values[0],self.Site.longitude.values[0]])   
        for at,on in zip (lat_box.flatten(),lon_box.flatten()):
            folium.Marker([at, on]).add_to(m)
        folium.CircleMarker([self.Site.latitude.values[0],self.Site.longitude.values[0]],popup=self.Site_code).add_to(m)
        m.save(f'{self.out_dir}/{self.var_name}_grid_pts.html')

        self.x_clip = self.x[self.x_bounds[0]:self.x_bounds[1]]
        self.y_clip = self.y[self.y_bounds[0]:self.y_bounds[1]]
        self.xi,self.yi = np.meshgrid(self.x_clip,self.y_clip)
        self.xi,self.yi = self.xi.flatten(),self.yi.flatten()
        self.xy = np.array([self.xi,self.yi]).T
        self.var_clip = self.var[:,self.y_bounds[0]:self.y_bounds[1],self.x_bounds[0]:self.x_bounds[1]]

        self.coords = np.array([self.Site.geometry.x[0:],self.Site.geometry.y[0:]]).T

        tzf = TzFuncs.Tzfuncs(Time_Zone=self.ini[self.Site_code]['time_zone'],DST=True)
        tzf.convert(pd.to_datetime(self.time),from_UTC=True)
        TS = pd.DataFrame()
        TS[self.writer['NARR']['date_cols']] = tzf.Standard_Time # = pd.to_datetime(self.time)+timedelta(hours=int(self.ini[self.Site_code]['time_zone']))
        
        TS[self.var_name]=np.nan
        for i,row in TS.iterrows():
            TS.loc[TS.index == i, self.var_name] = self.interpolate(self.var_clip[i].flatten())
        TS = TS.set_index(self.writer['NARR']['date_cols'])
        TS = TS.resample(freq).asfreq()
        TS[self.var_name+'_interp_linear'] = TS[self.var_name].interpolate(method='linear')
        TS[self.var_name+'_interp_spline_2ndOrder'] = TS[self.var_name].interpolate(method='spline',order=2)
        TS = TS.round(1)

        self.Trace = pd.concat([self.Trace,TS])

    def interpolate(self,val):
        # Interpolates value from grid (xy) to desired points (coords) using a Radial Bias Function
        # Default behavior is to use a thin plate spline function r**2 * log(r)
        return(RBFInterpolator(self.xy, val,kernel='linear')(self.coords))


if __name__ == '__main__':
    file_path = os.path.split(__file__)[0]
    os.chdir(file_path)
    # If called from command line, parse the arguments
    
    CLI=argparse.ArgumentParser()
    CLI.add_argument(
    "--site",  # name on the CLI - drop the `--` for positional/required parameters
    nargs=1,  # 0 or more values expected => creates a list
    type=str,
    default='BB',  # default if nothing is provided
    )

    CLI.add_argument(
    "--years",
    nargs='+',
    type=int,  
    default=[],
    )
    
    CLI.add_argument(
    "--verbose",
    nargs=1,
    type=int,  
    default=[0],
    )

    args = CLI.parse_args()
    if args.verbose[0]==1:
        print(args)
    PointSample(args.site[0],args.years,args.verbose[0])
