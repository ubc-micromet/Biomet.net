from tzfpy import get_tz
from datetime import *
import pandas as pd
import pytz

class Tzfuncs():
    # Takes an input timezone or auto-determines a (DST aware) timezone from lat/lon coordinates
    # Will convert to TZ aware "UTC_time" and "Local_Time" along with non-TZ aware / non DST "Standard_Time"

    def __init__(self,Time_Zone=None,lat_lon=None,DST=False):
        self.DST = DST
        if Time_Zone is not None:
            self.Time_Zone = pytz.timezone(Time_Zone)
        elif lat_lon is not None:
            self.AssumeTZ(lat_lon[1],lat_lon[0])
        else:
            print(f'No Time Zone Info Provided')

    def AssumeTZ(self,lon,lat):
        print(f'Timezone not provided, estimating for {lon}, {lat}')
        self.Time_Zone = pytz.timezone(get_tz(lon,lat))

    def convert(self,Input_Time,from_UTC=False,to_UTC=False):
        if isinstance(Input_Time,pd.DatetimeIndex):
            Input_Time=Input_Time.to_series()
        if from_UTC == False:
            self.Local_Time=Input_Time
            self.to_StandardTime(to_UTC)
        else:
            self.UTC_Time=Input_Time
            self.fromUTC()

    def to_StandardTime(self,to_UTC=False):
        offset = self.Local_Time.apply(lambda x: self.Time_Zone.dst(x,is_dst=self.DST))
        if self.DST == True:
            self.Standard_Time = pd.DatetimeIndex(self.Local_Time-offset)
            self.Local_Time = self.Local_Time.apply(lambda x: self.Time_Zone.localize(x,is_dst=self.DST))
        else:
            self.Standard_Time = pd.DatetimeIndex(self.Local_Time)
            self.Local_Time = (self.Local_Time+offset).apply(lambda x: self.Time_Zone.localize(x,is_dst=self.DST))
        if to_UTC == True:
            self.toUTC()
        self.Local_Time = pd.DatetimeIndex(self.Local_Time)

    def toUTC(self):
        self.UTC_Time = pd.DatetimeIndex(self.Local_Time.apply(lambda x: x.astimezone(pytz.utc)))

    def fromUTC(self):
        self.UTC_Time = self.UTC_Time.apply(lambda x: pytz.utc.localize(x, is_dst=self.DST))
        self.Local_Time = self.UTC_Time.apply(lambda x: x.astimezone(self.Time_Zone).replace(tzinfo=None))
        self.to_StandardTime(to_UTC=False)
        self.UTC_Time = pd.DatetimeIndex(self.UTC_Time)