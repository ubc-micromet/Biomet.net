function ach_get_licor_cal(currentDate_vec,SiteFlag)
%ach_get_licor_cal(SiteFlag,currentDate) 
%
%Inputs variables:   SiteFlag
%                    currentDate
%
%Ouputs variables:   calibration date
%                    licor co2 offset and gain (mV)
%                    licor h2o offset and gain (mV)
%                    optical bench temperature (mV)
%                    licor pressure (mV)
%                    licor number
%                    span gas concentration
%
%Function that extracts licor calibrations from high frequency chamber data
%
%(c) dgg
%Created:     Nov 26, 2003
%Revisions:   Sep 02, 2005
%   Sep 02, 2005
%      - removed bug that caused program to write NaNs into calibration file when 
%        data file is not found. (Zoran) 
% - Dec 05, 2003:
%     - Daily licor calibrations are now extracted independently from the fr_calc_main program. 

if ~exist('SiteId') | isempty(SiteFlag)
   SiteFlag = fr_current_siteid;
end

for i = 1:length(currentDate_vec)
   currentDate = currentDate_vec(i);
   c = fr_get_init(SiteFlag,currentDate);
   
   k = 0;
   warning off;
   cal_values = zeros(30,366);
   VB2MatlabDateOffset = 693960;
   
   %load and reorder HF and HH data
   try
      [data_HF,data_HH] = ach_read_data(currentDate,SiteFlag,c.chamber.systemType,0);
      
      data_HF_reordered = data_HF(:,c.chamber.ChanReorder.data_HF);   
      
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
      
      % calDay = floor(Time_vector_HF(end));            Commented out.  Z. Mar 30, 2005
      calDay = floor(currentDate);                      % fixed by Z. Mar 30, 2005
      calOffset = datenum(0,0,calDay,c.chamber.calHour,c.chamber.calMinute,0);
      
      %extract licor calibration data
      co2_mv = data_HF_reordered(:,6);
      h2o_mv = data_HF_reordered(:,7);
      TBench = data_HF_reordered(:,8);
      PBench = data_HF_reordered(:,9);
      
      VB_date = calOffset - VB2MatlabDateOffset;
      k = k+1;
      cal_values(1,k) = fix(VB_date);
      cal_values(2,k) = rem(VB_date,1);
      
      for calStage = 0:2
         if c.chamber.calPeriodSec == 45            
            indCal = find(Time_vector_HF >= datenum(0,0,0,0,0,calStage*c.chamber.calPeriodSec+c.chamber.calSkipSec)+calOffset ...
               & Time_vector_HF <= datenum(0,0,0,0,0,(calStage+1)*c.chamber.calPeriodSec-c.chamber.calSkipSec)+calOffset);
         elseif c.chamber.calPeriodSec == 300 
            indCal = find(Time_vector_HF >= datenum(0,0,0,0,0,calStage*c.chamber.calPeriodSec+(2*c.chamber.calSkipSec))+calOffset ...
               & Time_vector_HF <= datenum(0,0,0,0,0,(calStage+1)*c.chamber.calPeriodSec-(5*c.chamber.calSkipSec))+calOffset);
         end 
         if isempty(indCal)
            disp('Calibration time index not found');
            error 'Time index not found'
         end
         cal_values([10+calStage*2 19+calStage*4],k) = mean(co2_mv(indCal));
         cal_values([11+calStage*2 20+calStage*4],k) = mean(h2o_mv(indCal));
         cal_values([21+calStage*4],k) = mean(TBench(indCal));
         cal_values([22+calStage*4],k) = mean(PBench(indCal));
      end
      
      cal_values(3,k) = c.chamber.Licor.Num;
      cal_values(4,k) = c.chamber.span_conc;
      cal_values(5,k) = 0;
      
      cal_values = cal_values(:,1:k);
      fileName = fullfile(c.hhour_path,['calibrations' c.chamber.cal_ext '_ch']);
      
      % Save licor calibration data
      % First check if there is already an existing calibration file
      fid = fopen(fileName,'r');
      if fid < 3
         disp(['Creating new calibration file: ' fileName])
         cal_values_new = cal_values;
      else
        cal_values_old = fread(fid,[30 inf],'float32');
        fclose(fid);         
        calTime_old = cal_values_old(1,:)+cal_values_old(2,:)+VB2MatlabDateOffset;
        ind_cal = find(round(calTime_old.*1e5) == round(calOffset.*1e5));
        if isempty(ind_cal)
            [tv_dum,ind_sort] = sort([calTime_old calOffset]);
            cal_values_new = [cal_values_old cal_values];
            cal_values_new = cal_values_new(:,ind_sort);
        else
            cal_values_new = cal_values_old;
            cal_values_new(:,ind_cal) = cal_values;
            disp('Overwritting existing values...')
        end
      end
      
      
      fid = fopen(fileName,'w');
      if fid < 3
         error(['Cannot open file: ' fileName])
      end
      fwrite(fid,cal_values_new(:,:),'float32');
      fclose(fid);
      disp(['Extracted calibration at ' SiteFlag ' ' datestr(calOffset) ]);
      
   catch
      disp(['Error extracting calibration at ' SiteFlag ' ' datestr(currentDate) ]);
   end
end


%calRecord key table:
%
%1. Date serial number (in VB format)
%2. Time serial number (in VB format)
%3. Licor serial number
%4. CO2 calibration concentration (CAL_1)
%5. CO2 calibration concentration (CAL_2)
%6.
%7.
%8.
%9.
%10. CO2_mV     (N2)     Corrected
%11. H2O_mV     (N2)     Corrected
%12. CO2_mV     (CAL_1)  Corrected
%13. H2O_mV     (CAL_1)  Corrected
%14. CO2_mV     (CAL_2)  Corrected
%15. H2O_mV     (CAL_2)  Corrected
%16. Pgauge     (N2)
%17. Pgauge     (CAL_1)
%18. Pgauge     (CAL_2)
%19. CO2_mV     (N2)
%20. H2O_mV     (N2)
%21. Tbench_mV  (N2)
%22. Plicor_mV  (N2)
%23. CO2_mV     (CAL_1)
%24. H2O_mV     (CAL_1)
%25. Tbench_mV  (CAL_1)
%26. Plicor_mV  (CAL_1)
%27. CO2_mV     (CAL_2)
%28. H2O_mV     (CAL_2)
%29. Tbench_mV  (CAL_2)
%30. Plicor_mV  (CAL_2)




