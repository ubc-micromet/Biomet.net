function run_chamber_rename(dateIn)
[tv2,climateData2] = ach_move_and_rename(dateIn,'D:\met-data\csi_net\chambers_temp','Yf_acs2.DAT','d:\met-data\data\',101,'sec');
[tv2,climateData2] = ach_move_and_rename(dateIn,'D:\met-data\csi_net\chambers_temp','Yf_acs1.DAT','d:\met-data\data\',102,'30min');