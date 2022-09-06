function prOut = fr_profile_calc(RawData_mV,configIni)
% fr_profile_calc - calculates profile data based on the input mV and a configuration structure
%
%
%
% (c) Zoran Nesic               File created:       Mar xx, 2001
%                               Last modification:  Aug  4, 2001
%

% Revisions:
%
% Aug 4, 2001
%   - added switch instruction and LI800 calculations


Profile = configIni.Profile;

[co2,h2o,Tbench,Plicor,Pgauge] = fr_profile_licor_calc(RawData_mV,Profile);

[prOut.co2, z, zn] = fr_profile_means(co2,Profile);

if ~isempty(h2o)
   [prOut.h2o, z, zn] = fr_profile_means(h2o,Profile);
end
if ~isempty(Tbench)
	[prOut.Tbench, z, zn] = fr_profile_means(Tbench,Profile);
end
if ~isempty(Plicor)
	[prOut.Plicor, z, zn] = fr_profile_means(Plicor,Profile);
end
if ~isempty(Pgauge)
	[prOut.Pgauge, z, zn] = fr_profile_means(Pgauge,Profile);
end

return