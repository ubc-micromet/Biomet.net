## Simple function to rename traces in database
## Written by June Skeeter, Jan 2024

import os
from distutils.dir_util import copy_tree
for y in range(2014,2024):
    if os.path.isdir(f'C:/Database/{y}/ECCC/')==False:
        os.mkdir(f'C:/Database/{y}/ECCC/')
    copy_tree(f"C:/Database/{y}/BB/Met/ECCC", f"C:/Database/{y}/ECCC/49088/")

# for site in ['BB','BB2']:
#     for y in range(2016,2025):
#         old_name = f"P:/Database/{y}/{site}/Met/Manual/WTH_cm"
#         new_name = f"P:/Database/{y}/{site}/Met/Manual/WTD_cm"
#         if os.path.isfile(old_name):
#             os.rename(old_name,new_name)