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
%                       Last modification:  Apr 21, 2001

%
% Revisions:
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
[n,m] = size(cal_voltage);

calTime=(cal_voltage(1,:)+cal_voltage(2,:))'+VB2MatlabDateOffset;       % convert calibration times to a time vector

if exist('dateIn')~=1 | isempty(dateIn)                                 % dateIn not given use dateIn = calTime
    dateIn = calTime;                                                   % in that case all the cal values are returned
end
ind = find(calTime >= dateIn(1) & calTime <= dateIn(end));              % find all calibrations for the given dates

if isempty(ind)
    if length(dateIn) == 1
        [junk, ind]= min(abs(dateIn-calTime));
    else
        ind = zeros(2,1);
        [junk, ind(1)]= min(abs(dateIn(1)-calTime));
        [junk, ind(2)]= min(abs(dateIn(end)-calTime));
        ind = unique(ind);
    end
end

if ind(1) > 1                                                           % for proper interpolation grab
    ind = [ind(1)-1; ind];                                              % one point before
end
if ind(end) < length(calTime)                                           % and one point after
    ind = [ind ;ind(end)+1];                                            % the selected indexes
end

calTime = calTime(ind);                                                 % extract the requsted range
cal_voltage = cal_voltage(:,ind);                                       %
LicorNum = cal_voltage(3,:)';                                           %
[licors,i,j] = unique(LicorNum);                                        % find all different LI-6262s
cal_value = NaN*zeros(size(ind));                                       % create space for results
for k = licors'                                                        % cycle through all the licors
    ind1 = find(LicorNum ==k);                                         % calculate calibrations for each licor
    try
        cal_value(ind1) = fr_cal_licor(k, cal_voltage(4,ind1),cal_voltage(19,ind1),...
                             cal_voltage(23,ind1), cal_voltage(24,ind1), ...
                             cal_voltage(21,ind1), cal_voltage(22,ind1),...
                             cal_voltage(20,ind1))';                     % and store them in the output array
    end
end

CO2_cal1 = [cal_value -cal_voltage([19],:)'];                           % add zero calibrations
H2O_cal1 = [cal_value max(-cal_voltage([20 24],:))'];                   % add zero calibrations

% CO2_cal1 and H2O_cal1 have properly calculated values at the *calibration times*
% If one wants the calibration values at any arbitrary point in time 
% these calibrations need to be interpolated (using a table look-up)

CO2_cal = interp1(calTime,CO2_cal1, dateIn);
H2O_cal = interp1(calTime,H2O_cal1, dateIn);

outsideInd = find(dateIn < calTime(1));                                 % find dateIn values outside of calTime range
CO2_cal(outsideInd,1) = CO2_cal1(1,1);                                  % and use first or last cal. time instead.
CO2_cal(outsideInd,2) = CO2_cal1(1,2);                                  % 
H2O_cal(outsideInd,1) = H2O_cal1(1,1);                                  % 
H2O_cal(outsideInd,2) = H2O_cal1(1,2);                                  % 
outsideInd = find(dateIn > calTime(end));                               % this will remove NaNs put there by interp1
CO2_cal(outsideInd,1) = CO2_cal1(end,1);                                % for all the points outside of existing range
CO2_cal(outsideInd,2) = CO2_cal1(end,2);                                % 
H2O_cal(outsideInd,1) = H2O_cal1(end,1);                                % 
H2O_cal(outsideInd,2) = H2O_cal1(end,2);                                % 

