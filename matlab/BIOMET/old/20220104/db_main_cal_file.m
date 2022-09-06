function db_main_cal_file(SiteId,pth_in,pth_out,Years)
% Function to generate calibration database for all licors run at all sites
% The 30 values in the cal file are saved as cal.1 to cal.30 in a subdir
% cal under the system directory (one of Flux, Profile, Chambers). 
% Each year only contains that year's calibrations.
% Unlike most other database section, these files only have entries for the
% actual calibrations times NOT each hhour of the year

% kai* Dec 19, 2003
% Last revision:

switch upper(SiteId)
case {'CR','HJP02','OY','YF'}
    SiteName = SiteId;
case {'BS'}
    SiteName = 'PAOB';
case {'JP'}
    SiteName = 'PAOJ';
case {'PA'}
    SiteName = 'PAOA';
end

VB2MatlabDateOffset = 693960;

lst_fl = dir(fullfile(pth_in,['calibrations.c' SiteId(1) '2']));
lst_pr = dir(fullfile(pth_in,['calibrations.c' SiteId(1) '_pr']));
lst_ch = dir(fullfile(pth_in,['calibrations.c' SiteId(1) '_ch']));
lst = [lst_fl lst_pr lst_ch];

diary(fullfile(db_pth_root,num2str(max(Years)),SiteId,'dbase_cal.log'))
disp(sprintf('==============  Start ========================================='));
disp(sprintf('Date: %s',datestr(now)));
disp(sprintf('Variables: '));
disp(sprintf('pthIn = %s',pth_in));
disp(sprintf('pthOut = %s',pth_out));
disp(sprintf('Years updated = %s',num2str(Years)));

k = 0;
for i = 1:length(lst)
   
   cal_fileName = char(fullfile(pth_in,lst(i).name));
   
   fid = fopen(cal_fileName,'r');
   if fid == -1
      error(['Could not open ' cal_fileName])
   end
   cal_voltage = fread(fid,[30 inf],'float32');
   fclose(fid);
   
   calTime=(cal_voltage(1,:)+cal_voltage(2,:))'+VB2MatlabDateOffset;       % convert calibration times to a time vector
   dv_cal = datevec(calTime);
   
   if ~exist('Years') | isempty(Years)
      Years = unique(dv_cal(:,1));
   end
   
   switch lower(cal_fileName(end))
   case '2'
      pth_sys = 'Flux\';
   case 'r'
      pth_sys = 'Profile\';
   case 'h'
      pth_sys = 'Chambers\';
   end
   
   for j = 1:length(Years)
      
      if exist(fullfile(pth_out,pth_sys,'')) == 7
         if exist(fullfile(pth_out,pth_sys,'\cal','')) ~= 7
            mkdir(fullfile(pth_out,pth_sys,''),'cal');
         end
         
         db_update_cal_file(Years(j),cal_fileName,fullfile(pth_out,pth_sys,'cal'));
      end
   end
   k = k+1;
end

disp(sprintf('Number of files processed = %d',k));
disp(sprintf('==============  End    ========================================='));
disp(sprintf(''));
diary off
