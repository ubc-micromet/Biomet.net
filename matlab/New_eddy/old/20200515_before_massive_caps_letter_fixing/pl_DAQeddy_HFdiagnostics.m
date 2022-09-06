function pl_DAQeddy_HFdiagnostics(SiteFlag,startDate,endDate,channels,ind_xcorr);

% plots raw HF traces, xcorr, covariance and cumulative covariance for a 
% user specified channels (DAQ system only: as of April 9, 2010, CR, PA,
% BS)

currentDate     = startDate;
fr_set_site(SiteFlag,'n');
hhours          = floor( (endDate - startDate) * 48 + 1/480 ) + 1;
for i = 1:hhours
    [Stats,EngUnits_DAQ] = fr_calc_main(SiteFlag,currentDate,currentDate,1);
    c                    = fr_get_init(SiteFlag,currentDate);
    if isempty(ind_xcorr)
        ind_xcorr1 = 1:c.Delays.ArrayLengths(1);
        ind_xcorr2 = 1:c.Delays.ArrayLengths(2);
    else
        ind_xcorr1 = ind_xcorr;
        ind_xcorr2 = ind_xcorr;
    end
    a = detrend(EngUnits_DAQ(channels(1),ind_xcorr1));
    b = detrend(EngUnits_DAQ(channels(2),ind_xcorr2));
    [xc,lags] = xcorr(a,b);
    figure(1);
    plot(EngUnits_DAQ(channels(1),:)');
    title(['DAQ channel ' num2str(channels(1)) ', ' num2str(datestr(currentDate))]);
    zoom on; pause;
    figure(2);
    plot(EngUnits_DAQ(channels(2),:)');
    title(['DAQ channel ' num2str(channels(2)) ', ' num2str(datestr(currentDate))]);
    zoom on; pause;
    figure(3);plot(1:length(a),[a' b']);
    title(['Detrended DAQ Channels ' num2str(channels) ', ' num2str(datestr(currentDate))]);
    zoom on; pause;
    figure(4);
    plot(lags,xc);
    title(['XCorr DAQ channels ' num2str(channels(1)) ' and ' num2str(channels(2)) ...
        ' ' num2str(datestr(currentDate))]);
    zoom on; pause;
    covManual_old = (a-mean(a)).*(b-mean(b))/length(b);
    cov_sum = cumsum(covManual_old);
    cov_old = cov(a,b);
    figure(5);plot(1:length(covManual_old),covManual_old);
    title(['Cov channels ' num2str(channels) ', ' num2str(datestr(currentDate))]);
    zoom on; pause;
    figure(6);plot(1:length(cov_sum),cov_sum);
    title(['Cumulative Cov channels ' num2str(channels) ', ' num2str(datestr(currentDate))]);
    zoom on; pause;
    currentDate     = FR_nextHHour(currentDate);
end %