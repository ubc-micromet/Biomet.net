%% WL sapflow flux variable voltage correction
% Testing
% 
load('D:\NZ\Flux_Projects\FeeForService\Wilfrid.Laurier\data\sapflow\OBS_sap_exmpl_data_set.mat');
% remove mostly NaNs
nanStart = 1420;
GMT_offset = 7/24;
minutesIn_SMC = minutesIn_SMC(nanStart:end,:)-GMT_offset;
SF_SMC        = SF_SMC(nanStart:end,:);
v_SMC        = v_SMC(nanStart:end,:);
fig=0;
%% plot all data
fig=fig+1;
figure(fig)
clf
hAX(1) = subplot(2,1,1);
plot(minutesIn_SMC,SF_SMC); grid on;
title('SF')
ylabel('mV')
legend
hAX(2) = subplot(2,1,2);
plot(minutesIn_SMC,v_SMC,'o-'); grid on;
linkaxes(hAX,'x')
title('Voltage')
ylabel('V')

% plot one trace
traceNum = 9;
fig=fig+1;
figure(fig)
clf
hAX1(1) = subplot(2,1,1);
plot(minutesIn_SMC,SF_SMC(:,traceNum)); grid on;
title('SF')
ylabel('mV')
legend
hAX1(2) = subplot(2,1,2);
plot(minutesIn_SMC,v_SMC,'o-'); grid on;
%linkaxes(hAX1,'x')
title('Voltage')
ylabel('V')

% Find the time when the solar charger switches from full charge to float (~13.6 to ~13.3V)
% and use that to calculate delta_SF_mv = gain * battV
ind = find((minutesIn_SMC+GMT_offset)>=172.8383 & (minutesIn_SMC+GMT_offset)<=172.8471);
fig=fig+1;
figure(fig)
clf
hAX2(1) = subplot(2,1,1);
plot(minutesIn_SMC(ind),SF_SMC(ind,traceNum)); grid on;
title(sprintf('SF trace %d',traceNum))
ylabel('mV')

hAX2(2) = subplot(2,1,2);
plot(minutesIn_SMC(ind),v_SMC(ind),'o-'); grid on;
linkaxes(hAX2,'x')
title('Voltage')
ylabel('V')


% 1:1 plot for the above period (widen the range by extraPoints)
extraPoints = 100;
indNew = ind(1)-extraPoints:ind(end)+extraPoints*5;
fig=fig+1;
figure(fig)
clf
plot(v_SMC(indNew),SF_SMC(indNew,traceNum),'o'); grid on;
title(sprintf('SF trace %d',traceNum))
ylabel('mV')

zoom on

%%
% get the gain from the plot
% Trace = 10 =>gain = (0.9503-0.9213)/(13.58-13.29)*1;
% Trace = 8 =>gain = (0.5457-0.5217)/(13.58-13.29)*1;
% Trace = 1 =>gain = (0.6902-0.6611)/(13.58-13.29)*1;
% Trace = 2 =>gain = (0.7921-0.7622)/(13.58-13.29)*1;
% Trace = 3 =>gain = (0.6442-0.6173)/(13.58-13.29)*1;
% Trace = 9 =>gain(9) = (0.6681-0.6349)/(13.58-13.29)*0.8;
gain(traceNum) = (0.6681-0.6413)/(13.58-13.29)*0.8;
delay_samples = 1;      % SF lags voltage change. Account for the delay (which I eyeballed)
% Correct only the voltage transition period and plot the correction
SF_trace_corrected = SF_SMC(ind,traceNum) - (v_SMC(ind-delay_samples)-13.58)*gain(traceNum);
fig=fig+1;
figure(fig)
clf
plot(minutesIn_SMC(ind),SF_SMC(ind,traceNum),minutesIn_SMC(ind),SF_trace_corrected); grid on;
%axCorrected1 = gca;
title(sprintf('SF trace %d',traceNum))
ylabel('mV')
zoom on;
legend('Original','Corrected')

%%
% plot the entire trace
SF_trace_corrected = SF_SMC(:,traceNum) -  ([v_SMC(1:delay_samples); v_SMC(1:end-delay_samples)]-13.58)*gain(traceNum);
fig=fig+1;
figure(fig)
clf
plot(minutesIn_SMC,SF_SMC(:,traceNum),minutesIn_SMC,SF_trace_corrected); grid on;
axFig(1) = gca;
title(sprintf('SF trace %d',traceNum))
ylabel('mV')
zoom on;
legend('Original','Corrected')


%%
% plot the entire trace (filtered)
filterA = fir1(20,0.99);
SF_trace_corrected_filtered = filtfilt(filterA,1,SF_SMC(:,traceNum)) -  filtfilt(filterA,1,([v_SMC(1:delay_samples); v_SMC(1:end-delay_samples)]-13.58)*gain(traceNum));
SF_trace_corrected = SF_SMC(:,traceNum) -  ([v_SMC(1:delay_samples); v_SMC(1:end-delay_samples)]-13.58)*gain(traceNum);
fig=fig+1;
figure(fig)
clf
plot(minutesIn_SMC,SF_SMC(:,traceNum),minutesIn_SMC,SF_trace_corrected); grid on;
axFig(2) = gca;
title(sprintf('SF trace %d (filtered)',traceNum))
ylabel('mV')
zoom on;
legend('Original','Corrected')
%%
% Plot voltage and link with traces
fig=fig+1;
figure(fig)
clf
plot(minutesIn_SMC,v_SMC,'o-'); grid on;

title('Voltage')
ylabel('V')
axFig(3) = gca;
%linkaxes(axFig,'x')


%%
% plot all traces assuming the same gain
SF_trace_corrected = SF_SMC -  ([v_SMC(1:delay_samples); v_SMC(1:end-delay_samples)]-13.58)*gain(traceNum);
fig=fig+1;
figure(fig)
clf
hAX4(1) = subplot(2,1,1);
plot(minutesIn_SMC,SF_SMC); grid on;
ylabel('mV')
title('Original')
hAX4(2) = subplot(2,1,2);
plot(minutesIn_SMC,SF_trace_corrected); grid on;
title('Corrected')
%linkaxes(hAX4,'x')
ylabel('mV')
zoom on;

linkaxes([hAX hAX1 axFig hAX4],'x')



