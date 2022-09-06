function [cal_voltage,cal_value] = cal_pl(indX,Year,SiteID,pth,flag_sys)
% [cal_voltage,cal_value] = cal_pl(indX,Year,SiteID,pth,flag_sys) Plot calibrations
% 
% flag_sys - 'EC' 'PR' 'CH'
% 

% (c) Zoran Nesic       File created:       Sep 13, 1998
%                       Last modification:  Jul 02, 2003

% calRecord key table:
%
% 1. Date serial number (in VB format)
% 2. Time serial number (in VB format)
% 3. Licor serial number
% 4. CO2 calibration concentration (CAL_1)
% 5. CO2 calibration concentration (CAL_2)
% 6. Flag 'Ignore calibration' (cal not used of ==1)
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

%
% Revisions:
%
% Jul 02, 2003
%   - added flag_prof parameter to enable plotting of profile calibrations
% Jul 22, 2001
%   - fixed a bug that caused the program to bomb when pth is not given
%   - fixed a bug that created errors when comparing the calibration
%     values with the setup values (input to read_init_files - NewTV) was local not GMT
%     time. 
% Jun 20, 2001
%   - made it possible to input the calibration file name instead of the path.
%     Good for plotting the hand-made calibration files with wierd extensions.
% Mar 8, 2000
%   - big changes in the way program works:
%       1. added plotting of the setup calibration values
%       2. program reads the setup ini file as many times as there
%          are points. This will help in tracking down wrong setup
%          values
%
% Jan 8, 2000
%   - new tank for BS  (Jan 8, 2000 CC78242)
% Dec 29, 1999
%   - added new tank for PA (running since Dec 23, 1999)
% Nov 14, 1999
%   - tried to set automatic site detection so program can find by itself
%     the right data location
%   - added a few plots
% Sep  4, 1999
%   - added JP to the site list
% Jan  1, 1999
%   - added parameter "pth" to the end of list
% Nov 22, 1998
%   - replaced input parameter "pth" with "year" to keep the syntax the same
%     among all plotting programs. ("year" is not used, yet)
% Nov 11, 1998
%   - Added one more pressure (after calibration - normal operation), and
%     converted pressure to kPa.
% Oct 8, 1998
%   - Changed paths designation when pth = [].
% Sep 17, 1998
%   - default path now works over the net
% Sep 14, 1998
%   - converted VB date format to matlab date format and included the GMToffset

VB2MatlabDateOffset = 693960;

if exist('SiteID')~=1 | isempty(SiteID)
    SiteID = fr_current_siteID;
end

if exist('Year')~=1 | isempty(Year)
   [Year,junk,junk]=datevec(now);
end

if exist('indX') ~= 1 | isempty(indX)
    indX = (datenum(Year,1,1):now)-datenum(Year,1,0);           % assume current year, all days
end

TimeVector = datenum(Year,1,0) + indX;
if exist('pth')~=1 | isempty(pth)
    c= fr_get_init(SiteID,TimeVector(end));                 % get the most current init file 
    pth = c(end).hhour_path;                                % site and use the local path
end

if exist('flag_sys')~=1 | isempty(flag_sys)
   flag_sys = 'EC';
end

% Determine calibration file extension
switch upper(SiteID)
        %    case 'CR', ext = 'cc2';LicorNum = 791;c_cal_ppm = 346.9;GMToffset = 8/24;
        %    case 'CR', ext = 'cc2';LicorNum = 791;c_cal_ppm = 352;GMToffset = 8/24;
        %    case 'CR', ext = 'cc2';LicorNum = 740;c_cal_ppm = 352;GMToffset = 8/24;
    case 'CR', ext = 'cc2';GMToffset = 8/24;
        %    case 'PA', ext = 'cp2';LicorNum = 914;c_cal_ppm = 349.38;GMToffset = 6/24; % removed May 25, 1999
        %case 'PA', ext = 'cp2';LicorNum = 914;c_cal_ppm = 359.796;GMToffset = 6/24; % New tank May 25, 1999, CC 21523
        %case 'PA', ext = 'cp2';LicorNum = 1038;c_cal_ppm = 359.796;GMToffset = 6/24; % New Licor Jun 30, 1999
        %case 'PA', ext = 'cp2';LicorNum = 1038;c_cal_ppm = 361.117;GMToffset = 6/24; % New tank Dec 23, 1999 CC 84683
    case 'YF', ext = 'cyf';GMToffset = 8/24;
    case 'PA', ext = 'cp2';GMToffset = 6/24; 
        %    case 'BS', ext = 'cb2';LicorNum = 1037;c_cal_ppm = 359.76;GMToffset = 6/24;
        %    case 'BS', ext = 'cb2';LicorNum = 1036;c_cal_ppm = 359.76;GMToffset = 6/24;  % New Licor box, Jun 29, 1999
        %    case 'BS', ext = 'cb2';LicorNum = 1036;c_cal_ppm = 361.39;GMToffset = 6/24;  % New calibration tank, Jan 8, 2000 CC78242
    case 'BS', ext = 'cb2';GMToffset = 6/24; 
        %    case 'JP', ext = 'cj2';LicorNum = 939;c_cal_ppm = 359.288;GMToffset = 6/24;  % New Licor box, Jun 29, 1999
    case 'JP', ext = 'cj2';GMToffset = 6/24;  
    otherwise, error 'Wrong site ID!'
end

switch upper(flag_sys)   
case 'EC'
	% do nothing   
case 'PR'
   ext = [ext(1:2) '_pr'];
case 'CH'
    if strcmp(upper(SiteID),'YF')    
       ext = [ext(1:3) '_ch'];
    else
        ext = [ext(1:2) '_ch'];
    end
end

   
if exist(pth)==2                            % if pth is a file name assign it to fileName
    fileName = pth;
else                                        % if pth is only a path
    if pth(end)~='\'                        % make sure it has a "\" at the end
        pth = [pth '\'];
    end
    fileName = [pth 'calibrations.' ext];   % and append the file name
end

%---------- begin skip --------------------
if 0
fid = fopen(fileName,'r');
if fid < 3
    error(['Cannot open file: ' fileName])
end
cal_voltage = fread(fid,[30 inf],'float32');
fclose(fid);
decDOY=(cal_voltage(1,:)+cal_voltage(2,:)-datenum(Year,1,1))+VB2MatlabDateOffset-GMToffset+1;
end
%---------- end skip   --------------------

% =====---- begin new ---------------------
switch upper(flag_sys)   
case {'EC','CH'}
   [CO2_Cal, H2O_Cal, cal_voltage, calTime,LicorNum] = fr_get_Licor_cal(fileName);
case 'PR'
   [CO2_Cal,H2O_Cal,cal_voltage,calTime,LicorNum] =  fr_get_Licor_cal_all_types(fileName);
end
decDOY = calTime - datenum(Year,1,1) - GMToffset + 1;
% =====---- end new ---------------------

[n,m] = size(cal_voltage);

if exist('indX') == 1 & ~isempty(indX)
    ind = find(decDOY >= min(indX) & decDOY <= max(indX));
else
    ind = 1:m;
end
CO2_Cal = CO2_Cal(ind,:);
H2O_Cal = H2O_Cal(ind,:);
decDOY = decDOY(ind);
cal_voltage = cal_voltage(:,ind);
LicorNum = LicorNum(ind);
newTV = (indX + datenum(Year,1,0) + GMToffset);             % range of dates to process (make sure it's in GMT)
N = length(newTV);
newTVDOY =  newTV - datenum(Year,1,0) - GMToffset;
%newTVDOY =  decDOY;

%fr_licor_invert_cal(fileName);

c = read_ini_files(SiteID,newTV);                           % read ini files the range
pth = c(end).hhour_path;                                    % site and use the local path

switch upper(flag_sys)   
case 'EC'
   Cal.CO2_cal = [c(:).CO2_Cal];
   Cal.H2O_cal = [c(:).H2O_Cal];
   LicorNo     = [c(:).licor];
case 'PR'
   Cal = [c(:).Profile];
   Cal = [Cal(:).Licor];
   for i=1:length(c), LicorNo(i) = c(i).Profile.Licor.Num; end;
case 'CH'
   Cal = [c(:).chamber];
   Cal = [Cal(:).Licor];
   for i=1:length(c), LicorNo(i) = c(i).chamber.Licor.Num; end;
end
CO2_Cal_setup = reshape([Cal(:).CO2_cal],[ 2 N])';
H2O_Cal_setup = reshape([Cal(:).H2O_cal],[ 2 N])';

%Licor temperature (C)
fig = 0;
fig=fig+1;
figure(fig)
clf
plot(decDOY,0.01221*cal_voltage([21 25],:),'o-')
grid on
title([ 'Calibration (' SiteID ' site) ' num2str(max(Year))])
ylabel('Temp (degC)')
xlabel('DOY')
legend('zero','cal1',-1)
zoom on

if ~isnan(LicorNum(end))
   [cp,hp,Tc,Th,pp] = licor(LicorNum(end));                    % need pp only
else
   pp = [1 1 1];
end

%Licor pressure (kPa)
fig=fig+1;
figure(fig)
clf
plot(decDOY,polyval(pp,cal_voltage([22 26 30],:)),'o-')
grid on
title([ 'Calibration (' SiteID ' site) ' num2str(max(Year))])
ylabel('Pressure (kPa)')
xlabel('DOY')
legend('zero','cal1','cal2',-1)
zoom on

%Gauge pressure (kPa)
if flag_sys == 'EC' | flag_sys == 'PR'  
fig=fig+1;
figure(fig)
clf
plot(decDOY,polyval(c(end).Pgauge_poly,cal_voltage([16:18],:)),'o-')
grid on
title([ 'Calibration (' SiteID ' site) ' num2str(max(Year))])
ylabel('Gauge Pressure (kPa)')
xlabel('DOY')
legend('zero','cal1','cal2',-1)
zoom on
end

%Zero calibration (mV)
fig=fig+1;
figure(fig)
clf
plot(decDOY,cal_voltage([19:20 24],:),'o-', ...
     newTVDOY,-CO2_Cal_setup(:,2),'h',...
     newTVDOY,-H2O_Cal_setup(:,2),'h')
grid on
title([ 'Zero calibration (' SiteID ' site) ' num2str(max(Year))])
ylabel('mV')
xlabel('DOY')
legend('CO_2','H_2O(1)','H_2O(2)','CO2_{setup}','H2O_{setup}',-1)
zoom on

%Span calibration (mV)
fig=fig+1;
figure(fig)
clf
plot(decDOY,CO2_Cal(:,1),'o-', ...
     newTVDOY,[CO2_Cal_setup(:,1)],'h')
grid on
title(['CO_2 calibration (' SiteID ' site)'])
ylabel('1')
xlabel('DOY')
zoom on

%Calibration gases and Licor number
fig=fig+1;
figure(fig)
clf
plot(decDOY,cal_voltage([4:5 3],:),'o-',newTVDOY,LicorNo,'h');
legend('cal1','cal2','Licor nbr calFile','Licor nbr iniFile',-1);
zoom on;
  
%N=max(get(0,'children'));
%for i=1:N;
%    figure(i);
%    if i ~=N
%       pause;
%    end
%end

childn = get(0,'children');
childn = sort(childn);
N = length(childn);
for i=childn(:)';
    if i < 200 
        figure(i);
%        if i ~= childn(N-1)
            pause;
%        end
    end
end

function c = read_ini_files(SiteID,TimeVector)
    N = length(TimeVector);
    for i=1:N;
         c(i)= fr_get_init(SiteID,TimeVector(i));                 %
%        LicorNum(i)=c.licor;
%        co2Cal(i,:) = c.CO2_Cal;
%        h2oCal(i,:) = c.H2O_Cal;
    end

