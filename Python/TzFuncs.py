from tzfpy import get_tz
from datetime import *
import pandas as pd
import pytz

class Tzfuncs():
    def __init__(self,Input_Time,Time_Zone='UTC',lat_lon=None,DST=False):
        if isinstance(Input_Time,pd.DatetimeIndex):
            self.Local_Time=Input_Time.to_series()
        else:
            self.Local_Time=Input_Time
        self.DST = DST

        self.Time_Zone = pytz.timezone(Time_Zone)
        if lat_lon is not None:
            self.AssumeTZ(lat_lon[1],lat_lon[0])
        print(f'Initialized for: {self.Time_Zone}')

        self.to_StandardTime()
        self.toUTC()
        self.Local_Time = pd.DatetimeIndex(self.Local_Time)

    def AssumeTZ(self,lon,lat):
        print(f'Timezone not provided, estimating for {lon}, {lat}')
        self.Time_Zone = pytz.timezone(get_tz(lon,lat))

    def to_StandardTime(self):
        offset = self.Local_Time.apply(lambda x: self.Time_Zone.dst(x,is_dst=self.DST))
        if self.DST == True:
            self.Standard_Time = pd.DatetimeIndex(self.Local_Time-offset)
            self.Local_Time = self.Local_Time.apply(lambda x: self.Time_Zone.localize(x,is_dst=self.DST))
        else:
            self.Standard_Time = pd.DatetimeIndex(self.Local_Time)
            self.Local_Time = (self.Local_Time+offset).apply(lambda x: self.Time_Zone.localize(x,is_dst=self.DST))
        
    def toUTC(self):
        self.UTC_Time = pd.DatetimeIndex(self.Local_Time.apply(lambda x: x.astimezone(pytz.utc)))