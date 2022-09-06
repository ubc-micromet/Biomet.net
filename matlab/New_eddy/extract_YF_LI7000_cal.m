function  [cal_values_new,HF_data,cal_values] = extract_HJP75_LI7000_cal(dateIn)

if ~exist('dateIn') | isempty(dateIn)
    dateIn = fix(now)+datenum(0,0,0,7,1,0);
end

ind_HF_data = [50 150];
ind_CAL0 = [700 800];
ind_CAL1 = [1750 1850];
ind_Ambient_before = [1 50];
ind_Ambient_after = [10000 10100];
ind_all = [ind_HF_data ; ind_CAL0 ; ind_CAL1 ;ind_Ambient_before ; ind_Ambient_after] ;
instrumentNum = 5;
saveHF_flag = 1;
overwriteCal_flag = 0;
CAL1_ppm = 362;

%for i=1:30;
    try;
        [cal_values_new,HF_data,cal_values] = extract_LI7000_calibrations(dateIn,instrumentNum, ...
                                        ind_all, CAL1_ppm,saveHF_flag,overwriteCal_flag);
    end;
%end
if nargout == 0
    clear cal_values_new HF_data cal_values
end