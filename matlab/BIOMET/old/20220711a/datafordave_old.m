function [] = datafordave(years,startDate,stopDate,datatype, eh_pth, plot_flag);
% datafordave(2004,datenum(2004,datenum(2004,2,29),datenum(2004,?,?),'interception','c:\temp\');
% 
% Data export for Dave Spittlehouse
%
% Explanation by Elyn:
%
% Normally, Dave wants us to send him his datalogger data along with some of our met data.  
% I use the program,
%
% datafordave(years,startDate,stopDate,datatype, eh_pth, plot_flag)
%
% Where years refers to our database years, and startDate and stopDate in datenum refer 
% to the dates he requests.  Datatype is 'interception' for his datalogger data and 
% 'model' for more met variables on daily time steps.  He hasn't asked for the latter 
% in awhile.  Sorry the program is so pedestrian ... I did write it in 1998 :-)
%
% For interception data, this file generates a number of ascii files which I then zip 
% together along with the readme file interception_data_readme.txt, which sits in the same
% directory as this program.  
% The 24h data also have a readme file 'model_data_readme.txt' in the same directory.
% 
% plot_flag == 1 (the default) will produce plots to check the data

%E.Humphreys    Dec 15, 1998
% Revisions June 17, 1999 - dave wants more data!
%           Apr  14, 2004 - floor startdate in list of dates
%           Mar  03, 2005 - made data plotting optional for automatic export & added year 
%                           to all output names

format short g

if ~exist('eh_pth') | isempty(eh_pth);
    eh_pth = 'd:\elyn_data\data_out\dave\';
end

if ~exist('datatype') | isempty(datatype);
    datatype = 'interception';
end

arg_default('plot_flag',1);

%years = [2000]
pth    = biomet_path('yyyy','cr','clean\secondstage');
pth_cl = biomet_path('yyyy','cr','cl');
pth_b   = biomet_path('yyyy','cr','cl');
if years < 1999;
   switch years
   case 1997
      pth_cl  = '\\ANNEX001\DATABASE\1997\CR\climate\';
      pth  = '\\ANNEX001\DATABASE\1997\CR\clean\secondstage\';
      
      
   case 1998
      pth_cl  = '\\ANNEX001\DATABASE\1998\CR\climate\';  
      pth  = '\\ANNEX001\DATABASE\1998\CR\clean\secondstage\';
      
   end
end


%select shift = 8/24 when processing daily data
GMT_shift = 8/24;       %shift grenich mean time to 24hr day
tv = read_bor([ pth_cl 'clean\clean_tv'],8,[],years)- GMT_shift;

%Nov 23, 2000
%startDate  = datenum(years,doy,1);
%stopDate   = datenum(now);
dbaseStart = datenum(years(1),1,1);

indOut = find(tv >= startDate & tv < stopDate);
tv = tv(indOut);
t  = tv-dbaseStart+1; 

P_tot    = read_bor([pth_cl 'clean\precipitation_1'],[],[],years,indOut);
%P_tot    = read_bor([pth_cl 'fr_clim\fr_clim_105.45'],[],[],years,indOut);

   
   switch datatype
   case 'model'
      u        = read_bor([pth_cl 'clean\wind_speed_40m'],[],[],years,indOut);
      u        = ta_interp_points(u,48);
      Solar    = read_bor([pth 'global_radiation_main'],[],[],years,indOut);
      Solar    = ta_interp_points(Solar,48);
      Rn       = read_bor([pth 'radiation_net_main'],[],[],years,indOut);   
      Rn       = ta_interp_points(Rn,48);
      Tair     = read_bor([pth 'air_temperature_main'],[],[],years,indOut);
      Tair     = ta_interp_points(Tair,48);
      RH       = read_bor([pth 'relative_humidity_main'],[],[],years,indOut);
      RH       = ta_interp_points(RH ,48);
      SHF      = read_bor([pth 'soil_heat_flux_main'],[],[],years,indOut);
      SHF      = ta_interp_points(SHF,48);
   end    

year     = read_bor([pth_b 'fr_b\fr_b.2'],[],[],years,indOut);
day      = read_bor([pth_b 'fr_b\fr_b.3'],[],[],years,indOut);
hrmin    = read_bor([pth_b 'fr_b\fr_b.4'],[],[],years,indOut);

alldave1 = read_dave1(pth_b,years,indOut);
alldave2 = read_dave2(pth_b,years,indOut);
cut      = find(alldave2(:,1) ~= 0);
alldave2 = alldave2(cut,:);

if plot_flag
   fig = 0;
   fig = fig+1;figure(fig);clf;
   plot(tv,P_tot);
   ylabel('precip (mm)');
   zoom on;
   
   fig = fig+1;figure(fig);clf;
   plot(t,hrmin);
   zoom on;
   
   fig = fig+1;figure(fig);clf;
   plot(t,day);
   zoom on;
   
   fig = fig+1;figure(fig);clf;
   plot(t,year,'.-');
   zoom on;
end

switch datatype
case 'model'
    %----------------
    %do a temporary patch clean on SHF
    if years == 2001;
        ind = find(t > 192.8 & t < 194.7);
        SHF(ind) = NaN;
    end
    
    if plot_flag
       fig = fig+1;figure(fig);clf;
       plot(t,Rn,t,Solar);
       a = legend('Rn','Solar');
       set(a,'Visible','off');
       zoom on;
       
       fig = fig+1;figure(fig);clf;
       plot(t,Tair);
       zoom on;
       
       fig = fig+1;figure(fig);clf;
       plot(t,RH);
       zoom on;
       
       fig = fig+1;figure(fig);clf;
       plot(t,SHF);
       zoom on;
    end    
    convert_2_MJ = 30.*60./1e6;

variables.Solar = Solar;
variables.Rn    = Rn;
variables.Tair  = Tair;
variables.RH    = RH;
variables.SHF   = SHF;
variables.P_tot = P_tot;

if plot_flag
   pause;
   close all;
end

m          = 6;
dates_list = [floor(startDate):1:datenum(years+1,1,1)-1];

data_24h_totals     = NaN.*ones(length(dates_list),m+2);
data_24h_means      = NaN.*ones(length(dates_list),m+2);
data_daytime_totals = NaN.*ones(length(dates_list),m+2);
data_daytime_means  = NaN.*ones(length(dates_list),m+2);

[DOY,Y,D,hhmm] = convert_tv(dates_list,'doy');
DOY = DOY';
Y   = Y';

data_24h_totals(:,1:2)    = [Y DOY];
data_24h_means(:,1:2)     = [Y DOY];
data_24h_max(:,1:2)     = [Y DOY];
data_24h_min(:,1:2)     = [Y DOY];
data_daytime_totals(:,1:2)= [Y DOY];
data_daytime_means(:,1:2) = [Y DOY];

day   = find(Solar > 0);
names = fieldnames(variables);

for i = 1:m;
    eval(['tmp = variables.' char(names(i)) ';']);
             
    [x_time x_avg x_sum x_max x_min] = dailystats_number(tv, tmp, 2000, -2000, 1);
    stats = [x_time x_avg x_sum x_max x_min];    
    [C,IA,IB]  = intersect(dates_list,stats(:,1));
    if strcmp(upper(char(names(i))),'SOLAR') | strcmp(upper(char(names(i))),'RN')| strcmp(upper(char(names(i))),'SHF');
        data_24h_totals(IA,i+2)    = [stats(IB,3)].*convert_2_MJ;
    else
        data_24h_totals(IA,i+2)    = [stats(IB,3)];
    end
    data_24h_means(IA,i+2)     = [stats(IB,2)];
    if strcmp(upper(char(names(i))),'TAIR')
       data_24h_max(IA,3)     = [stats(IB,4)];
       data_24h_min(IA,3)     = [stats(IB,5)];
    end

    clear stats;
    
    [x_time, x_avg, x_sum, x_max, x_min] = dailystats_number(tv(day), tmp(day), 2000, -2000, 1);
    stats = [x_time x_avg x_sum x_max x_min];
    [C,IA,IB]  = intersect(dates_list,stats(:,1));
    if strcmp(upper(char(names(i))),'SOLAR') | strcmp(upper(char(names(i))),'RN')| strcmp(upper(char(names(i))),'SHF');          
        data_daytime_totals(IA,i+2)    = [stats(IB,3)].*convert_2_MJ;
    else
        data_daytime_totals(IA,i+2)    = [stats(IB,3)];
    end
    data_daytime_means(IA,i+2)     = [stats(IB,2)];
    
end


%for i = 1:size(data_daytime_totals,2);
if plot_flag
   for i = 1:m;
      
      fig = fig+1;figure(fig);clf;
      plot(data_daytime_totals(:,2),data_daytime_totals(:,2+i),...
         data_24h_totals(:,2),data_24h_totals(:,2+i));
      ylabel(char(names(i)));
      a = legend('daytotal','24total');
      set(a,'Visible','off');
      zoom on;
      
      if i == 3;     %only for Tair  
         fig = fig+1;figure(fig);clf;
         plot(data_daytime_means(:,2),data_daytime_means(:,2+i),...
            data_24h_means(:,2),data_24h_means(:,2+i),...
            data_24h_means(:,2),data_24h_max(:,3),...
            data_24h_means(:,2),data_24h_min(:,3));
         ylabel(char(names(i)));
         a = legend('daymean','24mean','24max','24min');
         set(a,'Visible','off');
         zoom on;
      else
         fig = fig+1;figure(fig);clf;
         plot(data_daytime_means(:,2),data_daytime_means(:,2+i),...
            data_24h_means(:,2),data_24h_means(:,2+i));
         ylabel(char(names(i)));
         a = legend('daymean','24mean');
         set(a,'Visible','off');
         zoom on;
      end
   end
   childn = get(0,'children');
   childn = sort(childn);
   N = length(childn);
   for i=childn(:)';
      if i < 200 
         figure(i);
         if i ~= childn(N-1)
            pause;
         end
      end
   end
end
eval(['save ' eh_pth num2str(years) '_24h_means' ' data_24h_means' ' -ascii;']);
eval(['save ' eh_pth num2str(years) '_24h_max' ' data_24h_max' ' -ascii;']);
eval(['save ' eh_pth num2str(years) '_24h_min' ' data_24h_min' ' -ascii;']);

eval(['save ' eh_pth num2str(years) '_24h_totals' ' data_24h_totals' ' -ascii;']);
eval(['save ' eh_pth num2str(years) '_daytime_means' ' data_daytime_means' ' -ascii;']);
eval(['save ' eh_pth num2str(years) '_daytime_totals' ' data_daytime_totals' ' -ascii;']);

case 'interception'
   if plot_flag
      pause; close all;
   end
   
    eval(['save ' eh_pth  num2str(years) '_alldave_table1' ' alldave1' ' -ascii;']);
    eval(['save ' eh_pth  num2str(years) '_alldave_table2' ' alldave2' ' -ascii;']);
    eval(['save ' eh_pth  num2str(years) '_Precip' ' P_tot' ' -ascii;']);
    eval(['save ' eh_pth  num2str(years) '_hrmin' ' hrmin' ' -ascii;']);
    eval(['save ' eh_pth  num2str(years) '_day' ' day' ' -ascii;']);
    eval(['save ' eh_pth  num2str(years) '_year' ' year' ' -ascii;']); 
    
end



