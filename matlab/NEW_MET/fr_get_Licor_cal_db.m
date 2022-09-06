function [CO2_cal, H2O_cal, cal_voltage, calTime,LicorNum] = fr_get_Licor_cal_db(par1,dateIn,system)
% fr_get_Licor_cal_db - returns Licor 6262 calibrations from the database info
%
% The call to this function can have two syntaxes:
%   1. Working on site and system information 
%       function [CO2_cal, H2O_cal, cal_voltage, calTime] = 
%                               fr_get_Licor_cal_db(SiteId,dateIn,system)
%      where system is one of 'FLUX','PROFILE', or 'CHAMBERS'
%   2. Working on a specific cal directory
%       function [CO2_cal, H2O_cal, cal_voltage, calTime] = 
%                               fr_get_Licor_cal_db(pth,dateIn)
%
% (c) kai*       File created:       Aug 16, 2003
%                Last modification:  

%
% Revisions:
%

if find(par1 == '\')
   pth = par1;
else
   if exist('par1')~=1 | isempty(par1)
      SiteId = fr_current_SiteId;
   else
      SiteId = par1;
   end
   yy = datevec(dateIn);
   yy = unique(yy(:,1));
   
   pth = biomet_path('yyyy',SiteId,fullfile(system,'cal',''));
end

exist_pth = zeros(size(yy));
for i = 1:length(yy)
    exist_pth(i) = exist(biomet_path(yy(i),SiteId,fullfile(system,'cal','')));
end

if prod(exist_pth) ~= 7^length(exist_pth)
   CO2_cal		= [];
   H2O_cal		= [];
   cal_voltage	= [];
   calTime		= [];
   LicorNum		= [];
else
   calTime = read_bor(fullfile(pth,['cal_tv']),8,[],yy);
   cal_voltage = NaN .* ones(30,length(calTime));
   for i = 1:30
      cal_voltage(i,:) = read_bor(fullfile(pth,['cal.' num2str(i)]),[],[],yy)';
   end
   
   % From here the function is identical to fr_get_Licor_cal
   [CO2_cal, H2O_cal, cal_voltage, calTime,LicorNum] = fr_calc_Licor_cal(calTime,cal_voltage,dateIn);
   
end
