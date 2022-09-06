% Read barometric_pressure from database and insert it into 
% cal_voltage(9,:)
VB2MatlabDateOffset = 693960;

%------------------------------------------------------
% Read profile calibrations
%------------------------------------------------------
fileName = '\\paoa001\sites\paoa\hhour\calibrations.cp_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
tv_cal =(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset);
yy = datevec(tv_cal);
yyyy = unique(yy(:,1));
yyyy = 2003; % Remove later to make this generic

%------------------------------------------------------
% Read barometric pressure
%------------------------------------------------------
pth = biomet_path('yyyy','pa','clean\thirdstage');
tv_p  = read_bor([pth 'clean_tv'],8,[],yyyy,[],1);
p_bar = read_bor([pth 'barometric_pressure_main'],[],[],yyyy,[],1);

%------------------------------------------------------
% Find LI6252 calibrations
%------------------------------------------------------
ind = find(cal_voltage(3,:) == 209);

%------------------------------------------------------
% Interpolate the barometic pressure to cal times
%------------------------------------------------------
p_bar_CAL = interp1(tv_p,p_bar,tv_cal(ind));

cal_voltage(9,ind)= p_bar_CAL;

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);

