function [CO2_cal, H2O_cal, cal_voltage, calTime,LicorNum] = fr_get_Licor_cal(par1,dateIn,DAQ_SYS_TYPE,pth)
% fr_get_Licor_cal - returns Licor 6262 calibrations from the calibration file
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
% (c) Zoran Nesic       File created:       Oct  5, 2000
%                       Last modification:  Sep 16, 2003

%
% Revisions:
%  Sep 16, 2003
%   - Bug fix: default dateIn = []; if undefined
%  Aug 16, 2003
%   - Put the core part of the function into a new function called fr_calc_licor_cal
%  Jul 14, 2003
%   - made the program use the bench temperature and pressure during Span cal1 
%     flow (lines 25&26 from the cal file), not zeroing (lines 21&22 from the cal file)
%  Aug  3, 2001
%   - made the program use the corrected values from the calibration file
%     not the measured ones (lines 10-15 from the cal file not 19-25)
%  Apr 21, 2001
%   - changed the help info
%  Mar 21, 2001
%   - changed the calling syntax. Now user can select to call the
%     calibration file by its full name instead using the 
%     default locations/names. The old syntax is kept as is.
%

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

calTime=(cal_voltage(1,:)+cal_voltage(2,:))'+VB2MatlabDateOffset;       % convert calibration times to a time vector

if exist('dateIn')~=1 | isempty(dateIn)                                 
    dateIn = [];                                                   
end

[CO2_cal, H2O_cal, cal_voltage, calTime,LicorNum] = fr_calc_Licor_cal(calTime,cal_voltage,dateIn);