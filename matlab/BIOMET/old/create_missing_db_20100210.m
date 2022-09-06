function create_missing_db(Year)
% Create profile and cal_stats databases that were missing 
% after Zoran created the new database for 2005

pth_db = db_pth_root;

% create missing profile db
x = DB_create_profile([pth_db num2str(Year) '\bs\profile\'],Year,'bs');
x = DB_create_profile([pth_db num2str(Year) '\cr\profile\'],Year,'cr');
x = DB_create_profile([pth_db num2str(Year) '\jp\profile\'],Year,'jp');
x = DB_create_profile([pth_db num2str(Year) '\pa\profile\'],Year,'pa');

% create missing chambers db
fr_set_site('bs','n')
x = DB_create_chambers([pth_db num2str(Year) '\bs\chambers\'],Year,'bs');

fr_set_site('pa','n')
x = DB_create_chambers([pth_db num2str(Year) '\pa\chambers\'],Year,'pa');

fr_set_site('cr','n')
x = DB_create_chamber_paul([pth_db num2str(Year) '\cr\chambers\'],Year);

% create missing cal_stats db for BS,CR,JP,PA for eddy, profile and
% chambers
x = DB_create_cal_stats([pth_db num2str(Year) '\bs\flux\'],Year);
x = DB_create_cal_stats([pth_db num2str(Year) '\bs\profile\'],Year);
x = DB_create_cal_stats([pth_db num2str(Year) '\bs\chambers\'],Year);

x = DB_create_cal_stats([pth_db num2str(Year) '\cr\flux\'],Year);
x = DB_create_cal_stats([pth_db num2str(Year) '\cr\profile\'],Year);
x = DB_create_cal_stats([pth_db num2str(Year) '\cr\chambers\'],Year);

x = DB_create_cal_stats([pth_db num2str(Year) '\jp\flux\'],Year);
x = DB_create_cal_stats([pth_db num2str(Year) '\jp\profile\'],Year);
x = DB_create_cal_stats([pth_db num2str(Year) '\jp\chambers\'],Year);

x = DB_create_cal_stats([pth_db num2str(Year) '\pa\flux\'],Year);
x = DB_create_cal_stats([pth_db num2str(Year) '\pa\profile\'],Year);
x = DB_create_cal_stats([pth_db num2str(Year) '\pa\chambers\'],Year);


