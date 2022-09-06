function [stats] = ach_calc(SiteFlag,startDate,Stats,c,recalc)
%[stats] = ach_calc(SiteFlag,startDate,Stats,c,recalc)
%
%Function that computes stats for automated respiration chamber systems
%Called within fr_calc_main or ach_recalc - Site independent
%
%Input variables:    SiteFlag
%                    startDate
%                    Stats (from eddy covariance output)
%                    c (initialisation matrix)
%						 recalc
%
%Output variables:   output structure stats that contains all the information about effluxes, effective volumes, 
%							chamber climate and diagnostic variables
%
%(c) dgg                
%Created:  Nov 26, 2003
%Revision: lots
warning off;
tic;

try

   %load and reorder HF and HH data
   [data_HF,data_HH] = ach_find_and_read_data(startDate,SiteFlag,c.chamber.systemType);
   data_HF_reordered = data_HF(:,c.chamber.ChanReorder.data_HF);   
   data_HH_reordered = data_HH(:,c.chamber.ChanReorder.data_HH);

   %create time vector for HF data (5 seconds)
   hour = floor(data_HF_reordered(:,4) / 100);										
   minutes = data_HF_reordered(:,4) - hour*100;				
   month = ones(size(data_HF_reordered(:,2))); 
   
   Time_vector_HF = datenum(data_HF_reordered(:,2),...
                            month,...
                            data_HF_reordered(:,3),...
                            hour,...
                            minutes,...
                            data_HF_reordered(:,5));

   %create time vector for HH data (30 minutes)   
   if c.chamber.systemType == 1 %year is not available on CR10
      year = data_HF_reordered(1,2)*ones(size(data_HH_reordered(:,1)));
      doy = data_HH_reordered(:,2);
      hour = floor(data_HH_reordered(:,3) / 100);										           
      minutes = data_HH_reordered(:,3) - hour * 100;				
   elseif c.chamber.systemType == 2
      year = data_HH_reordered(:,2);
      doy = data_HH_reordered(:,3); 
      hour = floor(data_HH_reordered(:,4) / 100);										           
      minutes = data_HH_reordered(:,4) - hour * 100;				
   end
   month = ones(size(year));
   seconds = zeros(size(hour));
   
   Time_vector_HH = datenum(year,...
                            month,...
                            doy,...
                            hour,...
                            minutes,...
                            seconds);

   %convert licor data to engineering units - convert CO2 from mole fraction (wet) to mixing ratio (dry)
   [co2_ppm,h2o_mmol,temperature,pressure] = fr_licor_calc(c.chamber.Licor.Num, [], ...
                                             data_HF_reordered(:,6),data_HF_reordered(:,7), ...
                                             data_HF_reordered(:,8),data_HF_reordered(:,9),...
                                             c.chamber.Licor.CO2_cal,c.chamber.Licor.H2O_cal);
  
   %round co2_ppm for storage space
   co2_ppm_short = round(co2_ppm);
   N = length(co2_ppm_short);
   Time_ind = 1:10:N;
   if Time_ind(end) ~= N
      Time_ind = [Time_ind N];
   end

   %calculate HH chamber climate and diagnostic stats - Site dependent
   [HH_climate_stats,HH_diag_stats,Time_vector_HH_HH,bVol,cTCHTemp,pTCHTemp] = ach_HH_climate_stats...
                                                (SiteFlag,data_HH_reordered,data_HF_reordered,...
                                                Time_vector_HH,Time_vector_HF,co2_ppm_short,...
                                                temperature,pressure,c);
   
   %calculate daily effective volumes and HH chamber flux stats - Site independent
   [HH_flux_stats] = ach_HH_flux_stats(SiteFlag,startDate,Time_vector_HF,Time_vector_HH_HH,...
                                       HH_climate_stats,data_HF_reordered,co2_ppm,h2o_mmol,...
                                       c,Stats,recalc);

   %prepare output structure chOut
   stats.CO2_HF               = co2_ppm;
   stats.H2O_HF               = h2o_mmol;
   stats.Time_vector_HF       = Time_vector_HF;

   stats.CO2_HF_short         = co2_ppm_short;
   Time_vector_HF_short       = Time_vector_HF(Time_ind);
   stats.Time_vector_HF_short = Time_vector_HF_short;
   stats.Time_ind             = Time_ind;

   stats.Time_vector_HH       = Time_vector_HH_HH;

   stats.Diagnostic_Stats.co2_avg      = HH_diag_stats.co2;
   stats.Diagnostic_Stats.temp_avg     = HH_diag_stats.temp;
   stats.Diagnostic_Stats.press_avg    = HH_diag_stats.press;
   stats.Diagnostic_Stats.mfc_avg      = HH_diag_stats.flow;
   stats.Diagnostic_Stats.batt_vol     = bVol;
   stats.Diagnostic_Stats.ctrbox_temp  = cTCHTemp;
   stats.Diagnostic_Stats.pumpbox_temp = pTCHTemp;

   stats.Climate_Stats                 = HH_climate_stats;
   stats.Fluxes_Stats                  = HH_flux_stats;

   disp(sprintf('Chamber data processed in %4.2f (s)',toc));    

catch

   disp('Chamber data processing failed');
    
end
