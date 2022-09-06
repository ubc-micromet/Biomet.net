function ch_pl_21x(timeSer,dataIn,Month,flagDOY)

if exist('flagDOY')~= 1
    flagDOY = 0;
end
if exist('Month') ~= 1
    Month = 1;
    flagDOY = 0;
end

switch flagDOY
    case 0, timeOffset = datenum(1998,1,1)-1;newTime = timeSer - timeOffset;Xlabel = 'DOY';
    case 1, timeOffset = datenum(1998,Month,1)-1;newTime = timeSer - timeOffset;Xlabel = ['Day of month #' num2str(Month)];
    case 2, timeOffset = datenum(1998,Month,1)-1;newTime = timeSer - timeOffset;newTime = newTime * 24 * 60;Xlabel = ['Minutes of month #' num2str(Month)];
end


fig = 0;


fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,10))
grid on
zoom on
ylabel('Optical bench temperature (degC)')
xlabel(Xlabel)
set(fig,'name','Tbench (21x output array element 10)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[8]))
grid on
zoom on
ylabel('CO2 (mV)')
xlabel(Xlabel)
set(fig,'name','CO2 mV (21x output array element 8)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[9]))
grid on
zoom on
ylabel('H2O (mV)')
xlabel(Xlabel)
set(fig,'name','H2O mV (21x output array element 9)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[6]))
grid on
zoom on
ylabel('MFC FlowB (cc min-1)')
xlabel(Xlabel)
set(fig,'name','MFC FlowB (21x output array element 6)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[7]))
grid on
zoom on
ylabel('MFC Volt B (mV)')
xlabel(Xlabel)
set(fig,'name','MFC Volt B (21x output array element 7)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[11]))
grid on
zoom on
ylabel('P Bench (kPa)')
xlabel(Xlabel)
set(fig,'name','Pressure Bench (21x output array element 11)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[21]))
grid on
zoom on
ylabel('CO2 (umol mol-1)')
xlabel(Xlabel)
set(fig,'name','CO2 umol mol-1 (21x output array element 21)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[12]))
grid on
zoom on
ylabel('Panel temperature (deg C)')
xlabel(Xlabel)
set(fig,'name','Panel Temperature (21x output array element 12)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[13]))
grid on
zoom on
ylabel('Ch1 Tair in (deg C)')
xlabel(Xlabel)
set(fig,'name','Ch 1 Tair in (21x output array element 13)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[16]))
grid on
zoom on
ylabel('Ch2 Tair in (deg C)')
xlabel(Xlabel)
set(fig,'name','Ch 2 Tair in (21x output array element 16)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[19]))
grid on
zoom on
ylabel('Status ')
xlabel(Xlabel)
set(fig,'name','Status (21x output array element 19)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[20]))
grid on
zoom on
ylabel('Cal Flag')
xlabel(Xlabel)
set(fig,'name','Cal Flag (21x output array element 20)', ...
        'numbertitle','off')

h=get(0,'children');
h=sort(h);
for i=min(h):max(h)
    figure(h(i))
    pause
end