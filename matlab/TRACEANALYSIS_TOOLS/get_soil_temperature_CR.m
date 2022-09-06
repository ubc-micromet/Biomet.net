function [Ts,tv] = get_soil_temperature_CR(trace_name,year)
% Ts = get_soil_temperature_CR(trace_name)
%
% Reads all availablel CR soil temperature data from trace trace_name 
% and fills all gaps by linear interpolation

if ~exist('trace_name') | isempty(trace_name)
   trace_name = 'soil_temperature_5cm';
end
   
get_traces_db('cr',year,'cl',{'clean_tv' trace_name });
eval(['Ts = ' trace_name ';']);

% Fill the NaNs in the soil temperature trace
ind_nan   = find( isnan(Ts));
ind_nonan = find(~isnan(Ts));
Ts_nan = interp1(ind_nonan,Ts(ind_nonan),ind_nan);
Ts(ind_nan) = Ts_nan;

tv = clean_tv;
