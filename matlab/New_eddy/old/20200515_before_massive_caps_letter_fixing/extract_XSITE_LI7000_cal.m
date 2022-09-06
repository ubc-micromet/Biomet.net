function  [cal_values_new,HF_data,cal_values] = extract_XSITE_LI7000_cal(dateIn)

if ~exist('dateIn') | isempty(dateIn)
    dateIn = fix(now)+datenum(0,0,0,8,40,0);
end

ind_HF_data = [12220 12320];
ind_CAL0 = [12650 12750];
ind_CAL1 = [13150 13250];
ind_Ambient_before = [12000 12100];
ind_Ambient_after  = [14000 14100];
ind_all = [ind_HF_data ; ind_CAL0 ; ind_CAL1 ;ind_Ambient_before ; ind_Ambient_after] ;
instrumentNum = 2;
saveHF_flag = 1;
overwriteCal_flag = 0;
% CAL1_ppm = 359.52; % at ON_GR
CAL1_ppm = 364.241;

for i=1:length(dateIn)
    try;
        [cal_values_new,HF_data,cal_values] = extract_LI7000_calibrations(dateIn(i),instrumentNum, ...
                                        ind_all, CAL1_ppm,saveHF_flag,overwriteCal_flag);
    end;
end
if nargout == 0
    clear cal_values_new HF_data cal_values
end