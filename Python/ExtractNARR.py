import os
import sys
import numpy as np
import pandas as pd
import netCDF4 as nc
import urllib.request
import geopandas as gpd
import argparse
import folium
import configparser
from datetime import timedelta
from scipy.interpolate import RBFInterpolator
import datetime

import DatabaseFunctions


class PointSample():
    
    def __init__(self,Site_code,Years,NARR_ini='ini_files/WriteTraces_NARR.ini',verbose=0):
        self.ini = configparser.ConfigParser()
        self.ini.read('ini_files/BiometPy.ini')
        self.ini.read(f'ini_files/site_configurations/{Site_code}.ini')
        self.ini.read(NARR_ini)
        self.verbose = verbose
        self.Site_code = Site_code
        
        inv = self.ini["Downloads"]["nc_path"]+'inventory.csv'
        if os.path.isfile(inv):
            self.inventory = pd.read_csv(inv)
        else:
            self.inventory = pd.DataFrame(columns=['file','month'])
        
        # Dump Site_Info to a Dataframe
        df = pd.DataFrame(data=dict(self.ini['Site']),index=[0])
        for c in df.columns:
            try:
                df[c]=df[c].astype('float64')
            except:
                pass

        self.Site = gpd.GeoDataFrame(
            df, geometry=gpd.points_from_xy(df.longitude, df.latitude), crs="EPSG:4326"
        )
        
        # WKT description of the NARR LCC projection
        # Source: https://spatialreference.org/ref/sr-org/8214/
        NARR_LCC = '+proj=lcc +lat_1=50 +lat_0=50 +lon_0=-107 +k_0=1 +x_0=5632642.22547 +y_0=4612545.65137 +a=6371200 +b=6371200 +units=m +no_defs'
        self.Site = self.Site.to_crs(NARR_LCC)
        
        Vars = self.ini['Downloads']['NARR_var_names'].split(',')
        
        self.out_dir = f'{self.ini["Downloads"]["nc_path"]}/{self.Site_code}'
        if os.path.isdir(self.out_dir) is False: os.makedirs(self.out_dir)

        for self.var_name in Vars:
            if os.path.isfile(f'{self.out_dir}/{self.var_name}.csv'):
                self.Trace = pd.read_csv(f'{self.out_dir}/{self.var_name}.csv',
                                parse_dates=[self.ini['NARR']['date_cols']],
                                index_col=self.ini['NARR']['date_cols']
                                )
            else:
                self.Trace = pd.DataFrame()
                
            for self.year in Years:
                if self.year >=1979 & self.year <= datetime.datetime.now().year:
                    self.check()
                    print(f'Estimating {self.var_name} for {self.year} at {self.Site_code}')
                    self.estimate_values()
            
            self.Trace = self.Trace[self.Trace.index.duplicated(keep = 'last')==False].sort_index()
            self.Trace
            self.Trace.to_csv(f'{self.out_dir}/{self.var_name}.csv')

            # Filter out hanging date (NARR data is in UTC, depending on timezone up to 8 data points will be in previous year)
            CT = self.Trace.groupby(self.Trace.index.year).count()[self.var_name]
            
            Traces_to_Write = self.Trace.loc[self.Trace.index.year.isin(CT.loc[CT>8].index)].copy()
            
            writer = configparser.ConfigParser()
            writer.read(NARR_ini)
            writer['NARR']['path_patterns']=self.var_name+',NARR'
            writer['NARR']['site']=self.Site_code
            
            with open('_Temp/Write_NARR.ini', 'w') as configfile:    # save
                writer.write(configfile)
            DatabaseFunctions.MakeTraces(os.getcwd()+'/_Temp/Write_NARR.ini',Traces_to_Write)

        self.inventory.to_csv(inv,index=False)

    def check(self):
              
        fn = f'{self.var_name}_{self.year}.nc'
        if self.inventory['file'].str.contains(fn).sum()>0:
            m = self.inventory.loc[self.inventory['file']==fn,'month'].values[0]
        else:
            m = 12

        if os.path.exists(f'{self.ini["Downloads"]["nc_path"]}/{self.var_name}_{self.year}.nc') == False:
            print(f'Could not find {self.var_name}_{self.year}.nc locally, downloading dataset')
            self.download()
        elif m < datetime.datetime.now().month-1 and datetime.datetime.now().day>1:
            print(f'Downloaded update for {self.var_name}_{self.year}.nc')
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
        if self.inventory['file'].str.contains(fn).sum()==0:
            self.inventory.loc[self.inventory.shape[0]] = [fn,self.time[-1].month]

    def estimate_values(self,pad = 2,freq = '30T'):
        # Estimates values of the variable of interest for point (or area) locations, passed as a geodataframe (self.Site)
        # Gets the smallest set of grid points containing the bounding box of the self.Site + "pad" grid points in each direction
        # Values are interpolated spatially using a radial bias function and saved to a dataframe for each point
        # Then values for each point are linearly interpolated resampled to the desired temporal resolution 
        # Saved to Outputs/NARR_interpolated_{self.var_name}_{self.year}.csv'
        
        bbox = self.Site.total_bounds
        
        self.x_bounds = [np.where(self.x<bbox[0])[0][-(1+pad)],np.where(self.x>bbox[2])[0][pad]]
        self.y_bounds = [np.where(self.y<bbox[1])[0][-(1+pad)],np.where(self.y>bbox[3])[0][pad]]

        lon_box = self.lon[self.y_bounds[0]:self.y_bounds[1],self.x_bounds[0]:self.x_bounds[1]]
        lat_box = self.lat[self.y_bounds[0]:self.y_bounds[1],self.x_bounds[0]:self.x_bounds[1]]

        m = folium.Map(location=[self.Site.geometry.y[0],self.Site.geometry.x[0]])   
        for at,on in zip (lat_box.flatten(),lon_box.flatten()):
            folium.Marker([at, on]).add_to(m)
        folium.CircleMarker([self.Site.geometry.y[0],self.Site.geometry.x[0]],popup=self.Site_code).add_to(m)
        m.save(f'{self.out_dir}/{self.var_name}_grid_pts.html')

        self.x_clip = self.x[self.x_bounds[0]:self.x_bounds[1]]
        self.y_clip = self.y[self.y_bounds[0]:self.y_bounds[1]]
        self.xi,self.yi = np.meshgrid(self.x_clip,self.y_clip)
        self.xi,self.yi = self.xi.flatten(),self.yi.flatten()
        self.xy = np.array([self.xi,self.yi]).T
        self.var_clip = self.var[:,self.y_bounds[0]:self.y_bounds[1],self.x_bounds[0]:self.x_bounds[1]]

        self.coords = np.array([self.Site.geometry.x[0:],self.Site.geometry.y[0:]]).T
            
        TS = pd.DataFrame()
        TS[self.ini['NARR']['date_cols']] = pd.to_datetime(self.time)+timedelta(hours=int(self.ini['Site']['utc_offset']))
        
        TS[self.var_name]=np.nan
        for i,row in TS.iterrows():
            TS.loc[TS.index == i, self.var_name] = self.interpolate(self.var_clip[i].flatten())
        TS = TS.set_index(self.ini['NARR']['date_cols'])
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
