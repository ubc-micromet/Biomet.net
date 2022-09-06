function create_missing_cal_stats_db(Year)

% creates missing cal_stats files on Annex001 database

% Nick, Sept 22/06

pth_db = db_pth_root;

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


