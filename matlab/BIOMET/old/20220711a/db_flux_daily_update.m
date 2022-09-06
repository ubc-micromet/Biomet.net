function k = db_flux_daily_update(dateIn,SiteID,system_fieldname)

% Last updated: Dec 19, 2007

% Revisions:
% Dec 19, 2007
%   -replaced hardwired db path with db_pth_root (Nick)

switch upper(SiteID)
case {'CR','HJP02','OY','YF'}
    SiteName = SiteID;
case {'BS'}
    SiteName = 'PAOB';
case {'JP'}
    SiteName = 'PAOJ';
case {'PA'}
    SiteName = 'PAOA';
end

pth_db = db_pth_root; % added Dec 19, 2007

pthIn = ['\\paoa001\Sites\' SiteName '\hhour\'];
dateV = datevec(dateIn);
yearX = dateV(1);

if upper(SiteID(1:2)) == 'OY'
    pthOut = [pth_db num2str(yearX) '\' SiteID '\flux\pc\'];
else
    pthOut = [pth_db num2str(yearX) '\' SiteID '\flux\'];
end


x = fr_datetofilename(dateIn);
x = x(1:6);
wildcard = [num2str(x) '*.mat'];

diary(['\\paoa001\Sites\' SiteName '\dbase.log'])
disp(sprintf('==============  Start ========================================='));
disp(sprintf('Date: %s',datestr(now)));
disp(sprintf('Variables: '));
disp(sprintf('pthIn = %s',pthIn));
disp(sprintf('wildcard = %s',wildcard));
disp(sprintf('pthOut = %s',pthOut));
disp(sprintf('system_fieldname = %s',system_fieldname));

switch upper(SiteID)
case {'HJP02','OY','YF'}
    k = db_main_update_neweddy(pthIn,wildcard,pthOut,system_fieldname);
case {'BS','CR','JP','PA'}
    k = db_main_update_eddy(pthIn,wildcard,pthOut);
end

disp(sprintf('Number of files processed = %d',k));
disp(sprintf('==============  End    ========================================='));
disp(sprintf(''));
diary off
