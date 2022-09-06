function x = plt_raw(FileName,NumOfChannels,chans,MaxNumOfSamplesToPlot,Fs,PlotRaw)

MaxNumOfSamplesToPlot = floor(MaxNumOfSamplesToPlot);
tic
if ~exist('Fs')
    Fs = 20.833;
end
if ~exist('PlotRaw')
    PlotRaw = 0;
end

[RawData,TotalSamples,NN] = read_raw(FileName,NumOfChannels,MaxNumOfSamplesToPlot);

if PlotRaw ~= 0
    [x,units] = convert2eng(RawData);
else
    x = RawData * 5000 / 2^15;
    units = str2mat('mV','mV','mV','mV','mV','mV','mV','mV','mV','mV');
    units = str2mat(units,'mV','mV','mV','mV','mV');               
end

Yaxis = [-5 5];

nn=1+TotalSamples-NN:TotalSamples;

figure(gcf)
if isempty(get(1,'children'))
    set(1,'menubar','none',...
        'numbertitle','off',...
        'name','Gill R2 Output')
    zoom on
    xlabel('Time(s)')
end

plot(nn /Fs/60,x(chans,:)')

grid on
ax=axis;
title('High frequency data')
xlabel('Minutes from the beginning of half hour')
c = ['Units: ' units(chans(1),:)];
for i = chans(2:length(chans));
    c = sprintf('%s, %s',c,units(i,:));
end
ylabel(c)
fprintf('Elapsed time: %f (s)\n %s\n',toc,datestr(now))

