function fr_chamber_get_licor_cal(SiteFlag,currentDate,c)
% Extract the calibration data from all of the high frequency chamber data
%
% Syntax: - dateIn "datenum(year,month,day):datenum(year,month,day)"
% 
% ex.: chamber_extract_cal(datenum(2001,01,01):datenum(2001,01,10),'PA');
%
% Created by David Gaumont-Guay March 12, 2002 (from Tim Griffis's work)
% Revisions: none

k = 0;
warning off;
cal_values = zeros(30,366);
VB2MatlabDateOffset = 693960;

[data_21x,data_CR10] = ch_read_data(currentDate,SiteFlag);

% --- define time variables and create a Time_vector using datenum with format
%   of Time_vector = datenum(year, month, day, hour, min, seconds) ---

          hour = floor(data_21x(:,4) / 100);										
       minutes = data_21x(:,4) - hour*100;				
         month = ones(size(data_21x(:,2))); 
   
            tv = datenum(data_21x(:,2),...
                         month,...
                         data_21x(:,3),...
                         hour,...
                         minutes,...
                         data_21x(:,5));

calDay = floor(tv(end));            
calOffset = datenum(0,0,calDay,c.chamber.calHour,c.chamber.calMinute,0);

% --- get calibration data ---

co2_mv = data_21x(:,9);
h2o_mv = data_21x(:,10);
TBench = data_21x(:,6);
PBench = data_21x(:,7);

VB_date = calOffset - VB2MatlabDateOffset;
k = k+1;
cal_values(1,k) = fix(VB_date);
cal_values(2,k) = rem(VB_date,1);

         for calStage = 0:2
            if c.chamber.calPeriodSec == 45            
               indCal = find(tv >= datenum(0,0,0,0,0,calStage*c.chamber.calPeriodSec+c.chamber.calSkipSec)+calOffset ...
                           & tv <= datenum(0,0,0,0,0,(calStage+1)*c.chamber.calPeriodSec-c.chamber.calSkipSec)+calOffset);
            elseif c.chamber.calPeriodSec == 300 
               indCal = find(tv >= datenum(0,0,0,0,0,calStage*c.chamber.calPeriodSec+(2*c.chamber.calSkipSec))+calOffset ...
                           & tv <= datenum(0,0,0,0,0,(calStage+1)*c.chamber.calPeriodSec-(5*c.chamber.calSkipSec))+calOffset);
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

% --- save calibration data ---

fid = fopen(fileName,'a');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_values(:,:),'float32');
fclose(fid);

% calRecord key table:
%
%  1. Date serial number (in VB format)
%  2. Time serial number (in VB format)
%  3. Licor serial number
%  4. CO2 calibration concentration (CAL_1)
%  5. CO2 calibration concentration (CAL_2)
%  6.
%  7.
%  8.
%  9.
% 10. CO2_mV     (N2)     Corrected
% 11. H2O_mV     (N2)     Corrected
% 12. CO2_mV     (CAL_1)  Corrected
% 13. H2O_mV     (CAL_1)  Corrected
% 14. CO2_mV     (CAL_2)  Corrected
% 15. H2O_mV     (CAL_2)  Corrected
% 16. Pgauge     (N2)
% 17. Pgauge     (CAL_1)
% 18. Pgauge     (CAL_2)
% 19. CO2_mV     (N2)
% 20. H2O_mV     (N2)
% 21. Tbench_mV  (N2)
% 22. Plicor_mV  (N2)
% 23. CO2_mV     (CAL_1)
% 24. H2O_mV     (CAL_1)
% 25. Tbench_mV  (CAL_1)
% 26. Plicor_mV  (CAL_1)
% 27. CO2_mV     (CAL_2)
% 28. H2O_mV     (CAL_2)
% 29. Tbench_mV  (CAL_2)
% 30. Plicor_mV  (CAL_2)




