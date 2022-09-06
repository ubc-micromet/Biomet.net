% Do this for BS CR JP PA
% SiteId = 'PA';
% Year = 2004;
% pth_base = ['D:\DataBase\' num2str(Year) '\' SiteId '\']


x = DB_create_profile([pth_base 'Profile\'],Year,SiteId)

x = DB_create_cal_stats([pth_base 'Flux\'],Year)
x = DB_create_cal_stats([pth_base 'Profile\'],Year)

% BERMS only
x = DB_create_cal_stats([pth_base 'Chambers\'],Year)

% Just CR
x = DB_create_chamber_paul([pth_base 'Chambers\'],Year)
