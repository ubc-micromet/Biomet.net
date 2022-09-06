function [chamber_data] = ch_read_and_save(currentDate,SiteID)
% [chamber_data] = ch_read_and_save(currentDate,SiteID)
%
% This function loads the comma-delimited files with chamber data,
% converts and saves them into matlab data format and calculates
% and saves a halfhour stats and a sample of high frequency data (time +CO2 trace)
%
% (c) Gord Drewitt & Zoran Nesic        File created:       Aug  3, 2000 (based on Gord's view_data.m)
%                                       Last modification:  Aug 12, 2000

% Revisions:


% If input parameters are not given use the defaults
if exist('SiteID')~= 1 | isempty(SiteID)
    SiteID = fr_current_siteID;
end
if exist('currentDate')~= 1 | isempty(currentDate)
    currentDate = now;
end
 
 
[data_21x,data_CR10] = ch_read_data(currentDate,SiteID);

[pthHF, pthHH] = fr_get_local_path;

c = fr_get_init(SiteID,currentDate);                        % get the init data

%------------------------------------------------------------------------------------
%define time variables and create a Time_vector using datenum with format
%of Time_vector = datenum(year, month, day, hour, min, seconds)
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
% Note: here we use 21x Year because cr10 data does not have that field !!??
        Year   = data_21x(1,2)*ones(size(hour));
   
   Time_vectorCR10 = datenum(Year,...
                         month,...
                         data_CR10(:,2),...
                         hour,...
                         minutes,...
                         seconds);


%convert Licor data to Engineering units
[co2_ppm,h2o_mmol,Temperature,Pressure] = fr_licor_calc(c.chamber.Licor, [], ...
                                           data_21x(:,9), data_21x(:,10), ...
                                           data_21x(:,6),data_21x(:,7),...
                                            c.chamber.CO2_Cal,c.chamber.H2O_Cal);

co2_ppm = round(co2_ppm);                       % round up the data to save storage space
N_21x = length(co2_ppm);
Time_ind = 1:10:N_21x;
if Time_ind(end) ~= N_21x
    Time_ind = [Time_ind N_21x];
end
 
% x=zeros(1,1440);for i=1:1440;x(i)=datenum(2000,7,1,0,i+5,randn(1,1)*5);end
% y=floor(x*48+8/60/60/24*48)/48;
% i=find(diff(y)>0)+1;if i(1)~=1, i = [1 ;i(:)];end
% [datestr([y(i)']),datestr( x(i)')]

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

%calculate half hourly statistics of important 21X measurements
for i = 1:numOfHHours_21x;
    ind = HH_ind_21x(i):HH_ind_21x(i+1); 
    if ~isempty(ind) 
        CO2(i,1) = mean(co2_ppm(ind));
        CO2(i,2) = max(co2_ppm(ind));
        CO2(i,3) = min(co2_ppm(ind));
        TEMP(i,1) = mean(Temperature(ind));
        TEMP(i,2) = max(Temperature(ind));
        TEMP(i,3) = min(Temperature(ind));
        PRESS(i,1) = mean(Pressure(ind));
        PRESS(i,2) = max(Pressure(ind));
        PRESS(i,3) = min(Pressure(ind));                   
    end
                
end

%calculate half hourly statistics of important CR10 measurements
%only do it for columns 4 to 31
TimeVectorHH_CR10 = floor(Time_vectorCR10*48+8/60*48/60/24)/48;
HH_ind_CR10=find(diff(TimeVectorHH_CR10)>0)+1;
if HH_ind_CR10(1)~=1,
   HH_ind_CR10 = [1 ;HH_ind_CR10(:)];
end
TimeVectorHH_CR10 = TimeVectorHH_CR10(HH_ind_CR10(2:end));
numOfHHours_CR10 = length(TimeVectorHH_CR10);

out_all.mean = NaN * ones(numOfHHours_CR10,(31-4+1));            
for i = 1:numOfHHours_CR10;
    ind = HH_ind_CR10(i):HH_ind_CR10(i+1); 
    if ~isempty(ind) 
        out_all.mean(i,:) = mean(data_CR10(ind,4:31));
    end               
end

%out_all.mean = round(out_all.mean * 100) / 100;


%===============================================
% Prepare output structure "chamber_data"
% and save it into the default "HHOUR" folder
%===============================================
chamber_data.co2_conc       = co2_ppm;
chamber_data.CO2            = CO2;
chamber_data.Temp           = TEMP;
chamber_data.Press          = PRESS;
chamber_data.stats          = out_all.mean;

Time_vector21x = Time_vector21x(Time_ind);
chamber_data.Time_vector    = Time_vector21x;

chamber_data.Time_ind       = Time_ind;
chamber_data.TimeVectorHH_CR10 = TimeVectorHH_CR10;
chamber_data.TimeVectorHH_21x  = TimeVectorHH_21x;

FileName_p      = FR_DateToFileName(currentDate);
FileName        = [pthHH FileName_p(1:6) c.chamber.HH_ext];    % File name for the full set of stats
save(FileName,'chamber_data');


%-------------------------------------------------------------------------------
% Local functions
%-------------------------------------------------------------------------------






%-------------------------------------------------------------------------------
%Order of columns in datafile is...
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
%Order of columns in datafile is...
% 1 Out_array_ID (100)
% 2 DDOY
% 3 HH_MM
% 4 Battery Voltage
% 5 Panel Temperature
% 6 TC1 					Chamber1  Temperature PA
% 7 TC2						surface  Temperature PA 
% 8 TC3						Soil_2cm Temperature PA
% 9 TC4			Blank for PA
%10 TC5
%11 TC6
%12 TC7
%13 TC8
%14 TC9			Blank for PA
%15 TC10
%16 TC11
%17 TC12
%18 TC13		Blank for PA
%19 TC14
%20 TC15
%21 TC16
%22 TC17		Blank for PA
%23 TC18
%24 TC19
%25 TC20
%26 TC21		Blank for PA
%27 TC22
%28 TC23
%29 TC24
%30 PAR1		Blank for PA
%31 PAR2		Blank for PA
%------------------------------------------------------------------------------------
