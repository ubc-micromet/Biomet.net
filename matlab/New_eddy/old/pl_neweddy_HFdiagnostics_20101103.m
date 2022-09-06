function pl_neweddy_HFdiagnostics(siteId,startDate,endDate,instrchan,syschan,nMainEddy,ind_xcorr);

% new eddy instrument channels: sonic
% 1 u
% 2 v
% 3 w
% 4 Ts
% 5 diag

% new eddy instrument channels: IRGA_cp
% 1 'co2'     
% 2 'h2o' 
% 3 'Tbench'
% 4 'Plicor'
% 5 'Aux' (should be sonic w)
% 6 'Diag'
 
% possible system channels
% 1 u
% 2 v
% 3 w
% 4 T
% 5 co2
% 6 h2o

arg_default('instrchan',[ 3 1 ]);
arg_default('syschan',[ 3 5 ]); % w and co2 in EngUnits

fr_set_site(siteId,'n');

viewHhour     = startDate;

hhours          = floor( (endDate - startDate) * 48 + 1/480 ) + 1;

for i=1:length(hhours)
    [Stats_New,HF_Data] = yf_calc_module_main(viewHhour,siteId,2);

    c = fr_get_init(siteId,viewHhour);
    
    %nMainEddy = 1;
    instrum = c.System(nMainEddy).Instrument;
    [xc_old,lags] = xcorr(HF_Data.System(1).EngUnits(ind_xcorr,syschan(1)),HF_Data.System(1).EngUnits(ind_xcorr,syschan(2)));

    a = detrend(HF_Data.System(1).EngUnits(ind_xcorr,syschan(1)));
    b = detrend(HF_Data.System(1).EngUnits(ind_xcorr,syschan(2)));

    [xc_old,lags] = xcorr(a,b);
    covManual_old = (a-mean(a)).*(b-mean(b))/length(b);
    cov_sum = cumsum(covManual_old);
    cov_old = cov(a,b);
    
    % plot raw HF traces (Instrument) first
    figure(1); plot(HF_Data.Instrument(instrum(1)).EngUnits(:,instrchan(1)));
    title(['NewEddy Instrument ' num2str(instrum(1)) ' channel ' num2str(instrchan(1))]);
    zoom on; pause;
    figure(2); plot(HF_Data.Instrument(instrum(2)).EngUnits(:,instrchan(2)));
    title(['NewEddy Instrument ' num2str(instrum(2)) ' channel ' num2str(instrchan(2))]);
    zoom on; pause;
    figure(3);plot(1:length(a),[a b]);
    title(['New eddy system # ' num2str(nMainEddy) ' detrended channels ' num2str(syschan) ', ' num2str(datestr(viewHhour(i)))]);
    zoom on; pause;
    figure(4);plot(lags,xc_old); 
    title(['XCorr channels ' num2str(syschan) ', ' num2str(datestr(viewHhour(i)))]);
    zoom on; pause;
    figure(5);
    plot(1:length(covManual_old),covManual_old);
    title(['Cov channels ' num2str(syschan) ', ' num2str(datestr(viewHhour(i)))]);
    zoom on; pause;
    figure(6);
    plot(1:length(cov_sum),cov_sum);
    title(['Cumulative cov channels ' num2str(syschan) ', ' num2str(datestr(viewHhour(i)))]);
    zoom on; pause; 
    viewHhour     = FR_nextHHour(viewHhour);
end



