function xsite_plt(dateIn)

arg_default('dateIn',now-1/48);

fNamePre = fr_datetofilename(dateIn+1/48);
       
% fPath = 'd:\met-data\data\';
fPath = fr_get_local_path;

if exist(fullfile(fPath,fNamePre(1:6)),'dir')
    % if data moved to the daily folder change path
    fPath = [fPath fNamePre(1:6) '\'];
end

LI7000=fr_read_digital2_file(fullfile(fPath,[fNamePre '.dx8']));
LI7500=fr_read_digital2_file(fullfile(fPath,[fNamePre '.dx4']));
GillR3=fr_read_raw_data(fullfile(fPath,[fNamePre '.dx5']),5).'/100;
GillR3(:,4)=GillR3(:,4)-273.15;
tGillR3=[1:length(GillR3)]/20;
tLI7000=[1:length(LI7000)]/20.345;
tLI7500=[1:length(LI7500)]/20;

disp(sprintf('File name: %s    Num. of Points  R3 = %d  CP = %d OP = %d',fNamePre,length(GillR3),length(LI7000),length(LI7500)));
disp(sprintf('Diagnostic Flag Averages: R3m = %3.1f  CP = %3.1f OP = %3.1f',mean(GillR3(:,5)),mean(LI7000(:,6)),mean(LI7500(:,6))));

figure(1)
set(gcf,'name','GillR3')
subplot(4,1,1)
plot(tGillR3,GillR3(:,1:2))
ylabel('u and v (m/s)')
title(['Gill R3 (@ ' fNamePre ')'])

subplot(4,1,2)
plot(tGillR3,mean(((GillR3(:,1:3).^2)').^0.5))
ylabel('Cup (m/s)')

subplot(4,1,3)
plot(tGillR3,GillR3(:,3))
ylabel('w (m/s)')

subplot(4,1,4)
plot(tGillR3,GillR3(:,4))
ylabel('T (\circC)')
xlabel('Time (s)')

zoom_together(1,'x','on')

fig = 2;
figure(fig)
set(fig,'name','LI-7500')
subplot(5,1,1)
plot(tLI7500,LI7500(:,1))
ylabel('CO_2 (mmol/m^3)')
title(['LI-7500 (@ ' fNamePre ')'])

subplot(5,1,2)
plot(tLI7500,LI7500(:,2))
ylabel('H_2O (mmol/m^3)')

subplot(5,1,3)
plot(tLI7500,LI7500(:,3))
ylabel('Aux (mV)')

subplot(5,1,4)
plot(tLI7500,LI7500(:,5))
ylabel('Pair (kPa)')

subplot(5,1,5)
plot(tLI7500,LI7500(:,6))
ylabel('Diag')
xlabel('Time (s)')

zoom_together(fig,'x','on')

fig = 3;
figure(fig)
set(fig,'name','LI-7000')
subplot(4,1,1)
plot(tLI7000,LI7000(:,1))
ylabel('CO_2 (ppm)')
title(['LI-7000 (@ ' fNamePre ')'])

subplot(4,1,2)
plot(tLI7000,LI7000(:,2))
ylabel('H_2O (mmol/mol)')

subplot(4,1,3)
plot(tLI7000,LI7000(:,3))
ylabel('Tbench (\circC)')

subplot(4,1,4)
plot(tLI7000,LI7000(:,4))
ylabel('Plicor (kPa)')
xlabel('Time (s)')

zoom_together(fig,'x','on')

return
