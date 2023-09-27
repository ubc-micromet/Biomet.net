import configparser
from tzfpy import get_tz
import datetime
import pytz 

def get_TZ(Lon,Lat,DST=True):
    TZ = get_tz(float(Lon), float(Lat)) 
    UTC_offset = pytz.timezone(TZ).localize(datetime.datetime.now(),is_dst=DST)#.strftime('%z')
    print(UTC_offset,DST)
    return(TZ,UTC_offset)


def generate(site_code,metadata,Template='Template.ini'):
    METADATA = configparser.ConfigParser()
    METADATA.read(metadata)
    template = configparser.ConfigParser()
    template.read(f'ini_files/site_configurations/{Template}')

    template.add_section(site_code)
    for key, val in template['Site'].items():
        try:
            template['Site'][key] = eval(val)
        except:
            pass
    items = template.items('Site')
    for item in items:
        template.set(site_code,str(item[0]),str(item[1]))
    template.remove_section('Site')

    # if template['Auxillary']['utc_offset']  == 'Auto':
    #     # template['Auxillary']['utc_offset'] = 
    #     get_TZ(METADATA['Site']['longitude'],METADATA['Site']['latitude'])[1]

    with open(f'ini_files/site_configurations/{site_code}.ini','w+') as file:
        template.write(file)
         
if __name__ == '__main__':
    MD = "C:\\highfreq\\DSM\\raw\\2022\\10\\2022-10-01T000000_AIU-2264.metadata"
    generate('DSM',metadata=MD)