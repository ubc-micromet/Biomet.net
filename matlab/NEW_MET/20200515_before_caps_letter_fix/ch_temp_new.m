%(c) DGG 2003.07.27 (from previous program ch_temp)

% --- get data ---
%fname = 'D:\david_data\files_AC\SOBS_newsystem\CH_23x_2.dat';
fname = 'D:\david_data\files_AC\SOBS_newsystem\030807_CH_23X_2.DAT';
data_23x_5s = textread(fname,'%f','delimiter',',');
data_23x_5s = reshape(data_23x_5s,43,length(data_23x_5s)/43)';
%data_23x_5s = reshape(data_23x_5s,42,length(data_23x_5s)/42)';

%fname = 'D:\david_data\files_AC\SOBS_newsystem\CH_23x_1.dat';
fname = 'D:\david_data\files_AC\SOBS_newsystem\030807_CH_23X_1.DAT';
data_23x_30m = textread(fname,'%f','delimiter',',');
data_23x_30m = reshape(data_23x_30m,124,length(data_23x_30m)/124)';
%data_23x_30m = reshape(data_23x_30m,120,length(data_23x_30m)/120)';

% --- create time vectors ---
hour = floor(data_23x_5s(:,4) / 100);										
minutes = data_23x_5s(:,4) - hour * 100;				
month = ones(size(data_23x_5s(:,2))); 
   
Time_vector23x_5s = datenum(data_23x_5s(:,2),...
                         	 month,...
                      		 data_23x_5s(:,3),...
                      	    hour,...
                      		 minutes,...
                      		 data_23x_5s(:,5));
                          
hour = floor(data_23x_30m(:,4) / 100);										
minutes = data_23x_30m(:,4) - hour * 100;				
month = ones(size(data_23x_30m(:,2))); 
                                                    
Time_vector23x_30m = datenum(data_23x_30m(:,2),...
								     month,...
								     data_23x_30m(:,3),...
								     hour,...
								     minutes,...
								     data_23x_30m(:,5));

%co2 mV 
figure(1);
plot(Time_vector23x_5s,data_23x_5s(:,16));
hold on;
plot(Time_vector23x_5s,data_23x_5s(:,6)+2000,'r');
hold off;
datetick('x',15);
xlabel(datestr(Time_vector23x_5s(end),1));
title('CO2 linearized (mV)');
zoom on;

%co2 ppm
co2_ppm = data_23x_5s(:,16) .* 0.2; %linearized signal, see datalogger program for details 

figure(2);
plot(Time_vector23x_5s,co2_ppm);
hold on;
plot(Time_vector23x_5s,data_23x_5s(:,6)+400,'r');
hold off;
datetick('x',13);
xlabel(datestr(Time_vector23x_5s(end),1));
title('CO2 linearized (ppm)');
zoom on;

%Licor bench temp mV + C
figure(3);
plot(Time_vector23x_5s,data_23x_5s(:,13));
datetick('x',13);
xlabel(datestr(Time_vector23x_5s(end),1));
title('Tbench (mV)');
zoom on;

Tbench_C = data_23x_5s(:,13) .* 0.01221;

figure(4);
plot(Time_vector23x_5s,Tbench_C);
datetick('x',13);
xlabel(datestr(Time_vector23x_5s(end),1));
title('Tbench (C)');
zoom on;

%Licor pressure mV + kPa
figure(5);
plot(Time_vector23x_5s,data_23x_5s(:,14));
hold on;
plot(Time_vector23x_5s,data_23x_5s(:,6)+1100,'r');
hold off;
datetick('x',13);
xlabel(datestr(Time_vector23x_5s(end),1));
title('PLicor (mV)');
zoom on;

Pli_kPa = data_23x_5s(:,14) .* 0.01532;
Pli_kPa = Pli_kPa + 58.650;

figure(6);
plot(Time_vector23x_5s,Pli_kPa);
hold on;
plot(Time_vector23x_5s,data_23x_5s(:,6)+70,'r');
hold off;
datetick('x',13);
xlabel(datestr(Time_vector23x_5s(end),1));
title('PLicor (kPa)');
zoom on;

%Battery voltage
figure(7);
plot(Time_vector23x_30m,data_23x_30m(:,[5,8,11]));
datetick('x',13);
xlabel(datestr(Time_vector23x_30m(end),1));
title('Battery voltage (V)');
legend('mean','max','min')
zoom on;

%Control TCH temp 
figure(8);
plot(Time_vector23x_30m,data_23x_30m(:,[6,9,12]));
datetick('x',13);
xlabel(datestr(Time_vector23x_30m(end),1));
title('Control TCH temperature (C)');
legend('mean','max','min')
zoom on;

%Pump TCH temp 
figure(9);
plot(Time_vector23x_30m,data_23x_30m(:,[7,10,13]));
datetick('x',13);
xlabel(datestr(Time_vector23x_30m(end),1));
title('Pump TCH temperature (C)');
legend('mean','max','min')
zoom on;

