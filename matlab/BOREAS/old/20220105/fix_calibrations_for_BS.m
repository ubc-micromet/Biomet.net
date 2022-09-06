VB2MatlabDateOffset = 693960;
GMToffset = 6/24;

%fileName = 'D:\sites\paob\hhour\calibrations_20030627b.CB2';
%fid = fopen(fileName,'r');
%if fid < 3
%    error(['Cannot open file: ' fileName])
%end
%cal_voltage_old = fread(fid,[30 inf],'float32');
%fclose(fid);


fileName = 'D:\sites\paob\hhour\calibrations.cb2';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);


% ---------- fix 1 -------------------------------------
% append old calibration file (before computer HD crash 
% in July 2003 to the new one (since the HD was restored)
%cal_voltage = [cal_voltage_old cal_voltage];
% ----------- end of fix 1 -------------------------------


[n,m] = size(cal_voltage);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

% ---------- fix 2 -------------------------------------
% fix bad calibration gas value for Apr 11, 2003 until Jun 27, 2003
ind = find(decDOY >= datenum(2003,4,11) & decDOY <= datenum(2003,7,11));
% fix CAL1 value
cal_voltage(4,ind)=361.975;
% ----------- end of fix 2 -------------------------------

% ---------- fix 3 -------------------------------------
% fix bad calibration zero value for Apr 11, 2003 until Apr 26, 2003
ind = find(decDOY >= datenum(2003,4,10) & decDOY <= datenum(2003,4,26));
% fix CAL0 corrected value
cal_voltage(10,ind)=cal_voltage(10,ind(1)-1);
cal_voltage(11,ind)=linspace(cal_voltage(13,ind(1)-1),cal_voltage(13,ind(end)+1),length(ind));

% ----------- end of fix 2 -------------------------------

% Save the results
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end


fwrite(fid,cal_voltage,'float32');
fclose(fid);

