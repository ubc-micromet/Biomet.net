function plotdata(dateIn)
% Plot CSAT, Li700 and FWTC data
% May 24, 2002

% Constants
Rd = 287.04;  % J/K/kg
gamad = 1.4;


% Read CSAT data file
x   = readCSAT(['CS' dateIn '.bin']);
ux = x(:,1);  % x wind in m/s
uy = x(:,2);  % y wind in m/s
uz = x(:,3);  % z wind in m/s
ts = x(:,4);  % sonic temp in deg C

% Read Thermocouple data
ttc = readFWTC(['TC' dateIn '.bin']);
ttc=resample(ttc,600,639);
% Read LICOR data file
licor = readLI7000(['LI' dateIn '.bin']);

dco2    = licor(:,1);  % Diff CO2 umol/mol
dh2o    = licor(:,2);  % Diff H2O in mmol/mol
press   = licor(:,3);  % Sanple cell pressure in kPa
tirga   = licor(:,4);  % IRGA temp in deg C
tsaux1  = licor(:,5); % sonic temp (aux1) deg C
tsaux1 = ((tsaux1.^2)/(gamad*Rd)) - 273.15;
aux1v   = licor(:,6);  % voltage for c (sped of sound) in volts

%%% Plot wind speed
figure(1)
plot(ux,'b')
hold on
plot(uy,'r')
hold on 
plot(uz,'g')
%set(gca,'box','on','ylim',[-10 10],'FontSize',10);
%set(gca,'box','on','xlim',[1 36000],'FontSize',10);
xlabel('time (Hz)','FontSize',10)
ylabel('Windspeed (m s^{-1})','FontSize',10)
aa = legend('Ux','Uy','Uz');
set(aa,'Vis','off','FontSize',10);


%%% Plot temperatures
figure(2)
plot(ts,'b')
hold on
plot(ttc,'r')
hold on
plot(tirga,'g')
hold on
plot(tsaux1,'c')
%set(gca,'box','on','ylim',[10 30],'FontSize',10);
%set(gca,'box','on','xlim',[1 36000],'FontSize',10);
xlabel('time (Hz)','FontSize',10)
ylabel('Temperature (^{o}C)','FontSize',10)
aa = legend('T_{sonic}','T_{fwtc}','T_{irga}','T{aux1}');
set(aa,'Vis','off','FontSize',10);

%%% Plot CO2 and H2O concentration
figure(3)
plot(dco2)
%set(gca,'box','on','ylim',[300 500],'FontSize',10);
%set(gca,'box','on','xlim',[1 36000],'FontSize',10);
xlabel('time (Hz)','FontSize',10)
ylabel('Diff CO2 (umol mol^{-1})','FontSize',10)

figure(4)
plot(dh2o)
%set(gca,'box','on','ylim',[1 12],'FontSize',10);
%set(gca,'box','on','xlim',[1 36000],'FontSize',10);
xlabel('Time (Hz)','FontSize',10)
ylabel('Diff H2O (mmol mol^{-1})','FontSize',10)

%%% plot sample cell pressure
figure(5)
plot(press)
xlabel('time (Hz)','FontSize',10)
ylabel('Sample Cell Pressure (kPa)','FontSize',10)

%%% plot sonic temp from aux1 in deg C and aux1 voltage 
figure(6)
plot(tsaux1)
%set(gca,'box','on','ylim',[10 30],'FontSize',10);
%set(gca,'box','on','xlim',[1 36000],'FontSize',10);
xlabel('time (Hz)','FontSize',10)
ylabel('T_{sonic} aux1 (deg C)','FontSize',10)

figure(7)
plot(aux1v)
%set(gca,'box','on','ylim',[-1 2],'FontSize',10);
%set(gca,'box','on','xlim',[1 36000],'FontSize',10);
xlabel('time (Hz)','FontSize',10)
ylabel('T_{sonic} aux1v (volt)','FontSize',10)