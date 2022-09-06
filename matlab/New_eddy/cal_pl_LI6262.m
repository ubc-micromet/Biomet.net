function [cal_values_out] = cal_pl_li6262(indX,Year,SiteID,pth)
% [cal_values_out, HF_data_out] = cal_pl_li7000(indX,Year,SiteID,pth) Plot LI-7000 calibrations
% 
% 
% (c) Zoran Nesic       File created:       Dec 15, 2004
%                       Last modification:  Dec 24, 2004

%
% Revisions:
% Nov 29, 2005, kai* - adapted function to new ini-file structure
% Feb 22, 2007, Iain - corrected graph labels at lines 187-188

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

c= fr_get_init(SiteID,TimeVector(end));                 % get the most current init file 
if exist('pth')~=1 | isempty(pth)
    pth = c(end).hhour_path;                                % site and use the local path
end

types = {c.Instrument(:).Type};
instrumentNum = find(strcmp(types,'6262'));
%ext = [c.ext c.Instrument(instrumentNum).FileID];
ext = [c.ext num2str(instrumentNum)];
ext(2) = 'c';            % replace "d" with "c" for calibration
%GMToffset = -1 * c.gmt_to_local;
GMToffset = -8;
%----- Temperature correction -----
Tp=[0 0];
%----- pressure correction -----
Pp = [0 0];  % line through two points, to avoid noise
% switch upper(SiteID)
%     case 'HJP75', 
% 		%----- Temperature correction -----
% 		Tp=polyfit([24.8 37.7],[364.2 361.5]-CAL_1_ppm,1);
% 		%----- pressure correction -----
% 		Pp = polyfit([80 88],[361.7 361.2]-CAL_1_ppm,1);  % line through two points, to avoid noise
% end

if exist(pth)==2                            % if pth is a file name assign it to fileName
    fileName = pth;
else                                        % if pth is only a path
    if pth(end)~='\'                        % make sure it has a "\" at the end
        pth = [pth '\'];
    end
    fileName = [pth 'calibrations' ext '.mat'];   % and append the file name
end

load(fileName);

tv=get_stats_field(cal_values,'TimeVector');

m = length(cal_values);

cal_ignor = get_stats_field(cal_values,'Ignore');

if exist('TimeVector') == 1 & ~isempty(TimeVector)
    ind = find((tv >= min(TimeVector) & tv <= max(TimeVector)) & cal_ignor==0 );
else
    ind = 1:m;
end

cal_values = cal_values(ind);
decDOY = tv-datenum(Year,1,0);
decDOY=decDOY(ind);
tv = tv(ind);

co2_z=get_stats_field(cal_values,'measured.Cal0.CO2');
h2o_z=get_stats_field(cal_values,'measured.Cal0.H2O');
co2_z_cor = get_stats_field(cal_values,'corrected.Cal0.CO2');
h2o_z_cor = get_stats_field(cal_values,'corrected.Cal0.H2O');
Tbench_z=get_stats_field(cal_values,'measured.Cal0.Tbench');
Plicor_z=get_stats_field(cal_values,'measured.Cal0.Plicor');
%Diag_z=get_stats_field(cal_values,'measured.Cal0.Diag');

co2=get_stats_field(cal_values,'measured.Cal1.CO2');
h2o=get_stats_field(cal_values,'measured.Cal1.H2O');
co2_cor = get_stats_field(cal_values,'corrected.Cal1.CO2');
h2o_cor = get_stats_field(cal_values,'corrected.Cal1.H2O');
Tbench=get_stats_field(cal_values,'measured.Cal1.Tbench');
Plicor=get_stats_field(cal_values,'measured.Cal1.Plicor');
%Diag=get_stats_field(cal_values,'measured.Cal1.Diag');

CAL_1_cal = get_stats_field(cal_values,'measured.Cal1.Cal_ppm');
CAL_1_cal_cor = get_stats_field(cal_values,'corrected.Cal1.Cal_ppm');
CAL_2_cal = get_stats_field(cal_values,'measured.Cal2.Cal_ppm');

Li_No_cal = get_stats_field(cal_values,'SerNum');

[CO2_cal, H2O_cal] = fr_get_LI6262_cal(SiteID,tv,c,instrumentNum);
%CO2_cal = CO2_cal(ind,:);
%H2O_cal = H2O_cal(ind,:);
% gain     = CAL_1_cal(ind)./(co2(ind)-co2_z(ind)-polyval(Tp,Tbench(ind)));
% gain_cor = CAL_1_cal_cor(ind)./(co2_cor(ind)-co2_z_cor(ind)-polyval(Tp,Tbench(ind)));

% Load calibration HF data
for i = 1:length(ind)
    c(i)= fr_get_init(SiteID,TimeVector(i));                 % get the most current init file 

    % fileName_hf = [pth fr_datetofilename(tv(ind(i))) c(i).ext c(i).Instrument(instrumentNum).FileID '_cal.mat']; 
    fileName_hf = [pth fr_datetofilename(tv(i)) c(i).ext c(i).Instrument(instrumentNum).FileID '_cal.mat']; 
    try
        load(fileName_hf);
        co2_hf(:,i) = cal_values(ind(i)).HF_data(:,1);
        h2o_hf(:,i) = cal_values(ind(i)).HF_data(:,2);
    end
    co2_hf(:,i) = cal_values(i).HF_data(:,1);
    h2o_hf(:,i) = cal_values(i).HF_data(:,2);
    tv_hf = [1:length(co2_hf)]./c(i).Instrument(instrumentNum).Fs;
end    

CAL_1_ini = get_stats_field(c,['Instrument(' num2str(instrumentNum) ').Cal.ppm(2)']);
CAL_2_ini = get_stats_field(c,['Instrument(' num2str(instrumentNum) ').Cal.ppm(3)']);
Li_No_ini = get_stats_field(c,['Instrument(' num2str(instrumentNum) ').SerNum']);

% Format output data

fig=0;

fig=fig+1;
figure(fig)
clf

%Licor temperature (C)

plot(decDOY,0.01221*[Tbench_z Tbench],'o-')
grid on
title([ 'Calibration (' SiteID ' site) ' num2str(max(Year))])
ylabel('Temp (degC)')
xlabel('DOY')
legend('zero','cal1',-1)
zoom on

if ~isnan(Li_No_cal(end))                    % need pp only
   [cp,hp,Tc,Th,pp] = licor(Li_No_cal(end));
else
   pp = [1 1 1];
end

%Licor pressure (kPa)
fig=fig+1;
figure(fig)
clf
plot(decDOY,polyval(pp,[Plicor_z Plicor]),'o-')
grid on
title([ 'Calibration (' SiteID ' site) ' num2str(max(Year))])
ylabel('Pressure (kPa)')
xlabel('DOY')
legend('zero','cal1',-1)
zoom on

%Zero calibration (mV)
fig=fig+1;
figure(fig)
clf
plot(decDOY,[co2_z h2o_z h2o],'o-')
grid on
title([ 'Zero calibration (' SiteID ' site) ' num2str(max(Year))])
ylabel('mV')
xlabel('DOY')
legend('CO_2','H_2O(1)','H_2O(2)',-1)
zoom on

%Span calibration 
fig=fig+1;
figure(fig)
clf
plot(decDOY,CO2_cal(:,1),'o-')
grid on
title(['CO_2 calibration (' SiteID ' site)'])
ylabel('1')
xlabel('DOY')
zoom on

%Calibration gases and Licor number
fig=fig+1;
figure(fig)
clf
plot(decDOY,[CAL_1_ini CAL_2_ini Li_No_cal Li_No_ini],'o-');
legend('cal1','cal2','Licor nbr calFile','Licor nbr iniFile',-1);
zoom on;
  

% plot(decDOY(ind),[Tbench_z(ind) Tbench(ind)],'-o')
% ylabel('\circC')
% title('Licor temperature')
% legend('zero','cal1')
% zoom on
% 
% fig=fig+1;
% figure(fig)
% plot(decDOY(ind),[Plicor_z(ind) Plicor(ind)],'-o')
% ylabel('kPa')
% title('Licor Pressure')
% legend('zero','cal1')
% zoom on
% 
% fig=fig+1;
% figure(fig)
% plot(decDOY(ind),[Diag_z(ind) Diag(ind)],'-o')
% ylabel('1')
% title('Licor Diagnostics')
% legend('zero','cal1')
% zoom on
% 
% fig=fig+1;
% figure(fig)
% plot(decDOY(ind),co2_z(ind),'-o',decDOY(ind),co2_z_cor(ind),'h')
% ylabel('ppm')
% legend('measured','corrected')
% title('Zero Calibrations CO_2')
% zoom on
% 
% fig=fig+1;
% figure(fig)
% plot(decDOY(ind),[h2o_z(ind) h2o(ind)],'-o',decDOY(ind),[h2o_z_cor(ind) h2o_cor(ind)],'h')
% legend('Cal0 measured','Cal1 measured','Cal0 corrected','Cal1 corrected')
% ylabel('mmol/mol')
% title('Zero Calibrations H_2O')
% legend('Zero measured','Span measured','Zero corrected','Span corrected')
% zoom on
% 
% fig=fig+1;
% figure(fig)
% plot(decDOY(ind),gain,'-o',decDOY(ind),gain_cor,'h')
% title('Gain CO_2 (zero offset and temperature drift removed)')
% legend('Measured','Corrected')
% zoom on
% 
% fig=fig+1; 
% figure(fig)
% plot(decDOY(ind),co2(ind),'o-');
% line(decDOY(ind),co2_cor(ind),'Color','g','Marker','h','LineStyle','none')
% line(decDOY(ind),co2_cor(ind)-co2_z_cor(ind),'Color','m')
% line(decDOY(ind),gain_cor.*(co2_cor(ind)-co2_z_cor(ind)),'marker','x','Color','c')
% line(decDOY(ind),CAL_1_cal_cor(ind),'marker','s','linew',2)
% ylabel('mmol/mol')
% title('Calibration CO_2')
% legend('Original','Offset removed','Gain added','Cal1 tank')
% zoom on
% 
% fig=fig+1;
% figure(fig)
% plot(decDOY(ind),[CAL_1_cal(ind),CAL_2_cal(ind),Li_No_cal(ind)],'h',...
%      decDOY(ind),[CAL_1_ini,CAL_2_ini,Li_No_ini],'o-')
% legend('CAL1 ppm (cal)','CAL2 ppm (cal)','Licor No (cal)',...
%     'CAL1 ppm (ini)','CAL2 ppm (ini)','Licor No(ini)')
% zoom on
% 
fig=fig+1;
figure(fig)
plot(tv_hf,co2_hf,'.-')
title('Time response CO_2')
xlabel('t (s)')
ylabel('CO_2 (mV)')
zoom on

fig=fig+1;
figure(fig)
plot(tv_hf,h2o_hf,'.-')
title('Time response H_2O')
xlabel('t (s)')
ylabel('H_2O (mV)')
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
