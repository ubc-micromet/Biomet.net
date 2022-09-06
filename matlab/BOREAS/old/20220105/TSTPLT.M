function x = tstplt(FileName,NumOfChannels,MaxNumOfSamplesToPlot)
%NumOfChannels = 9;
%MaxNumOfSamplesToPlot = 1500;
Yaxis = [-1.5 1.5];
tic
c = sprintf('fid = fopen(%s%s%s,%sr%s);',39,FileName,39,39,39);
eval(c);
%fid = fopen('c:\nz\junk.out','r');
if fid < 3
    return
end
status = fseek(fid,0,'eof');
TotalSamples  = ftell(fid)/2/NumOfChannels;
NN = min(MaxNumOfSamplesToPlot,TotalSamples);
status = fseek(fid,-NN*NumOfChannels*2,'eof');
x = fread(fid,[NumOfChannels,NN],'int16');
fclose(fid);

nn=1+TotalSamples-NN:TotalSamples;
figure(1)
if isempty(get(1,'children'))
    set(1,'menubar','none',...
        'numbertitle','off',...
        'name','Gill R2 Output')
    zoom on
    xlabel('Time(s)')
end
%plot(nn /20.83,x(1:3,:)'./100)
%hold on
plot(nn /20.83,x(5,:))
%hold off
grid on
ax=axis;
%axis([ax(1:2) Yaxis])
title('Wind components: u (blue), v (green), w (red)')
xlabel('Seconds from the beginning of current half hour')
ylabel('m/s')
fprintf('Elapsed time: %f (s)\n %s\n',toc,datestr(now))
