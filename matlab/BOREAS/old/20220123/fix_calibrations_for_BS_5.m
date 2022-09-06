% Fix for bad calibrations in Apr and May 2005. These calibrations were missed
% due to a (possible) problem with the TCH power supply or TCH microcontroller
%
% Last revision May 10, 2005



%------------------------------------------------------
% Fix eddy calibrations
%------------------------------------------------------

%
% Load the original file
%
VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

fileName = '\\paoa001\sites\paob\hhour\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix calibrations ---------------------------
% find all points for Apr/May 2005 and Pgauge > 400 mV
ind = find((decDOY >= datenum(2005,4,1) & decDOY <= datenum(2005,5,31) ) & cal_voltage(16,:)>400 );
% fix CAL_1 corrected value
cal_voltage(6,ind)= 1;
% Find one bad H2O calibration and replace with the next day's values
ind = find((decDOY >= datenum(2005,1,104) & decDOY <= datenum(2005,1,105) ) );
cal_voltage(11,ind) = cal_voltage(11,ind-1);
cal_voltage(13,ind) = cal_voltage(13,ind-1);

% ----------- end of fix -------------------------------

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);


% 1. Date serial number (in VB format)
% 2. Time serial number (in VB format)
% 3. Licor serial number
% 4. CO2 calibration concentration (CAL_1)
% 5. CO2 calibration concentration (CAL_2)
% 6. Flag 'Ignore calibration' (cal not used if ==1)
% 7.
% 8.
% 9. Pbar       manually inserted when LI6252 is used
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