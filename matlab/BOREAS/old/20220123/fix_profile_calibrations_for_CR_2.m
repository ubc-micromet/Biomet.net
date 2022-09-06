% fix_pr_calibrations_for_CR.m

% Feb 26, 2008:  Nick and Christian


VB2MatlabDateOffset = 693960;
GMToffset = 8/24;

% Load the archived eddy cal file (covers calibrations DOY 0 to 277)

fileName = 'D:\Sites\CR\hhour\calibrations.cc_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);

[n,m] = size(cal_voltage);

decDOY=(cal_voltage(1,:)+cal_voltage(2,:)+VB2MatlabDateOffset-GMToffset);

%------------------------------------------------------------------------
% correct bad profile calibrations 
% -insufficient cal0 flow

doy=decDOY-datenum(2007,1,0);
ind_badflow = find(doy > 302 & doy < 342 & cal_voltage(10,:) > 0 | doy > 341 & doy < 342 & cal_voltage(10,:) > -16);
cal_voltage(6,ind_badflow) = 1;
%-----------------------------------------------------------------------

fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage,'float32');
fclose(fid);
