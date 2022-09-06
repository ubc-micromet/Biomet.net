function [CAL_1,CAL_2,calTime] = fr_get_cal_conc(par1,dateIn,DAQ_SYS_TYPE,pth)
% fr_get_cal_conc - returns calibration gas concentrations from the calibration file
%
% The call to this function can have two syntaxes:
%   1. Working on the eddy Licor cal. file
%       function [CO2_cal, H2O_cal, cal_voltage, calTime] = 
%                               fr_get_Licor_cal(SiteID,dateIn,DAQ_SYS_TYPE,pth)
%   2. Working on any specific Licor cal file
%       function [CO2_cal, H2O_cal, cal_voltage, calTime] = 
%                               fr_get_Licor_cal(calFileName,dateIn)
%
% 
%
% (c) kai*       File created:       Aug  11, 2003
%                Last modification:  Jul 14, 2003

VB2MatlabDateOffset = 693960;

if exist(par1,'file')==2
    calFileName = par1;
    fid = fopen(calFileName,'r');
    if fid < 3
        error(['Cannot open file: ' calFileName])
    end        
else
    if exist('par1')~=1 | isempty(par1)
        SiteID = fr_current_siteID;
    else
        SiteID = par1;
    end

    if exist('pth')~=1 | isempty(pth)
        [junk, pth] = FR_get_local_path;                            % site computer and use the local path
    end

    switch upper(SiteID)
        case 'CR', ext = ['cc' int2str(DAQ_SYS_TYPE)];
        case 'PA', ext = ['cp' int2str(DAQ_SYS_TYPE)];
        case 'BS', ext = ['cb' int2str(DAQ_SYS_TYPE)];
        case 'JP', ext = ['cj' int2str(DAQ_SYS_TYPE)];
        otherwise, error 'Wrong site ID!'
    end

    fileName = [pth 'calibrations.' ext];

    fid = fopen(fileName,'r');
    if fid < 3
        error(['Cannot open file: ' fileName])
	    end
end

cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
[n,m] = size(cal_voltage);

calTime=(cal_voltage(1,:)+cal_voltage(2,:))'+VB2MatlabDateOffset;       % convert calibration times to a time vector

if exist('dateIn')~=1 | isempty(dateIn)                                 % dateIn not given use dateIn = calTime
    dateIn = calTime;                                                   % in that case all the cal values are returned
end
ind_tv = find(calTime >= dateIn(1) & calTime <= dateIn(end));              % find all calibrations for the given dates

if isempty(ind_tv)
      ind_tv = find(calTime<dateIn);
      [junk, ind]= min(dateIn-calTime(ind_tv));
      ind_tv = ind_tv(ind);
end

calTime = calTime(ind_tv);                                                 % extract the requsted range
CAL_1 = cal_voltage(4,ind_tv);
CAL_2 = cal_voltage(5,ind_tv);