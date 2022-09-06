function [evOut,fluxOut] = fr_chamber_calc_flux(SiteFlag,...
                                                Stats,...
                                                Time_vector21x,...
                                                TimeVectorHH_21x,...
                                                flow_rate,...
                                                co2_ppm,...
                                                c);
% Function that calculates effective volumes and fluxes of automated respiration 
%  chambers (from high frequency measurements of co2)
%
% Called within fr_chamber_calc (fr_calc_main and fr_calc_and_save)
%
% Syntax:   [evOut,fluxOut] = fr_chamber_calc_flux(SiteFlag,...
%                                                  Stats,...
%                                                  Time_vector21x,...
%                                                  TimeVectorHH_21x,...
%                                                  flow_rate,...
%                                                  co2_ppm,...
%                                                  c);
%
% Created by David Gaumont-Guay 2002.02.14 (from Tim Griffis's work)
% Revisions: none

k=0;

tv_dec = datevec(Time_vector21x);
sd = datenum(tv_dec(1,1),tv_dec(1,2),tv_dec(1,3),tv_dec(1,4),0,5);        % start day
ed = datenum(tv_dec(end,1),tv_dec(end,2),tv_dec(end,3),tv_dec(end,4),0,0); % end day

slope_increment = datenum(0,0,0,0,5,0); % 5 minutes
sslope = 1; % start slope (minute1)
eslope = 2; % end slope (minute2)

for slope_time = sd:slope_increment:ed

   k = k + 1;

   indSlope = find(Time_vector21x >= (slope_time + datenum(0,0,0,0,sslope,0))...
      & Time_vector21x <= (slope_time + datenum(0,0,0,0,eslope,0)));

   tv_slope    = datevec(slope_time); % identification of the slope (hr and min)
   hour_slope  = tv_slope(:,4);       
   min_slope   = tv_slope(:,5) + 5;     
             
   tv_reg      = 1:length(indSlope);
   tv_reg      = tv_reg(:)*5;
   co2_reg     = co2_ppm(indSlope);
   co2_reg     = co2_reg(:);
   flow_rate_tmp  = flow_rate(indSlope);
   flow_rate_mean = mean(flow_rate_tmp);
           
   [dcdt,r2] = ch_regression(tv_reg,co2_reg);

   data_slope(k,1) = floor(slope_time*48)/48; % nearest half-hour
   data_slope(k,2) = dcdt;                    % dcdt (slope)
   data_slope(k,3) = r2;                      % rsquare (slope)
   data_slope(k,4) = flow_rate_mean;          % flow rate (MFC)
   data_slope(k,5) = min_slope;               % min
   data_slope(k,6) = hour_slope;              % hour

end

DATA = [DATA;data_slope];

% ---

for ch = 1:c.chamber.nbr_chambers

   % --- effective volume calculations ---

   ind_vol = find((DATA(:,5) == ((ch*c.chamber.length_slope) + ((ch-1)* ...
      c.chamber.length_slope)) & (DATA(:,6) == 0 | DATA(:,6) == 12)) | ...
      (DATA(:,5) == ((ch*c.chamber.length_slope) + (ch*c.chamber.length_slope)) &...
      (DATA(:,6) == 0 | DATA(:,6) == 12)));    

   data_vol(ind_vol,:) = DATA(ind_vol,:);
   ind_bad_vol = find(data_vol(:,1) == 0);
   data_vol(ind_bad_vol,:) = [];

   % stats EV

   evOut(1,ch) = data_vol(1,2);   % store dcdt ch 24:00 in evOut
   evOut(2,ch) = data_vol(2,2);   % store dcdt ch+cal 24:00 in evOut
   evOut(3,ch) = data_vol(1,3);   % store rsquare ch 24:00 in evOut
   evOut(4,ch) = data_vol(2,3);   % store rsquare ch+cal 24:00 in evOut
   evOut(5,ch) = data_vol(1,4);   % store flow ch 24:00 in evOut
   evOut(6,ch) = data_vol(2,4);   % store flow ch+cal 24:00 in evOut

   evOut(1,ch+6) = data_vol(3,2); % store dcdt ch 12:00 in evOut
   evOut(2,ch+6) = data_vol(4,2); % store dcdt ch+cal 12:00 in evOut
   evOut(3,ch+6) = data_vol(3,3); % store rsquare ch 12:00 in evOut
   evOut(4,ch+6) = data_vol(4,3); % store rsquare ch+cal 12:00 in evOut
   evOut(5,ch+6) = data_vol(3,4); % store flow ch 12:00 in evOut
   evOut(6,ch+6) = data_vol(4,4); % store flow ch+cal 12:00 in evOut

   % calc EV

   Ccal = c.chamber.effective_vol_gas * 1e6; % calibration tank concentration (ppm)

   flow_cal_1 = data_vol(2,4)/60; % ml\s
   dcdt_cal_1 = data_vol(2,2);    % ppm\s 
   dcdt_ch_1  = data_vol(1,2);    % ppm\s
   vol_eff_1  = ((flow_cal_1 .* Ccal) ./ (dcdt_cal_1 - dcdt_ch_1))./1000./1000; % m3
   evOut(7,ch) = vol_eff_1;        % store effective volume in evOut

   flow_cal_2 = data_vol(4,4)/60; % ml\s
   dcdt_cal_2 = data_vol(4,2);    % ppm\s 
   dcdt_ch_2  = data_vol(3,2);    % ppm\s
   vol_eff_2  = ((flow_cal_2 .* Ccal) ./ (dcdt_cal_2 - dcdt_ch_2))./1000./1000; % m3
   evOut(7,ch+6) = vol_eff_2;     % store effective volume in evOut

   % --- fluxes calculations ---

   ind_flux = find(DATA(:,5) == (ch*c.chamber.length_slope) | ...
      DATA(:,5) == ((ch+c.chamber.nbr_chambers)*c.chamber.length_slope));    

   data_flux(ind_flux,:) = DATA(ind_flux,:);
   ind_bad_flux = find(data_flux(:,1) == 0); 
   data_flux(ind_bad_flux,:) = [];

   ind_bad_cal_ch1   = find(data_flux(:,6) == 0 | data_flux(:,6) == 12); % chamber calibration
   ind_bad_cal_ch2   = find((data_flux(:,6) == 13) & data_flux(:,5) == (ch*c.chamber.length_slope));% first half-hour(no measurement)
   ind_bad_cal_licor = find((data_flux(:,6) == 1 & data_flux(:,5) == (ch*c.chamber.length_slope))); % licor calibration

   data_flux(ind_bad_cal_ch1,2:end)   = NaN;
   data_flux(ind_bad_cal_ch2,2:end)   = NaN;
   data_flux(ind_bad_cal_licor,2:end) = NaN;

   % stats F

   fluxOut.Dcdt(:,ch)    = data_flux(:,2); % store dcdt in fluxOut  
   fluxOut.Rsquare(:,ch) = data_flux(:,3); % strore rsquare in fluxOut

   air_t = squeeze(Stats.BeforeRot.AvgMinMax(1,13,:)) + 273.15;  % Kelvins
   pbar  = squeeze(Stats.BeforeRot.AvgMinMax(1,20,:)) .* 1000;   % Pascals

   % calc F

   R = 8.3144; % J mol-1 K-1 (or J Kg-1 K-1)
   
   if SiteFlag == 'PA' & ch == 2
      A = 0.33; % bole chamber area PA (m2)
   elseif SiteFlag == 'PA' & ch == 3
      A = 0.33; % bole chamber area PA (m2)
   else 
      A = 0.20; % soil chambers area (m2)
   end 

   vol_eff_tmp = (vol_eff_1 + vol_eff_2)/2; % mean effective volume for the day (m3)
   vol_eff = NaN .* zeros(length(TimeVectorHH_21x),1); 
   vol_eff(:,1) = vol_eff_tmp; 

   flux = pbar .* vol_eff .* data_flux(:,2) ./ (R .* air_t .* A);

   fluxOut.Flux(:,ch) = flux;    % store flux in fluxOut
   fluxOut.Ev(:,ch)   = vol_eff; % store effective volume in fluxOut

   clear data_vol;
   clear data_flux;

end

% --- structure evOut ---

% matrix 7 x 12
% colums:
%  1: midnight calibration chamber 1
%  2: noon calibration chamber 1
%  ...
%
% rows:
%  1: dcdt ch
%  2: dcdt ch+cal
%  3: rsquare ch
%  4: rsquare ch+cal
%  5: flow ch
%  6: flow ch+cal 
%  7: effective_volume


% --- structure fluxOut ---

% Fluxes             = 48 hhours x 6 chambers
% Dcdt               ...
% Rsquare            ...
% Effective_volume   ...