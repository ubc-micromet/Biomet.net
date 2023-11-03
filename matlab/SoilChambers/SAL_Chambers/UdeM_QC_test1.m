%% QA/QC for UdeM 2019 data set

load data/all_chambers.mat
%%
chNum = 18;
fluxType = 'ch4';

tv = chamberOut.chamber(chNum).tv;
doy = tv-datenum(2019,1,0);
percent_of_points_to_keep = 0.90;
std_multiplier = 2;
%mean_multiplier = 1;
type_of_threshold = 2;     % 1- keep % of data, 2 - use mean(rmse)*mean_multiplier, 3 - median*multiplier, 
useMedFilt = false;
medFiltPoints = 2;

if strcmpi(fluxType,'co2')
    absolute_rmse_limit = 1;
    absolute_flux_limit = [-20 +20];
else
    absolute_rmse_limit = 0.001;
    absolute_flux_limit = [-20 +20]/1000;
end

rmse_exp_B = chamberOut.chamber(chNum).flux.(fluxType).exp_B.rmse;
rmse_lin_B = chamberOut.chamber(chNum).flux.(fluxType).lin_B.rmse;
dcdt_exp_B = chamberOut.chamber(chNum).flux.(fluxType).exp_B.dcdt;
dcdt_lin_B = chamberOut.chamber(chNum).flux.(fluxType).lin_B.dcdt;
flux_exp_B = chamberOut.chamber(chNum).flux.(fluxType).exp_B.flux;
flux_lin_B = chamberOut.chamber(chNum).flux.(fluxType).lin_B.flux;

nPoints = length(rmse_exp_B);

% remove all outliers
indOutlierExp_absFluxLimit = flux_exp_B < absolute_flux_limit(1)| flux_exp_B >= absolute_flux_limit(2) ;
indOutlierLin_absFluxLimit = flux_lin_B < absolute_flux_limit(1)| flux_lin_B >= absolute_flux_limit(2) ;

indOutlierExp_absRmseLimit = rmse_exp_B > absolute_rmse_limit;
indOutlierLin_absRmseLimit = rmse_lin_B > absolute_rmse_limit;

indOutlierExp_spikesRmse   = abs(rmse_exp_B - mean(rmse_exp_B(~isnan(rmse_exp_B)))) > std_multiplier*std(rmse_exp_B(~isnan(rmse_exp_B)));
indOutlierLin_spikesRmse   = abs(rmse_lin_B - mean(rmse_lin_B(~isnan(rmse_lin_B)))) > std_multiplier*std(rmse_lin_B(~isnan(rmse_lin_B)));

indOutlierExp_spikesFlux   = abs(flux_exp_B - mean(flux_exp_B(~isnan(rmse_exp_B)))) > std_multiplier*std(flux_exp_B(~isnan(flux_exp_B)));
indOutlierLin_spikesFlux   = abs(flux_lin_B - mean(flux_lin_B(~isnan(rmse_lin_B)))) > std_multiplier*std(flux_lin_B(~isnan(flux_lin_B)));

indOutlierExp_FluxNans     = isnan(flux_exp_B);
indOutlierLin_FluxNans     = isnan(flux_lin_B);

indOutlierExp = indOutlierExp_absFluxLimit ...
             |  indOutlierExp_absRmseLimit...
             |  indOutlierExp_spikesRmse...
             |  indOutlierExp_spikesFlux...
             |  indOutlierExp_FluxNans;

indOutlierLin = indOutlierLin_absFluxLimit ...
             |  indOutlierLin_absRmseLimit...
             |  indOutlierLin_spikesRmse...
             |  indOutlierLin_spikesFlux...
             |  indOutlierLin_FluxNans;

rmse_exp_B(indOutlierExp)  = NaN;
rmse_lin_B(indOutlierLin)  = NaN;
dcdt_exp_B(indOutlierExp)  = NaN;
dcdt_lin_B(indOutlierLin)  = NaN;
flux_exp_B(indOutlierExp)  = NaN;
flux_lin_B(indOutlierLin)  = NaN;

% Do a bit of filtering if desired
if useMedFilt
    dcdt_exp_B_filtered = medfilt1(dcdt_exp_B,medFiltPoints,'omitnan');
    dcdt_lin_B_filtered = medfilt1(dcdt_lin_B,medFiltPoints,'omitnan');
    flux_exp_B_filtered = medfilt1(flux_exp_B,medFiltPoints,'omitnan');
    flux_lin_B_filtered = medfilt1(flux_lin_B,medFiltPoints,'omitnan');
else
    dcdt_exp_B_filtered = dcdt_exp_B;
    dcdt_lin_B_filtered = dcdt_lin_B;
    flux_exp_B_filtered = flux_exp_B;
    flux_lin_B_filtered = flux_lin_B;
end    


fprintf('\n============================== start ============================\n');
fprintf('\n  *** Chamber #%d (%s) ***\n\n',chNum,fluxType);
fprintf('---- Parameters ----\n')
if useMedFilt
    fprintf('Using medfilt1: true, (%d points long))\n', medFiltPoints);
else
    fprintf('Using medfilt1: false\n');
end
fprintf('points to keep      = %d%%\n',floor(percent_of_points_to_keep*100));
fprintf('std_multiplier      = %d\n',std_multiplier);
fprintf('absolute_flux_limit = %d to %d\n',absolute_flux_limit);
fprintf('absolute_rmse_limit = %d\n\n',absolute_rmse_limit);

fprintf('---- Outlier removal ---- \n');
fprintf('                   Exp            Lin\n');
fprintf('AbsFluxLim:   %8d       %8d\n',sum(indOutlierExp_absFluxLimit),sum(indOutlierLin_absFluxLimit));
fprintf('AbsRmseLim:   %8d       %8d\n',sum(indOutlierExp_absRmseLimit),sum(indOutlierLin_absRmseLimit));
fprintf('spikesRmse:   %8d       %8d\n',sum(indOutlierExp_spikesRmse),sum(indOutlierLin_spikesRmse));
fprintf('spikesFlux:   %8d       %8d\n',sum(indOutlierExp_spikesFlux),sum(indOutlierLin_spikesFlux));
fprintf('NaNs      :   %8d       %8d\n\n',sum(indOutlierExp_FluxNans),sum(indOutlierLin_FluxNans));

fprintf('Removing %5d (out of %5d) outliers from exp fit\n',sum(indOutlierExp),length(flux_exp_B));
fprintf('Removing %5d (out of %5d) outliers from lin fit\n',sum(indOutlierLin),length(flux_lin_B));


fig = 0;

%------------------------------------------------------------------------
% First plot the input data:
%  - rmse (before and after spike filtering)
%  - dcdt (before and after spike filtering) 
%  - flux (before and after spike filtering)
fig = fig+1;
figure(fig)
clf
%--- exp_B ---
ax(1) = subplot(3,2,1);
plot(doy,[rmse_exp_B rmse_exp_B],'.')
grid on
%ylim([0 10])
legend('Original','Filtered')
title([fluxType ' (EXP\_B)'])
ylabel('rmse (ppm)')
ax(2) = subplot(3,2,3);
plot(doy,[dcdt_exp_B dcdt_exp_B_filtered],'.')
%ylim(absolute_flux_limit/10)
ylabel('dcdt (ppm s^{-1})')
grid on
ax(3) = subplot(3,2,5);
plot(doy,[flux_exp_B flux_exp_B_filtered],'.')
%ylim(absolute_flux_limit)
ylabel('flux (ppm m^{-2} sec^{-1})')
grid on
zoom on
linkaxes(ax,'x')
xlim([170 240])

%--- lin_B ---
ax(1) = subplot(3,2,2);
plot(doy,[rmse_lin_B rmse_lin_B],'.')
grid on
%ylim([0 10])
legend('Original','Filtered')
title([fluxType ' (LIN\_B)'])
ylabel('rmse (ppm)')
ax(2) = subplot(3,2,4);
plot(doy,[dcdt_lin_B dcdt_lin_B_filtered],'.')
%ylim(absolute_flux_limit/10)
ylabel('dcdt (ppm s^{-1})')
grid on
ax(3) = subplot(3,2,6);
plot(doy,[flux_lin_B flux_lin_B_filtered],'.')
%ylim(absolute_flux_limit)
ylabel('flux (ppm m^{-2} sec^{-1})')
grid on
zoom on
linkaxes(ax,'x')
xlim([170 240])

%-----------------------------
% Second plot:
% RMSE error histograms
% The number of points accepted
% for the given threshold.
%-----------------------------
fig = fig+1;
figure(fig)
clf
ax(1) = subplot(2,2,1);
h1 = histogram(rmse_exp_B(~isnan(rmse_exp_B)),'BinLimits',[0 1],'BinWidth',0.01);
title('CO_2 (Exp\_B)')
xlabel('rmse (ppm)')
ylabel('Number of points')
hist_cumsum_exp_B_rmse = cumsum(h1.Values)/sum(h1.Values);                  % normalized cumsum of all the bins
hist_bin_edges_exp_B =  h1.BinEdges(2:end);
ind_tmp = find(hist_cumsum_exp_B_rmse > percent_of_points_to_keep);
rmse_threshold_exp_B_1 = hist_bin_edges_exp_B(ind_tmp(1));
rmse_std_exp = std(rmse_exp_B(~isnan(rmse_exp_B)));
rmse_threshold_exp_B_2 =  mean(rmse_exp_B(~isnan(rmse_exp_B)))   + rmse_std_exp * std_multiplier;
rmse_threshold_exp_B_3 =  median(rmse_exp_B(~isnan(rmse_exp_B))) + rmse_std_exp * std_multiplier;

fprintf('Exp_B:\n');
fprintf('   Threshold = %12.8f if keeping %d %% of points\n',rmse_threshold_exp_B_1,percent_of_points_to_keep*100);
fprintf('   Threshold = %12.8f if using mean(rmse)   + %d x std(rmse)\n',rmse_threshold_exp_B_2,std_multiplier);
fprintf('   Threshold = %12.8f if using median(rmse) + %d x std(rmse)\n',rmse_threshold_exp_B_3,std_multiplier);

ax(2) = subplot(2,2,2);
if strcmpi(fluxType,'co2')
    h2 = histogram(rmse_lin_B(~isnan(rmse_lin_B)),'BinLimits',[0 1],'BinWidth',0.01);
else
    h2 = histogram(rmse_lin_B(~isnan(rmse_lin_B)),'BinLimits',[0 0.001],'BinWidth',0.000001);    
end
title('CO_2 (Lin\_B)')
xlabel('rmse (ppm)')
ylabel('Number of points')


hist_cumsum_lin_B_rmse = cumsum(h2.Values)/sum(h2.Values);                  % normalized cumsum of all the bins
hist_bin_edges_lin_B =  h2.BinEdges(2:end);
ind_tmp = find(hist_cumsum_lin_B_rmse > percent_of_points_to_keep);
rmse_threshold_lin_B_1 = hist_bin_edges_lin_B(ind_tmp(1));
rmse_std_lin = std(rmse_lin_B(~isnan(rmse_lin_B)));
rmse_threshold_lin_B_2 = mean(rmse_lin_B(~isnan(rmse_lin_B)))   + rmse_std_lin * std_multiplier;
rmse_threshold_lin_B_3 = median(rmse_lin_B(~isnan(rmse_lin_B))) + rmse_std_lin * std_multiplier;

fprintf('Lin_B:\n');
fprintf('   Threshold = %12.8f if keeping %d %% of points\n',rmse_threshold_lin_B_1,percent_of_points_to_keep*100);
fprintf('   Threshold = %12.8f if using mean(rmse)   + %4.2f x std(rmse)\n',rmse_threshold_lin_B_2,std_multiplier);
fprintf('   Threshold = %12.8f if using median(rmse) + %4.2f x std(rmse)\n',rmse_threshold_lin_B_3,std_multiplier);

switch type_of_threshold
    case 1
        rmse_threshold = min([rmse_threshold_exp_B_1 rmse_threshold_lin_B_1]);
        fprintf('\nUse the minimum threshold min(exp_B,lin_B) based on keeping %d %% of all points\n',percent_of_points_to_keep*100);
    case 2
        rmse_threshold = min([rmse_threshold_exp_B_2 rmse_threshold_lin_B_2]);
        fprintf('\nUse the minimum threshold min(exp_B,lin_B) based on (mean rmse errors) * %4.2f\n',std_multiplier);
    case 3
        rmse_threshold = min([rmse_threshold_exp_B_3 rmse_threshold_lin_B_3]);
        fprintf('\nUse the minimum threshold min(exp_B,lin_B) based on (median rmse errors) * %4.2f\n',std_multiplier);
end

fprintf('    Threshold to apply: %12.8f\n',rmse_threshold);

indBad_exp_B = rmse_exp_B > rmse_threshold | isnan(rmse_exp_B);
indBad_lin_B = rmse_lin_B > rmse_threshold | isnan(rmse_lin_B);

% Pick the best data. 
%   1. Use exp_B if good, 
%   2. replace bad exp_B points with good lin_B points when possible
%   3. reject the points when both are bad
% 
% indGood_filled = ~indBad_exp_B | (indBad_exp_B & ~indBad_lin_B);

% Initiate an array of NaNs
goodDCDT = NaN(nPoints,1);
goodFlux = NaN(nPoints,1);

if strcmpi(fluxType,'co2')
    indFirstChoice = indBad_exp_B;
    indSecondChoice = indBad_lin_B;
else
%     indFirstChoice = indBad_lin_B;
%     indSecondChoice = indBad_exp_B;
    indFirstChoice = indBad_exp_B ;
    indSecondChoice = indBad_lin_B;
end


% use good exp_B points if they are good
goodDCDT(~indFirstChoice) = dcdt_exp_B_filtered(~indFirstChoice);
goodFlux(~indFirstChoice) = flux_exp_B_filtered(~indFirstChoice);

% fill in the bad exp_B points with good lin_B points if those exist
goodDCDT(indFirstChoice & ~indSecondChoice) = dcdt_lin_B_filtered(indFirstChoice & ~indSecondChoice);
goodFlux(indFirstChoice & ~indSecondChoice) = flux_lin_B_filtered(indFirstChoice & ~indSecondChoice);
indGood_filled = ~isnan(goodDCDT);   % or: indGood_filled = ~indBad_exp_B | (indBad_exp_B & ~indBad_lin_B);

N1 = sum(~indFirstChoice);
N2 = sum(indFirstChoice & ~indSecondChoice);
fprintf('Points filled using exp_B: %5d\n',N1);
fprintf('Points filled using lin_B: %5d\n',N2);
fprintf('Total points: %5d of %d (%d%%)\n',N1+N2,length(goodDCDT),round((N1+N2)/length(goodDCDT)*100));

ax(3)= subplot(2,2,3);
plot(hist_bin_edges_exp_B,hist_cumsum_exp_B_rmse,[1 1 ]*rmse_threshold, [0 1])
grid on
zoom on
ax(4)= subplot(2,2,4);
plot(hist_bin_edges_lin_B,hist_cumsum_lin_B_rmse,[1 1 ]*rmse_threshold, [0 1])
grid on
zoom on
linkaxes(ax,'x')

%----------------------------------------------
% Third plot
%----------------------------------------------

fig = fig+1;
figure(fig)
clf
bx(1) = subplot(3,1,1);
plot(doy,dcdt_lin_B_filtered,'.', ...
    doy,dcdt_exp_B_filtered,'.',...
    doy(indGood_filled),goodDCDT(indGood_filled),'o'...
    )
%ylim([-1 1])
ylabel('dcdt')
legend('lin','exp','good','location','eastoutside')
title(sprintf('%s for chamber #%d',fluxType,chNum))
grid on
zoom on

bx(2) = subplot(3,1,2);
plot(doy(indGood_filled),goodFlux(indGood_filled),'.',...
     doy(indFirstChoice & ~indSecondChoice),goodFlux(indFirstChoice & ~indSecondChoice),'b.')
bx_chi = get(bx(2),'chi');
set(bx_chi(2),'color',[0.8500 0.3250 0.0980]);
 ylabel('flux')
legend('good','lin-filled','location','eastoutside')
 grid on
zoom on

bx(3) = subplot(3,1,3);
plot(doy,rmse_lin_B,'.', ...
    doy,rmse_exp_B,'.',...
    doy(indFirstChoice & ~indSecondChoice),rmse_lin_B(indFirstChoice & ~indSecondChoice),'o', ...
    doy([1 end]),[1 1]*rmse_threshold,'-k')
ylabel('rmse')
xlabel('DOY')
legend('lin','exp','lin-filled','location','eastoutside')
grid on
zoom on

linkaxes(bx,'x')



% fig = fig+1;
% figure(fig)
% clf
% plot(doy,rmse_lin_B,'.', ...
%      doy,rmse_exp_B,'.',...
%      doy([1 end]),[1 1]*rmse_threshold,'-r')
% %      doy(~indBad_lin_B),rmse_lin_B(~indBad_lin_B),'o', ...
% %      doy(~indBad_exp_B),rmse_exp_B(~indBad_exp_B),'o')
% 
%  ylim([0 1]);
% grid on
% zoom on