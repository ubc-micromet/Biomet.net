function create_missing_db(Year)
% Create profile and cal_stats databases that were missing 
% after Zoran created the new database for 2005

x = DB_create_profile(['y:\database\' num2str(Year) '\bs\profile\'],Year,'bs');
x = DB_create_profile(['y:\database\' num2str(Year) '\cr\profile\'],Year,'cr');
x = DB_create_profile(['y:\database\' num2str(Year) '\jp\profile\'],Year,'jp');
x = DB_create_profile(['y:\database\' num2str(Year) '\pa\profile\'],Year,'pa');

fr_set_site('bs','n')
x = DB_create_chambers(['y:\database\' num2str(Year) '\bs\chambers\'],Year,'bs');
% fr_set_site('jp','n')
% x = DB_create_chambers(['y:\database\' num2str(Year) '\jp\chambers\'],Year,'jp');
fr_set_site('pa','n')
x = DB_create_chambers(['y:\database\' num2str(Year) '\pa\chambers\'],Year,'pa');

x = DB_create_cal_stats(['y:\database\' num2str(Year) '\bs\flux\'],Year);
x = DB_create_cal_stats(['y:\database\' num2str(Year) '\bs\profile\'],Year);
x = DB_create_cal_stats(['y:\database\' num2str(Year) '\bs\chambers\'],Year);

x = DB_create_cal_stats(['y:\database\' num2str(Year) '\cr\flux\'],Year);
x = DB_create_cal_stats(['y:\database\' num2str(Year) '\cr\profile\'],Year);
x = DB_create_cal_stats(['y:\database\' num2str(Year) '\cr\chambers\'],Year);

x = DB_create_cal_stats(['y:\database\' num2str(Year) '\jp\flux\'],Year);
x = DB_create_cal_stats(['y:\database\' num2str(Year) '\jp\profile\'],Year);
x = DB_create_cal_stats(['y:\database\' num2str(Year) '\jp\chambers\'],Year);

x = DB_create_cal_stats(['y:\database\' num2str(Year) '\pa\flux\'],Year);
x = DB_create_cal_stats(['y:\database\' num2str(Year) '\pa\profile\'],Year);
x = DB_create_cal_stats(['y:\database\' num2str(Year) '\pa\chambers\'],Year);


