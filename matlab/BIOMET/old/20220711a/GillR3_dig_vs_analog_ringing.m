
% File to compare R3 RS232 outputs with analog outs
% Data collected at PAOA site Aug 24, 2000
% CD PAOA_166
% 
% by Zoran Nesic

% load RS232 data
RS232 = load ('c:\sites\paoa\00082474.dat');

% extract temperature
tRS232 = RS232(:,4);
N_tRS232 = length(tRS232);

% load analog data (DAQbook file)
[RawData_DAQ,TotalSamples,SamplesRead]  =  FR_read_raw_data('e:\met-data\data\000824\00082474.dp2',20,50000);
tDAQ = RawData_DAQ(10,:)'*5000/2^15*60/2500;                % conversion to degC
N_tDAQ = length(tDAQ);

% extract the overlapping time period
k=30907;                                                    % time offset between the signals

tDAQ1 = tDAQ(k+[1:N_tRS232]);

% Signals are sampled at different rates (hence the difference in the plots)
% resample the tRS232 from 20Hz to 20.833Hz  (ratio 120:125)
tRS232r=resample(tRS232,125,120);
ind1=[1:length(tDAQ1)];                  % index and adjust for the time shift
figure(1)
plot(ind1,tRS232r(ind1),ind1+70,tDAQ1)      % plot frequency and delay adjusted signals
ylabel('Deg C')
xlabel('samples at 20Hz')
h=legend('RS232','Analog');
set(h,'visible','off')
zoom on
ax=axis;axis([500 1150 25.1 25.7])
print -djpeg90 c:\sites\paoa\temp_comp


% resample the tDAQ1 from 20.833Hz to 20Hz  (ratio 125:120)
% just to make sure resampling does not produce different results
tDAQ1r=resample(tDAQ1,120,125);
ind1=[1:length(tDAQ1r)];                           % index and adjust for the time shift
figure(2)
plot(ind1-67,tRS232(ind1),ind1,tDAQ1r(ind1))      % plot frequency and delay adjusted signals
ylabel('Deg C')
xlabel('samples at 20Hz')
h=legend('RS232','Analog');
set(h,'visible','off')
zoom on

% show that wind components don't have spikes (temp. only)
% extract w
wRS232 = RS232(:,3);
N_wRS232 = length(wRS232);

wDAQ = RawData_DAQ(9,:)'*5000/2^15*30/2500;                % conversion to m/s
N_wDAQ = length(wDAQ);

% extract the overlapping time period
wDAQ1 = wDAQ(k+[1:N_wRS232]);

% Signals are sampled at different rates (hence the difference in the plots)
% resample the wRS232 from 20Hz to 20.833Hz  (ratio 120:125)
wRS232r=resample(wRS232,125,120);
ind1=[1:length(wDAQ1)];                  % index and adjust for the time shift
figure(3)
plot(ind1,wRS232r(ind1),ind1+69,wDAQ1)      % plot frequency and delay adjusted signals
ylabel('m/s')
title('W')
xlabel('samples at 20Hz')
h=legend('RS232','Analog');
set(h,'visible','off')
zoom on
ax=axis;axis([500 1150 -0.3 2.1])
print -djpeg90 c:\sites\paoa\w_comp