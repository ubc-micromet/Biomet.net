function fr_profile_get_licor_cal(currentDay,SiteId)
%fr_profile_daily_calfile(currentDay,SiteId) Update profile calibration file for current site
%
%   Input: currentDay - a vector of Matlab days in GMT
%			  SiteId     - default: fr_current_siteid
% 

if ~exist('SiteId') | isempty(SiteId)
   SiteId = fr_current_siteid;
end

% Make sure the date input are unique straight matlab days
currentDay = unique(floor(currentDay));

for k =1:length(currentDay)
   % Get calibration dates from eddy calibration file
   c = fr_get_init(SiteId,currentDay(k)+1/48);
   [CO2_cal, H2O_cal, cal_voltage, calTime] = fr_get_Licor_cal(SiteId,currentDay(k):currentDay(k)+1,2,c.hhour_path);
   
   % calTime always has last calibration before currentDay in it
   % that is removed here
   ind = find(calTime>=currentDay(k) & calTime<currentDay(k)+1);
   if isempty(ind)
      disp(['No calibration were done at ' SiteId ' on ' datestr(currentDay(k)) ]);
   else
      
      calTime = calTime(ind);
      for i = 1:length(calTime);
         try
            c_cal = fr_get_init(SiteId,calTime(i));
            extract_flag = fr_profile_get_licor_cal_exact(SiteId,calTime(i),c_cal);
            switch extract_flag 
            case 1
               disp(['Extracted calibration at ' SiteId ' ' datestr(calTime(i)) ]);
            case 0
               disp(['No data for calibration at ' SiteId ' ' datestr(calTime(i)) ]);
            case -1
               disp(['Could not read data file for calibration at ' SiteId ' ' datestr(calTime(i)) ]);
            case -2
               disp(['No data for calibration at ' SiteId ' ' datestr(calTime(i)) ]);
            case -3
               disp(['Calibration not working at ' SiteId ' ' datestr(calTime(i)) ]);
            end
            
         catch
            disp(lasterr);
            disp(['Error extracting calibration at ' SiteId ' ' datestr(calTime(i)) ]);
         end
         
      end
   end
end

