function [Fc_wpl, E_wpl] = apply_WPL_correction(w_cc, w_cv, w_T, cc, cv, T, P)                

%WPL Correction for Biomet database (Amanda, August 2010)

% pth = biomet_path(YearX,SiteID);
% tv = read_bor(fullfile(pth ,'Flux_Logger\Clean_tv'),8);
% w_cc = read_bor(fullfile(pth,'Flux_Logger\CO2_cov_Cov5'));   % load covariances
% w_cv = read_bor(fullfile(pth,'\Flux_Logger\CO2_cov_Cov9'));
% w_T = read_bor(fullfile(pth,'\Flux_Logger\Tsonic_cov_Cov4'));
% cc = read_bor(fullfile(pth,'\Flux_Logger\CO2_Avg'));              % cc is molar CO2 density (mmol/m3)
% cv = read_bor(fullfile(pth,'\Flux_Logger\H2O_Avg'));              % cv is molar water vapour density (mmol/m3)
% T = read_bor(fullfile(pth,'\Flux_Logger\Tsonic_avg'));            % load T (deg C)
% P = read_bor(fullfile(pth,'\Flux_Logger\Irga_P_Avg'));         % load P [kPa] 

% convert units (Temperature to K and Pressure to Pa)
T = T + 273.15;
P = P .* 1000;

% calculate c (total molar density of moist air) using gas law P = RcT and convert from mol to mmol
c = P ./ (T.*8.314) .* 1000;                               

% calculate dry air density cd (mmol/m3)
cd = c - cv - cc;

% calculate Fc with WPL correction and convert to micromol m-2 s-1
Fc_wpl = (w_cc + (cc./cd) .* (w_cv + (c.*w_T ./ T))) .* 1000; 

% calculate E with WPL correction (mmol m-2 s-1)
E_wpl = (1 + (cv./cd)) .* (w_cv + (cv.*w_T ./ T)); 

% plot graph
% doy = tv-datenum(2010,1,0)-8/24;
% plot(doy,Fc_wpl);
% ax=axis;
% axis([ax(1:2) -20 10]);

    