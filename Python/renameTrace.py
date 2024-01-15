## Simple function to rename traces in database
## Written by June Skeeter, Jan 2024

import os
for site in ['BB','BB2']:
    for y in range(2016,2025):
        old_name = f"P:/Database/{y}/{site}/Met/Manual/WTH_cm"
        new_name = f"P:/Database/{y}/{site}/Met/Manual/WTD_cm"
        if os.path.isfile(old_name):
            os.rename(old_name,new_name)