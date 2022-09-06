function pl_BranchChamber(startDate)
% dgg, November 18 2005

%clear all;
close all;

%set parameters
data_HF = [];
loggerName = 'YF_ACS2';
NbrChannels = 52;
ID = 101;

%set paths
[pthIn, pthOut] = fr_get_local_path;

%define file name
fileNameDate = FR_DateToFileName(startDate+0.2);        
fileNameDate = fileNameDate(1:6);                          
filename = ([fileNameDate '\' fileNameDate '_' loggerName '.dat']);        
fname = fullfile(pthIn, filename);

%load HF data
data_HF = ach_load_file(fileNameDate,loggerName,pthIn,NbrChannels,ID);

[co2_ppm,h2o_mmol,temperature,pressure] = fr_licor_calc(740, [], ...
                                          data_HF(:,11),data_HF(:,12), ...
                                          data_HF(:,13),data_HF(:,14),...
                                          [1 0],[1 0]);
 
%create time vector for HF data (5 seconds)
hour = floor(data_HF(:,4) / 100);										
minutes = data_HF(:,4) - hour*100;				
month = ones(size(data_HF(:,2))); 
  
tv = datenum(data_HF(:,2),...
             month,...
             data_HF(:,3),...
             hour,...
             minutes,...
             data_HF(:,5));

GMTShift = 8/24;         
tv = tv - GMTShift;         

%plot HF data         
figure(1);
subplot(2,1,1)
plot(tv,data_HF(:,28),'r'); %Ta inside
hold on;
plot(tv,data_HF(:,29),'b'); %Ta outside
h = legend('T_a inside','T_a outside',2);
%legend boxoff;
set(h,'Box','Off','Visible','Off');
axis([tv(1) tv(end) min(data_HF(:,28)-1) max(data_HF(:,28)+1)]);
datetick('x',15);
set(gca,'XTickLabel','');
title(datestr(startDate));
ylabel('T_a (^oC)');
hold off;

subplot(2,1,2)
plot(tv,data_HF(:,44),'c'); %par inside
axis([tv(1) tv(end) 0 max(data_HF(:,44))+100]);
datetick('x',15);
ylabel('PAR (\mumol m^{-2} s^{-1})');

zoom_together(figure(1),'x','on');

max_win = [1 34 1024 657];
set(gcf,'Position',max_win);

figure(2);
subplot(3,1,1)
plot(tv,data_HF(:,28),'r'); %Ta inside
hold on;
plot(tv,data_HF(:,29),'b'); %Ta outside
h = legend('T_a inside','T_a outside',2);
%legend boxoff;
set(h,'Box','Off','Visible','Off');
axis([tv(1) tv(end) min(data_HF(:,28)-1) max(data_HF(:,28)+1)]);
datetick('x',15);
set(gca,'XTickLabel','');
title(datestr(startDate));
ylabel('T_a (^oC)');
hold off;

subplot(3,1,2)
plot(tv,co2_ppm,'b');
axis([tv(1) tv(end) 0 max(co2_ppm)+100]);
datetick('x',15);
ylabel('CO2 (\mumol mol^{-1})');

subplot(3,1,3)
plot(tv,h2o_mmol,'b');
axis([tv(1) tv(end) 0 max(h2o_mmol)+10]);
datetick('x',15);
ylabel('H2O (mmol mol^{-1})');

zoom_together(figure(2),'x','on');

max_win = [1 34 1024 657];
set(gcf,'Position',max_win);

%load and plot hourly data
tv3 = read_bor('\\Annex001\DATABASE\2005\Yf\Chambers\dcdt_long_tv',8);
dcdt = read_bor('\\Annex001\DATABASE\2005\Yf\Chambers\dcdt_long.7',1);
efflux = read_bor('\\Annex001\DATABASE\2005\Yf\Chambers\efflux_long.7',1);
wv = read_bor('\\Annex001\DATABASE\2005\Yf\Chambers\wv_long.7',1);
ev = read_bor('\\Annex001\DATABASE\2005\Yf\Chambers\ev_long.7',1);
par = read_bor('\\Annex001\DATABASE\2005\Yf\Chambers\parBC.1',1);
TaIns = read_bor('\\Annex001\DATABASE\2005\Yf\Chambers\Ta_insBC.1',1);
TaOut = read_bor('\\Annex001\DATABASE\2005\Yf\Chambers\Ta_outBC.1',1);

tv3 = tv3 - GMTShift;
doy = convert_tv(tv3,'doy');

figure(3);
subplot(3,1,1);
plot(doy(1:2:end-1),dcdt(1:2:end-1));
axis([doy(10500) doy(14400) -1.5 0.5]);
ylabel('dcdt (\mumol m^{-2} s^{-1})');

subplot(3,1,2);
plot(doy(1:2:end-1),par(1:2:end-1));
axis([doy(10500) doy(14400) 0 1500]);
ylabel('PAR (\mumol m^{-2} s^{-1})');

subplot(3,1,3);
plot(doy(1:2:end-1),TaIns(1:2:end-1),'r');
hold on;
plot(doy(1:2:end-1),TaOut(1:2:end-1),'b');
hold off;
h = legend('T_a inside','T_a outside');
%legend boxoff;
set(h,'Box','Off','Visible','Off');
axis([doy(10500) doy(14400) 0 40]);
ylabel('^oC');

max_win = [1 34 1024 657];
set(gcf,'Position',max_win);

zoom_together(figure(3),'x','on');

%some analysis...
%indOut = find(doy >= 220 & doy <= 300);
%dcdtTmp = dcdt(indOut);
%parTmp  = par(indOut);

Fc = read_bor('\\Annex001\DATABASE\2005\Yf\Clean\ThirdSTage\eco_photosynthesis_measured',1);

figure(4);
%subplot(3,1,1);
plot(doy(1:2:end-1),efflux(1:2:end-1));
hold on;
plot(doy(1:2:end-1),-Fc(1:2:end-1),'r');
hold off;
axis([doy(12820) doy(12980) -15 1]);
h = legend('Chamber','Eddy',3);
%legend boxoff;
set(h,'Box','Off','Visible','Off');
ylabel('\mumol m^{-2} s^{-1})');
max_win = [1 34 1024 657];
set(gcf,'Position',max_win);

