function yf_temperature_comp
% Compares the sonic and HMP temperatures for YF from 2002 to 2004
%
% For measurements in July and August with relative humidity below 70%
% there is a systematic variation over the course of the 3 three years

kais_plotting_setup

%------------------------------------------
% Read data
%------------------------------------------
[Ts,tv] = read_db(2002:2004,'yf','flux\clean','temperature_avg_gill');
Ta = read_db(2002:2004,'yf','climate\clean','air_temperature_hmp_12m');
rh = read_db(2002:2004,'yf','climate\clean','relative_humidity_hmp_12m');

%------------------------------------------
% Regressions
%------------------------------------------
dv = datevec(tv(:));

for y = 2002:2004
    figure;
    title([num2str(y) ' July and August, r_h < 70%']);
    ind = find(dv(:,1) == y & (dv(:,2) == 7 | dv(:,2) == 8) & rh<70);
    plot_regression(Ta(ind),Ts(ind));
    xlabel('T_{HMP} (^oC)')
    ylabel('T_{Gill} (^oC)')
end

