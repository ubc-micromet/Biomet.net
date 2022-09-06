function cr_ch_fluxes_calc(dates)
% cr_ch_fluxes_calc(dates) Calculate fluxes from Paul's chamber
% eg
% cr_ch_fluxes_calc([datenum(2005,5,22):datenum(2005,6,24)]);
% 
% 
% BEWARE of date conventions!
%
% On DOY 268 (Sept 25) the file CH_21X.268 will be renamed CH_21X_268.ch
% It contains the data from noon Sept 25 to noon Sept 26 and will be
% named 030925.hc_ch.mat
%
% cr_ch_fluxes_calc(floor(now)-1);
% will calculates calculate yesterday's data when called at 1PM today 
% (say DOY 269) since it grabs the data for DOY 268, which contains data
% from noon DOY 268 to 269 and the output is named 030925, i.e. yesterday
%
% Comprende? 

% Revisions:
% Nov 20, 2003 kai* & Paul
%   - Changed HF directory names and introduced stdCO2 calculation
% Jan 14, 2004 kai* & Paul
%   - Changed DOY naming for numbers smaller than 100

[pc,loc] = fr_get_pc_name;

if strcmp(upper(loc),'CR SITE')
   diary(['d:\met-data\log\cr_ch_fluxes_calc.log'])
   disp(sprintf('==============  Start ========================================='));
   disp(sprintf('Date: %s',datestr(now)));
end

for d = 1:length(dates)
   tic;
   currentDate = dates(d);
   
   % Read the data from proper location
   yy = datevec(currentDate);
   % doy = num2str(floor(currentDate) - datenum(yy(1),1,0),'%03i');
   doy_new = num2str(floor(currentDate) - datenum(yy(1),1,0),'%03i');
   doy = num2str(floor(currentDate) - datenum(yy(1),1,0));
   if strcmp(upper(loc),'CR SITE')
      pth_ch = 'd:\met-data\csi_net\';
      fileName    = [pth_ch 'CH_21X.' num2str(doy)];
      try 
         read_flag = 0;
         C = dlmread([fileName],','); 
         read_flag = 1;
      catch
         try
            C = dlmread([fileName],','); 
            fileName    = [pth_ch 'CH_21X_' num2str(doy) '.ch'];
            disp(['Successfully read ' fileName]);
         catch
            C = NaN.*ones(14400,12);; 
            disp(['Could not read file for ' datestr(currentDate)]);
         end
      end
   else
      pth_ch = '\\ANNEX001\HFREQ_CR\MET-DATA\Csi_net\';
      fileName    = [pth_ch 'CH_21X_' num2str(doy) '.ch'];
      try 
         C = dlmread([fileName],',');
         disp(['Successfully read ' fileName]);
      catch 
         pth_ch = '\\ANNEX001\HFREQ_CR\MET-DATA\Csi_net\CH_21X_cor\';
         fileName    = [pth_ch 'CH_21X.' num2str(doy)];
         try
            C = dlmread([fileName],','); 
            disp(['Successfully read ' fileName]);
         catch; 
            C = NaN.*ones(14400,12);; 
            disp(['Could not read file for ' datestr(currentDate)]);
         end
      end
   end
   
   
   % C     =  cr_chamber_data(currentDate,yy(1),0,pth_ch);
   
   %defines time vector
   month = ones(size(C(:,2))); 
   hour  = floor(C(:,4) / 100);										
   min   = C(:,4) - hour * 100;				
   sec   = C(:,5); 
   
   TV    = datenum(C(:,2),month,C(:,3),hour,min,sec);
   
   %defines variables
   CO2   = C(:,8);
   Air_T = C(:,9);
   TS2   = C(:,10);
   TS5   = C(:,11);
   TP    = C(:,12);
   
   % calculate fluxes (regression method)
   Vol        = 0.065;          % m3 
   Sur        = 0.2065;         % m2 
   R          = 8.3144;         % J mol-1 K-1
   len_sample = 100;
   
   ind_start = [1; find(diff(TV)>1/96)+1];
   nbr_sample = length(ind_start);
   
   for i        = 1:nbr_sample;
      ind       = [ind_start(i)+100:ind_start(i)+199];
      
      
      CO2_tmp   = CO2(ind);
      Air_T_tmp = Air_T(ind);
      TS2_tmp   = TS2(ind);
      TS5_tmp   = TS5(ind);
      tv_reg    = [0:len_sample-1]';
      tv1       = TV(ind);
      
      a = linregression(tv_reg,CO2_tmp);
      dcdt(i)       = a(1);
      delta_dcdt(i) = a(5);
      R2_CO2(i)     = a(8); 
      stdCO2(i)     = std(detrend(CO2_tmp));
      
      % Averages for the measurement interval
      tt(i)       = mean(tv1);
      Air_Temp(i) = mean(Air_T_tmp);
      if strcmp(upper(loc),'CR SITE')
         Pbar(i) = 98000;         % Pa
      else
        try
         pth_db = biomet_path(yy(1),'cr','climate\fr_clim\');
         tv_db = read_bor(fullfile(pth_db,'fr_clim_105_tv'),8);
         Pbar_db  = read_bor(fullfile(pth_db,'fr_clim_105.53')) .* 1000;
         % Linearly interpolate missing values
         [dtv,ind_tv] = min(abs(tv_db(find(~isnan(Pbar_db)))-tt(i)));
         Pbar(i) = Pbar_db(ind_tv);
        catch
            Pbar = NaN*tv_db;
        end
      end
      
      rho         = Pbar(i) / (R * (mean(Air_T_tmp) + 273.15));
      
      % ground CO2 (over 15 seconds before and after closing of the chamber)
      ind2        = ind_start(i)+45:ind_start(i)+65;
      ind3        = ind_start(i)+65:ind_start(i)+80;
      gr_co2_a    = CO2(ind2);
      gr_co2_b    = CO2(ind3);
      CO2_gr_a(i) = mean(gr_co2_a);
      CO2_gr_b(i) = mean(gr_co2_b);
      
      F(i)        = rho * Vol * dcdt(i)       / Sur;
      delta_F(i)  = rho * Vol * delta_dcdt(i) / Sur;
      ts2(i)      = mean(TS2_tmp);
      ts5(i)      = mean(TS5_tmp);
      
      Chambers.RecalcTimeVector(i,1) = now;
   end
   
   % Create output structure
   Chambers.TimeVector = tt';
   Chambers.DecDOY     = tt'-datenum(yy(1),1,0);
   Chambers.Year       = yy(1) .* ones(length(tt),1);
   Chambers.co2_after  = CO2_gr_b';
   Chambers.co2_before = CO2_gr_a';
   Chambers.r2         = R2_CO2';
   Chambers.dcdt       = dcdt';
   Chambers.delta_dcdt = delta_dcdt';
   Chambers.stdCO2     = stdCO2';
   Chambers.flux       = F';
   Chambers.delta_flux = delta_F';
   Chambers.temp1      = ts2';
   Chambers.temp2      = ts5';
   Chambers.tair       = Air_Temp';
   Chambers.pbar       = Pbar';
   stats.Chambers = Chambers;
   
   if strcmp(upper(loc),'CR SITE')
      [dd,pth_out] = fr_get_local_path;
   else
      pth_out = '\\ANNEX001\HFREQ_CR\MET-DATA\hhour\';
   end
   
   Filename_p = fr_datetofilename(currentDate+1/48);
   Filename_p = fullfile(pth_out,[Filename_p(1:6) 's.hc_ch.mat']);
   save(Filename_p,'stats') ;
   
   
   disp(sprintf('%i chamber fluxes calculated',length(find(~isnan(F)))));
   disp(sprintf('%s,  (%d/%d), time = %4.2f (s)',Filename_p,d,length(dates),toc));    
   
   if strcmp(upper(loc),'CR SITE') & read_flag == 1
      dos(['rename ' pth_ch 'CH_21X.' doy ' CH_21X_' doy_new '.ch']);
   end
   
end

if strcmp(upper(loc),'CR SITE')
   disp(sprintf('==============  End    ========================================='));
   disp(sprintf(''));
end

return
