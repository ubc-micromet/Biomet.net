function [stats] = ach_recalc(SiteFlag,year,month,day)
%[stats] = ach_recalc(SiteFlag,year,month,day)
%
%Function that recalcs stats for automated respiration chamber systems - Site independent - Will create file
%with different extension (ex. for SOBS = .rb.mat) than the one calculated at the site (= .sb.mat)
%
%Input variables: SiteFlag
%						year	
%						month
%						day (start and end)
%
%(c) dgg                
%Created:   April 2, 2004
%Revision:  lots
recalc = 1;

warning off;

[pthIn,pthOut] = FR_get_local_path;
pthLog = 'D:\met-data\log\';

startDate   = datenum(year,month,day(1),0.5,0,0);
endDate     = datenum(year,month,day(end),0.5,0,0);

for g = startDate:endDate
   
   try
   tic;
   
   %get inifile information
   c = fr_get_init(SiteFlag,g);
   
   %prepare filename for final storage
   FileName_p = FR_DateToFileName(g);
   FileName   = [pthOut FileName_p(1:6) c.chamber.HH_ext];  
   
   %get barometric pressure data from clean database
	Stats.pBarTmp  = read_bor(['\\ANNEX001\DATABASE\' num2str(year) '\' SiteFlag '\Clean\SecondStage\barometric_pressure_main'],1,[],[]);
   Stats.tvTmp  = read_bor(['\\ANNEX001\DATABASE\' num2str(year) '\' SiteFlag '\Clean\SecondStage\clean_tv'],8,[],[]);

   %calculate chamber stats
   [stats.Chambers] = ach_calc(SiteFlag,g,Stats,c,recalc);

   %save output structure stats
   save(FileName,'stats');
   disp(sprintf('File %s processed in %4.2f (s)',FileName_p(1:6),toc));
   
	catch
   %if not able to recalculate chamber data, create log file and index bad file
   currentDate = FR_DateToFileName(now);
   disp(['File ' FileName_p(1:6) ' corrupted, mission aborted!']);
   
	end
end

