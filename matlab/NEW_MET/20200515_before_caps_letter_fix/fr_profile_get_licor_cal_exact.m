function extract_flag = fr_profile_get_licor_cal_exact(SiteFlag,currentDate,c)
% Program used to extract the calibration values and create
% profile Licor 6262,6252 and 800 calibration files that haven't been
% created automatically by UBC_DAQbook.exe
%
% Extract the exact seconds given by the currentDate which is 
% assumed to have been extracted from a cal file
%
% (c) dgg                  File created: Dec 5, 2003
%                          Revisions: 
%
%  Revisions:

VB2MatlabDateOffset = 693960;

fileNameCal = fullfile(c.hhour_path,['calibrations' c.Profile.cal_ext '_pr']);

%check if calibration file exists
if exist(fileNameCal) == 2
   fid = fopen(fileNameCal,'r');
   if fid < 3
      error(['Cannot open file: ' fileNameCal])
   end
   cal_voltages = fread(fid,[30 inf],'float32');
   fclose(fid);
   
   calTimes = (cal_voltages(1,:) + cal_voltages(2,:))' + VB2MatlabDateOffset; 

   %check if calibration data exists
   indCalTime = find(currentDate == calTimes);
else
   %if the file does not exist then it will be created shortly...
   indCalTime = 666; 
end

k = 0;
warning off;
cal_values = zeros(30,366);
N_hhour_per_day = 48;

k = k+1;

%create file name for given calibration hhour (site specific)
dateCal = datevec(currentDate);
FileName_p = FR_DateToFileName(fr_round_hhour(currentDate,2));        
if exist(fullfile(c.path,FileName_p(1:6))) == 7
   pth1 = fullfile(c.path,FileName_p(1:6));
else
   pth1 = c.path;
end
FileName2  = fullfile(pth1,[FileName_p c.ext '2']);

% Extract directory in for HF data file
dirInf = dir(FileName2);
if isempty(dirInf)
   extract_flag = 0;
   return
end
dateClose = datenum(dirInf.date);
closeDiff = round((dateClose - fr_round_hhour(dateClose))*86400);
% Number of sec that the end of cal is before closing of file
%start_cal = round((closeDate-currentDate)*86400);
start_cal = round((fr_round_hhour(currentDate,2)-currentDate)*86400)+closeDiff;

%read data      
[RawData,TotalSamples,SamplesRead] = FR_read_raw_data(FileName2,c.DAQchNum,1e10);

%reorder the channels (see SiteID_init_all)
if ~isempty(RawData)
   RawData = RawData(c.ChanReorder,:)';        
else
   extract_flag = -1;
   return
end
            
voltages = (RawData(:,fr_reorder_chans(c.Profile.DAQ_chans,c)) - mean(RawData(:,5)))*5000/2^15;

%Calibration stages (end of each run).
%Start time and end time in seconds of the voltages that need to be averaged (checked visually and 
%everything is OK for the different sites (David)).
if upper(SiteFlag) == 'CR'
   Cal_stages = [...
                 3*c.Profile.cal_length-.5    3*c.Profile.cal_length+1;...
                 4*c.Profile.cal_length-0.5   4*c.Profile.cal_length+1;...
                 2*c.Profile.cal_length-0.5   2*c.Profile.cal_length+1];
    Cal_stages = Cal_stages - 3.*c.Profile.cal_length+4;
else
   Cal_stages = [...
                 2*c.Profile.cal_length-.5    2*c.Profile.cal_length+1;...
                 3*c.Profile.cal_length-0.5   3*c.Profile.cal_length+1;...
                 c.Profile.cal_length-0.5     c.Profile.cal_length+1];
    Cal_stages = Cal_stages - 3.*c.Profile.cal_length-4;
end

% The calibration time is the time when the calibration is finished
% c.Profile.calHour & calMin give the end of the hhour when the calibration happens,
% to get the actual time of calibration end 30min have to be subtracted.
VB_date = currentDate - VB2MatlabDateOffset;
cal_values(1,k) = fix(VB_date);
cal_values(2,k) = rem(VB_date,1);


ind_cal_end = round(length(voltages) - start_cal * c.Profile.Ts_DAQ);
%loop through calibration stages (zero, cal1, cal2) to find the corresponding milivolts
%figure
%plot(1:length(voltages),voltages(:,1:2));
%hold on
%plot(ind_cal_end,voltages(ind_cal_end,1:2),'r+')
for calStage = 0:2
   ind_cal = floor(Cal_stages(calStage+1,1)*c.Profile.Ts_DAQ :Cal_stages(calStage+1,2)*c.Profile.Ts_DAQ);
   ind = ind_cal_end + ind_cal ;
   if ~isempty(find(ind<0))
      extract_flag = -2;
   	return
   end
 %  plot(ind,voltages(ind,1:2),'r');
   cal_values([10+calStage*2 19+calStage*4],k) = mean(voltages(ind,1));     %co2
   if strcmp(c.Profile.Licor.Type,'800')
      cal_values([11+calStage*2 20+calStage*4],k) = NaN;                    %h2o
      cal_values([21+calStage*4],k) = NaN;                                  %Tbench
      cal_values([22+calStage*4],k) = NaN;                                  %Plicor
      cal_values([16+calStage],k) = NaN;                                    %Pgauge
      % Here we can already sort out calibration that have gone terribly wrong:
      if calStage == 0 & cal_values(10,k)>400 % The offset voltage should be around 125mV
         extract_flag = -3;
			return
      end
   elseif strcmp(c.Profile.Licor.Type,'6262')
      cal_values([11+calStage*2 20+calStage*4],k) = mean(voltages(ind,2));
      cal_values([21+calStage*4],k) = mean(voltages(ind,3));
      cal_values([22+calStage*4],k) = mean(voltages(ind,4));
      cal_values([16+calStage],k) = mean(voltages(ind,5));
   elseif strcmp(c.Profile.Licor.Type,'6252')
      cal_values([11+calStage*2 20+calStage*4],k) = NaN;
      cal_values([21+calStage*4],k) = mean(voltages(ind,3));
      cal_values([22+calStage*4],k) = NaN;
      cal_values([16+calStage],k) = mean(voltages(ind,5));
   end
end

cal_values(3,k) = c.Profile.Licor.Num;
cal_values(4,k) = c.Profile.span_conc;
cal_values(5,k) = c.Profile.span_conc_cal2;

cal_values = cal_values(:,1:k);

%if the file exists but the calibration data is missing then store calibration voltages at the time 
%given by currentDate
if isempty(indCalTime)
   if currentDate > max(calTimes)
      cal_voltages = [cal_voltages cal_values];
   elseif currentDate < min(calTimes)
      cal_voltages = [cal_values cal_voltages];
   else 
      indCalNow = find(currentDate > calTimes);
      cal_voltages = [cal_voltages(:,1:length(indCalNow)) cal_values cal_voltages(:,indCalNow(end)+1:end)];
   end

%if the file does not exist then create it and store calibration voltages at the time given 
%by currentDate
elseif ~isempty(indCalTime) & indCalTime == 666 
   cal_voltages(:,:) = cal_values(:,:);

%if the file does exist and the calibration data exists, overwrite it
%by currentDate
elseif ~isempty(indCalTime) & indCalTime ~= 666 
   cal_voltages(:,indCalTime) = cal_values;
end

%!!!NOTE: if the file exists and the calibration data exists as well then we keep the old calibration 
%voltages. This will avoid overwriting calibration voltages that have been cleaned manually. So that is
%why nothing happens when ~isempty(indCalTime) & ~= 666 (David). This situation will never occur at the
%site but will occur when recalculating profile data at UBC.
fid = fopen(fileNameCal,'wb');
if fid < 3
    error(['Cannot open file: ' fileNameCal])
end
fwrite(fid,cal_voltages(:,:),'float32');
fclose(fid);

extract_flag = 1;
   
% calRecord key table:
%
% 1. Date serial number (in VB format)
% 2. Time serial number (in VB format)
% 3. Licor serial number
% 4. CO2 calibration concentration (CAL_1)
% 5. CO2 calibration concentration (CAL_2)
% 6.
% 7.
% 8.
% 9.
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

