function [chOut] = fr_chamber_calc(SiteFlag,currentDate,Stats,c)
% Function that computes stats for automated respiration chambers 
%  and pepare output structure 
%
% Called within fr_calc_main (fr_calc_and_save)
%
% Syntax:   [chOut] = fr_chamber_calc(SiteFlag,currentDate,c)
%
% Created by David Gaumont-Guay 2002.02.14 (from Tim and Gord's work)
% Revisions: none

tic;
[data_21x,data_CR10] = ch_read_data(currentDate,SiteFlag);

% --- define time variables and create a Time_vector using datenum with format
%   of Time_vector = datenum(year, month, day, hour, min, seconds) ---

          hour = floor(data_21x(:,4) / 100);										
       minutes = data_21x(:,4) - hour*100;				
         month = ones(size(data_21x(:,2))); 
   
   Time_vector21x = datenum(data_21x(:,2),...
                         month,...
                         data_21x(:,3),...
                         hour,...
                         minutes,...
                         data_21x(:,5));

          hour = floor(data_CR10(:,3) / 100);										
       minutes = data_CR10(:,3) - hour*100;				
         month = ones(size(data_CR10(:,2)));
       seconds = zeros(size(hour));
% note: here we use 21x Year because cr10 data does not have that field !!??
        Year   = data_21x(1,2)*ones(size(hour));
   
   Time_vectorCR10 = datenum(Year,...
                         month,...
                         data_CR10(:,2),...
                         hour,...
                         minutes,...
                         seconds);

% --- convert Licor data to Engineering units ---

[co2_ppm,h2o_mmol,Temperature,Pressure] = fr_licor_calc(c.chamber.Licor.Num, [], ...
                                          data_21x(:,9), data_21x(:,10), ...
                                          data_21x(:,6),data_21x(:,7),...
                                          c.chamber.Licor.CO2_cal,c.chamber.Licor.H2O_cal);

co2_ppm_short = round(co2_ppm);  % round up the co2 data to save storage space
N_21x = length(co2_ppm_short);
Time_ind = 1:10:N_21x;
if Time_ind(end) ~= N_21x
   Time_ind = [Time_ind N_21x];
end
 
TimeVectorHH_21x = floor(Time_vector21x*48+8/60*48/60/24)/48;
HH_ind_21x=find(diff(TimeVectorHH_21x)>0)+1;
if HH_ind_21x(1)~=1,
   HH_ind_21x = [1 ;HH_ind_21x(:)];
end

TimeVectorHH_21x = TimeVectorHH_21x(HH_ind_21x(2:end));
numOfHHours_21x = length(TimeVectorHH_21x);

CO2 = NaN * ones(numOfHHours_21x,3);
TEMP = CO2;
PRESS = CO2;

% --- calculate half hourly statistics of important 21X measurements ---

for i = 1:numOfHHours_21x;
    ind = HH_ind_21x(i):HH_ind_21x(i+1); 
    if ~isempty(ind) 
        CO2(i,1) = mean(co2_ppm_short(ind));
        CO2(i,2) = max(co2_ppm_short(ind));
        CO2(i,3) = min(co2_ppm_short(ind));
        TEMP(i,1) = mean(Temperature(ind));
        TEMP(i,2) = max(Temperature(ind));
        TEMP(i,3) = min(Temperature(ind));
        PRESS(i,1) = mean(Pressure(ind));
        PRESS(i,2) = max(Pressure(ind));
        PRESS(i,3) = min(Pressure(ind));  
        FLOW(i,1) = mean(data_21x(ind,11));                   
        FLOW(i,2) = max(data_21x(ind,11));                   
        FLOW(i,3) = min(data_21x(ind,11));                   
    end                
end

% --- calculate half hourly statistics of important CR10 measurements
%   (only do it for columns 4 to 31 ---

TimeVectorHH_CR10 = floor(Time_vectorCR10*48+8/60*48/60/24)/48;
HH_ind_CR10=find(diff(TimeVectorHH_CR10)>0)+1;
if HH_ind_CR10(1)~=1,
   HH_ind_CR10 = [1 ;HH_ind_CR10(:)];
end

TimeVectorHH_CR10 = TimeVectorHH_CR10(HH_ind_CR10(2:end));
numOfHHours_CR10 = length(TimeVectorHH_CR10);

data_CR10_TC    = data_CR10(:,6:31);

for i = 1:numOfHHours_CR10;
   for ch = 1:c.chamber.nbr_chambers
      ind = HH_ind_CR10(i):HH_ind_CR10(i+1); 
      if ~isempty(ind) 
         CR10_Stats.Temp_air(i,ch)   = mean(data_CR10_TC(ind,ch+((ch-1)*3)));  
         CR10_Stats.Temp_sur(i,ch)   = mean(data_CR10_TC(ind,(ch+((ch-1)*3))+1));  
         CR10_Stats.Temp_2cm(i,ch)   = mean(data_CR10_TC(ind,(ch+((ch-1)*3))+2));
         CR10_Stats.Temp_blank(i,ch) = mean(data_CR10_TC(ind,(ch+((ch-1)*3))+3));     
         CR10_Stats.BVol_and_PTemp(i,:) = mean(data_CR10(ind,4:5));
      end               
   end
end

% --- calculate half-hourly chamber fluxes and effective_volumes ---

[evOut,fluxOut] = fr_chamber_calc_flux(SiteFlag,...
                                       Stats,...
                                       Time_vector21x,...
                                       TimeVectorHH_21x,...
                                       data_21x(:,11),...
                                       co2_ppm,...
                                       c);

% --- prepare output structure "chOut" and save it into the default 
%   "hhour" folder ---

chOut.Co2_slopes               = co2_ppm;
chOut.Time_vector_slopes       = Time_vector21x;

chOut.Co2_slopes_short         = co2_ppm_short;
Time_vector21x_short           = Time_vector21x(Time_ind);
chOut.Time_vector_slopes_short = Time_vector21x_short;
chOut.Time_ind                 = Time_ind;
chOut.TimeVectorHH_CR10        = TimeVectorHH_CR10;
chOut.TimeVectorHH_21x         = TimeVectorHH_21x;

chOut.Co2_avg                  = CO2;
chOut.Temp_avg                 = TEMP;
chOut.Press_avg                = PRESS;
chOut.Flow_rate_avg            = FLOW;
chOut.CR10_Stats               = CR10_Stats;
chOut.Ev_Stats                 = evOut;
chOut.Dcdt                     = fluxOut.Dcdt;
chOut.Rsquare                  = fluxOut.Rsquare;
chOut.Fluxes                   = fluxOut.Flux;
chOut.Ev                       = fluxOut.Ev;

disp(sprintf('Chamber data processed in %4.2f (s)',toc));    

%FileName_p      = FR_DateToFileName(currentDate);
%FileName        = [pthHH FileName_p(1:6) c.chamber.HH_ext];  % File name for the full set of stats
%save(FileName,'chamber_data');
%disp(sprintf('File %s processed in %4.2f (s)',FileName_p(1:6),toc));    

%-------------------------------------------------------------------------------
%Order of columns in datafile 21x is...
% 1 Out_array_ID
% 2 Year
% 3 DDOY
% 4 HH_min 
% 5 Seconds
% 6 Cell_temp_mv 
% 7 Cell_press_mv 
% 8 CO2_conc 
% 9 CO2_mv 
%10 H20_mv 
%11 MFC_flowrate 
%------------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
%Order of columns in datafile CR10 is...
% 1 Out_array_ID (100)
% 2 DDOY
% 3 HH_MM
% 4 Battery Voltage
% 5 Panel Temperature
% 6 TC1  Chamber1  Temperature PA
% 7 TC2  surface  Temperature PA 
% 8 TC3  Soil_2cm Temperature PA
% 9 TC4	Blank for PA
%10 TC5
%11 TC6
%12 TC7
%13 TC8  Blank for PA
%14 TC9
%15 TC10
%16 TC11
%17 TC12 Blank for PA
%18 TC13	
%19 TC14
%20 TC15
%21 TC16 Blank for PA
%22 TC17
%23 TC18
%24 TC19
%25 TC20 Blank for PA
%26 TC21	
%27 TC22
%28 TC23
%29 TC24 Blank for PA
%30 PAR1	Blank for PA
%31 PAR2	Blank for PA
%------------------------------------------------------------------------------------
