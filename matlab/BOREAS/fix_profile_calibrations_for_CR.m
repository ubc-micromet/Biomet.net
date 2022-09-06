% fix_pr_calibrations_for_CR.m

% July 3, 2007:  Nick


%  Splices together two profile calibration files from CR
%   -the calibration file was wiped out by a fix at the site on
%    Dec 19, 2006.  Time information stored in the cal file until 2007
%    is out of range and is screwing up the plotting routines and database
%    cal extractions



VB2MatlabDateOffset = 693960;
GMToffset = 8/24;

% Load the archived eddy cal file (covers calibrations DOY 0 to 277)

fileName = 'D:\Sites\CR\HHour\calibrations_20061117.cc_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage_old = fread(fid,[30 inf],'float32');
fclose(fid);

%
% Load the current eddy cal file--covers eddy calibrations from DOY 286 to
% end of year.
%

fileName = 'D:\Sites\CR\HHour\calibrations.cc_pr';
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);

% extract calibrations that have good time info

ind_good = find(cal_voltage(1,:) > 1e4 );

% ---------- splice together archived and current cal_voltage arrays ---------------------------
% 

cal_voltage_spl = [cal_voltage_old cal_voltage(:,ind_good)];

% Save the spliced cal_voltage array to the current eddy calibrations file
fileName = 'D:\Sites\CR\HHour\calibrations.cc_pr';
fid = fopen(fileName,'wb');
if fid < 3
    error(['Cannot open file: ' fileName])
end
fwrite(fid,cal_voltage_spl,'float32');
fclose(fid);
