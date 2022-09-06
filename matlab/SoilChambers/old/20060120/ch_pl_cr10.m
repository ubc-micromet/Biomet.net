function ch_pl_cr10(timeSer,dataIn,Month,flagDOY)

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
plot(newTime,dataIn(:,[6]))
grid on
zoom on
ylabel('Microswitch 1')
xlabel(Xlabel)
set(fig,'name','Microswitch 1(cr10 output array element 6)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[7]))
grid on
zoom on
ylabel('Microswitch 2')
xlabel(Xlabel)
set(fig,'name','Microswitch 2(cr10 output array element 7)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[8]))
grid on
zoom on
ylabel('MFC on')
xlabel(Xlabel)
set(fig,'name','MFC on (cr10 output array element 8)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[9]))
grid on
zoom on
ylabel('Panel Temperature (deg C)')
xlabel(Xlabel)
set(fig,'name','Panel Temperature (cr10 output array element 9)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[10]), newTime,dataIn(:,[11]), newTime,dataIn(:,[12]), ...
    newTime,dataIn(:,[13]));
grid on
zoom on
ylabel('T Soil (deg C)')
xlabel(Xlabel)
legend('CH1 2 in (tc1)', 'CH1 2 out (tc2)', 'CH1 m/o (tc3)', 'CH1 20 (tc4)') 
set(fig,'name','TSoil 1 (cr10 output array elements 10 to 13)', ...
        'numbertitle','off')

fig = fig+1;
figure(fig);
plot(newTime,dataIn(:,[14]), newTime,dataIn(:,[15]), newTime,dataIn(:,[16]), ...
    newTime,dataIn(:,[17]));
grid on
zoom on
ylabel('T Soil (deg C)')
xlabel(Xlabel)
legend('CH2 2 in (tc5)', 'CH2 2 out (tc6)', 'CH2 m/o (tc7)', 'CH2 20 (tc8)')
set(fig,'name','TSoil 2 (cr10 output array elements 14 to 17)', ...
        'numbertitle','off')



h=get(0,'children');
h=sort(h);
for i=min(h):max(h)
    figure(h(i))
    pause
end