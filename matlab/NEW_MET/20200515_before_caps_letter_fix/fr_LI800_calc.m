function co2 = fr_LI800_calc(RawData_mV,c_range,v_range,c_offset,CO2_cal)
% fr_LI800_calc - calculates LI800 co2 (ppm) from a milivolt input
%
%  Inputs:
%       RawData_mV      - milivolt measurement 
%       c_range         - LI800 ppm range (usually 0-2000ppm)
%       v_range         - LI800 mV range  (usually 0-5000mV)
%       c_offset        - LI800 preset co2 offset (usually 25ppm)
%       CO2_cal         - additional calibration poly:  [gain offset]
%  Outputs:
%       co2             - ppm value
%
% (c) Zoran Nesic               File created:       Aug 04, 2001
%                               Last modification:  Dec 03, 2002
%
% Revisions:
%
% Dec 03, 2002
%   -added 3 first lines to avoid problems with the inifile when CO2_cal is not available. Does not
%    change anything to other programs (David)
% Nov 20, 2002
%   -changed:
%           co2 = (co2 + CO2_cal(2)) .* CO2_cal(1);
%   -to:
%           co2 = (co2 - CO2_cal(2)) .* CO2_cal(1);

if exist('CO2_cal')~=1 | isempty(CO2_cal) 
    CO2_cal = [1 0];                                       
end

co2 = RawData_mV .* c_range ./ v_range - c_offset;
co2 = (co2 - CO2_cal(2)) .* CO2_cal(1);

