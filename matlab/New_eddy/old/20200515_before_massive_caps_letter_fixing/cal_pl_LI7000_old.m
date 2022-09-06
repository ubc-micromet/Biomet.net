function [cal_voltage,cal_value] = cal_pl_li7000(indX,Year,SiteID,pth)
% [cal_voltage,cal_value] = cal_pl_li7000(indX,Year,SiteID,pth) Plot LI-7000 calibrations
% 
% 
% (c) Zoran Nesic       File created:       Dec 15, 2004
%                       Last modification:  Nov 29, 2006

%
% Revisions:
%
% NOv 29, 2006
%  - added 0.9999 to the TimeVector to be able to see the last point for
%  the day

if exist('SiteID')~=1 | isempty(SiteID)
    SiteID = fr_current_siteID;
end

if exist('Year')~=1 | isempty(Year)
   [Year,junk,junk]=datevec(now);
end

if exist('indX') ~= 1 | isempty(indX)
    indX = (datenum(Year,1,1):now)-datenum(Year,1,0);           % assume current year, all days
end

TimeVector = datenum(Year,1,0) + indX + 0.9999;        % added 0.9999 to catch the entire last day (Z) 20061129

if exist('pth')~=1 | isempty(pth)
    c= fr_get_init(SiteID,TimeVector(end));                 % get the most current init file 
    pth = c(end).hhour_path;                                % site and use the local path
end

% Determine calibration file extension
switch upper(SiteID)
        %    case 'CR', ext = 'cc2';LicorNum = 791;c_cal_ppm = 346.9;GMToffset = 8/24;
        %    case 'CR', ext = 'cc2';LicorNum = 791;c_cal_ppm = 352;GMToffset = 8/24;
        %    case 'CR', ext = 'cc2';LicorNum = 740;c_cal_ppm = 352;GMToffset = 8/24;
    case 'HJP75', ext = 'ch75_8';CAL_1_ppm = 361.5;GMToffset = 8/24;
        %    case 'XSITE', ext = 'cX8';CAL_1_ppm = 359.52;GMToffset = 5/24; 
%    case 'XSITE', ext = 'cX8';CAL_1_ppm = 359.52;GMToffset = 5/24; % @
%    ON_GR
    case 'XSITE', ext = 'cX8';CAL_1_ppm = 364.241;GMToffset = 4/24;
        %    case 'PA', ext = 'cp2';LicorNum = 914;c_cal_ppm = 349.38;GMToffset = 6/24; % removed May 25, 1999
        %case 'PA', ext = 'cp2';LicorNum = 914;c_cal_ppm = 359.796;GMToffset = 6/24; % New tank May 25, 1999, CC 21523
        %case 'PA', ext = 'cp2';LicorNum = 1038;c_cal_ppm = 359.796;GMToffset = 6/24; % New Licor Jun 30, 1999
        %case 'PA', ext = 'cp2';LicorNum = 1038;c_cal_ppm = 361.117;GMToffset = 6/24; % New tank Dec 23, 1999 CC 84683
%    case 'PA', ext = 'cp2';GMToffset = 6/24; 
        %    case 'BS', ext = 'cb2';LicorNum = 1037;c_cal_ppm = 359.76;GMToffset = 6/24;
        %    case 'BS', ext = 'cb2';LicorNum = 1036;c_cal_ppm = 359.76;GMToffset = 6/24;  % New Licor box, Jun 29, 1999
        %    case 'BS', ext = 'cb2';LicorNum = 1036;c_cal_ppm = 361.39;GMToffset = 6/24;  % New calibration tank, Jan 8, 2000 CC78242
%    case 'BS', ext = 'cb2';GMToffset = 6/24; 
        %    case 'JP', ext = 'cj2';LicorNum = 939;c_cal_ppm = 359.288;GMToffset = 6/24;  % New Licor box, Jun 29, 1999
%    case 'JP', ext = 'cj2';GMToffset = 6/24;  
    otherwise, error 'Wrong site ID!'
end

   
if exist(pth)==2                            % if pth is a file name assign it to fileName
    fileName = pth;
else                                        % if pth is only a path
    if pth(end)~='\'                        % make sure it has a "\" at the end
        pth = [pth '\'];
    end
    fileName = [pth 'calibrations.' ext];   % and append the file name
end

load( fileName,'-mat')

switch upper(SiteID)
    case 'HJP75', 
        ext = 'ch75_8';
        CAL_1_ppm = 361.5;
        GMToffset = 8/24;
		%----- Temperature correction -----
		Tp=polyfit([24.8 37.7],[364.2 361.5]-CAL_1_ppm,1);
		%----- pressure correction -----
		Pp = polyfit([80 88],[361.7 361.2]-CAL_1_ppm,1);  % line through two points, to avoid noise
    case 'XSITE', 
        ext = 'cX8';
CAL_1_ppm = 364.241;
% CAL_1_ppm = 359.52; % @ ON_GR
        GMToffset = 5/24;
		%----- Temperature correction -----
		Tp=[0 0];
		%----- pressure correction -----
		Pp = [0 0];  % line through two points, to avoid noise
    otherwise, error 'Wrong site ID!'
end

tv=get_stats_field(cal_values,'TimeVector');

m = length(cal_values);

if exist('TimeVector') == 1 & ~isempty(TimeVector)
    ind = find(tv >= min(TimeVector) & tv <= max(TimeVector));
else
    ind = 1:m;
end

decDOY = tv-datenum(Year,1,0);

co2_z=get_stats_field(cal_values,'Cal0.CO2');
h2o_z=get_stats_field(cal_values,'Cal0.H2O');
Tbench_z=get_stats_field(cal_values,'Cal0.Tbench');
Plicor_z=get_stats_field(cal_values,'Cal0.Plicor');
Diag_z=get_stats_field(cal_values,'Cal0.Diag');

co2=get_stats_field(cal_values,'Cal1.CO2');
h2o=get_stats_field(cal_values,'Cal1.H2O');
Tbench=get_stats_field(cal_values,'Cal1.Tbench');
Plicor=get_stats_field(cal_values,'Cal1.Plicor');
Diag=get_stats_field(cal_values,'Cal1.Diag');


fig=0;

fig=fig+1;
figure(fig)
clf
plot(decDOY(ind),Tbench(ind),'-o')
ylabel('\circC')
title('Licor temperature')
zoom on

fig=fig+1;
figure(fig)
plot(decDOY(ind),Plicor(ind),'-o')
ylabel('kPa')
title('Licor Pressure')
zoom on

fig=fig+1;
figure(fig)
plot(decDOY(ind),Diag(ind),'-o')
ylabel('1')
title('Licor Diagnostics')
zoom on

fig=fig+1;
figure(fig)
plot(decDOY(ind),co2_z(ind),'-o')
ylabel('ppm')
title('Zero Calibrations CO_2')
zoom on

fig=fig+1;
figure(fig)
plot(decDOY(ind),[h2o_z(ind) h2o(ind)],'-o')
legend('Cal0','Cal1')
ylabel('mmol/mol')
title('Zero Calibrations H_2O')
zoom on

fig=fig+1;
figure(fig)
plot(decDOY(ind),co2(ind),decDOY(ind),co2(ind)-co2_z(ind), ...
            decDOY(ind),co2(ind)-co2_z(ind)-polyval(Tp,Tbench(ind)),...
            decDOY(ind),co2(ind)-co2_z(ind)-polyval(Tp,Tbench(ind))-polyval(Pp,Plicor(ind)),'-o')
line(decDOY(ind),ones(size(ind))*CAL_1_ppm,'marker','s','linew',2)
ylabel('mmol/mol')
title('Calibration CO_2')
zoom on
legend('Original','Offset removed','Temp.drift removed','Press.drift removed','Cal1 tank')

fig=fig+1;
figure(fig)
plot(decDOY(ind),ones(size(ind))*CAL_1_ppm./(co2(ind)-co2_z(ind)-polyval(Tp,Tbench(ind))),'-o')
title('Gain CO_2 (zero offset and temperature drift removed)')
zoom on


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

return

fig=fig+1;
figure(fig)
plot(tv(ind),co2(ind))
datetick('x')
ylabel('ppm')
title('Cal1')
zoom on

fig=fig+1;
figure(fig)
plot(Tb,cz)
xlabel('Tbench')
title('Tbench vs Cal0')
zoom on

fig=fig+1;
figure(fig)
plot(Tb,c,'o')
xlabel('Tbench')
title('Tbench vs Cal1')
zoom on

fig=fig+1;
figure(fig)
plot(Tb,c-cz,'o')
xlabel('Tbench')
zoom on
title('Tbench vs Cal1-Cal0')

p=polyfit([24.8 37.7],[364.2 361.5]-361.5,1);

fig=fig+1;
figure(fig)
plot(Tb,c-cz-polyval(p,Tb),'o')
zoom on
title('Using calibration values to correct the Cal1')
ylabel('c-cz-polyval(p,Tb)')
xlabel('Tbench')

fig=fig+1;
figure(fig)
plot(tv(ind(k)),c-cz-polyval(p,Tb),'o')
datetick('x')
zoom on
title('Using calibration values to correct the Cal1')
ylabel('c-cz-polyval(p,Tb)')

fig=fig+1;
figure(fig)
plot(tv(ind),co2(ind),'b')
line(tv(ind),co2(ind)-co2_z(ind),'col','g')
line(tv(ind),co2(ind)-co2_z(ind)-polyval(p,Tbench(ind)),'col','r')
%hold on;
line(tv(ind),co2(ind)-co2_z(ind)-polyval(p,Tbench(ind))-polyval(Pp,Plicor(ind)),'col','k');
line(tv(ind([1 end])),[1 1]*361.5,'col','k','linest','--');
%hold off
datetick('x')
zoom on
legend('no corr.','zero off','-Toff','-Poff',num2str(CAL_1_ppm))
title('Using T and P correction on Cal1')
ylabel('ppm')
