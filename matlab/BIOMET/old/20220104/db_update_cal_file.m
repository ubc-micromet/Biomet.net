function OutputData = db_update_cal_file(Year,cal_fileName,pth)
%
%
% (c) kai*           File created:       Aug 15, 2003
%                    Last modification:  
%

%
% Revisions:

tic;
VB2MatlabDateOffset = 693960;

%------------------------------------------------------------
% Open calibration file and read calibration times &values
%------------------------------------------------------------
fid = fopen(cal_fileName,'r');
if fid < 3
   error(['Cannot open file: ' cal_fileName ' - did nothing.']);
end

cal_voltage = fread(fid,[30 inf],'float32');
OutputData = cal_voltage';
fclose(fid);

calTime=(cal_voltage(1,:)+cal_voltage(2,:))'+VB2MatlabDateOffset;       % convert calibration times to a time vector

%------------------------------------------------------------
% Check output pth
%------------------------------------------------------------
pth_out = fr_valid_path_name(pth);          % check the path and create
if isempty(pth_out)                         
    error 'Directory does not exist!'
else
    pth = pth_out;
end
err_count = 0;

%-------------------------------------------------------
% Save calibration values for Year in pth
%-------------------------------------------------------
ind = find(calTime > datenum(Year,1,1,0,29,0) & calTime < datenum(Year+1,1,1,0,1,0) );

calTime = calTime(ind);
OutputData = OutputData(ind,:);
[n,m] = size(OutputData);

try,
   fileOut = fullfile(pth,['cal_tv']);
   f1 = save_bor(fileOut,8,calTime);
   for i = 1:m
      fileOut = fullfile(pth,['cal.' num2str(i)]);
      f1 = save_bor(fileOut,1,OutputData(:,i));
   end
catch,
   error(['Could not save ' fileOut]);
end

disp(['Updated calibration data in directory ' pth]);
disp(['from calibration file ' cal_fileName]);
disp(['in ' num2str(toc,'%3.1f') ' sec']);
return