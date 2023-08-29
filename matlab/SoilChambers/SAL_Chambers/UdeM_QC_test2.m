%% QA/QC for UdeM 2019 data set

load data/all_chambers.mat
clear cleanFlux

%%
%#ok<*NBRAK> 
chToProcess = [1:18];           % Chamber to process (a scalar or a vector)
fluxType = 'ch4';               % flux (ch4 or co2)
if strcmpi(fluxType,'co2')
    expFirst = true;               % use exponential (exp_B) fit first, lin_B second
else
    expFirst = false;               % use exponential (exp_B) fit first, lin_B second
end

if expFirst
    firstChoice  = 'exp_B';
    secondChoice = 'lin_B';
else
    firstChoice  = 'lin_B';
    secondChoice = 'exp_B';
    fillFlag = false;
end

percent_of_points_to_keep = 0.90;
std_multiplier = 2;
%mean_multiplier = 1;
type_of_threshold = 2;     % 1- keep % of data, 2 - use mean(rmse)*std_multiplier, 3 - median*std_multiplier, 
useMedFilt = false;
medFiltPoints = 2;

if strcmpi(fluxType,'co2')
    absolute_rmse_limit = 1;
    absolute_flux_limit = [-10 +20];
    binLimits = [0 1];
    BinWidth = 0.01;
else
    absolute_rmse_limit = 0.005;
    absolute_flux_limit = [-20 +20]/1000;
    binLimits = [0 0.001];
    BinWidth = 0.00001;
end

% ----- store clean data ---------------
cleanFlux.(fluxType).firstChoice = firstChoice;
cleanFlux.(fluxType).secondChoice = secondChoice;
cleanFlux.(fluxType).std_multiplier = std_multiplier;
cleanFlux.(fluxType).useMedFilt = useMedFilt;
cleanFlux.(fluxType).medFiltPoints = medFiltPoints;
cleanFlux.(fluxType).percent_of_points_to_keep = percent_of_points_to_keep;
cleanFlux.(fluxType).absolute_rmse_limit = absolute_rmse_limit;
cleanFlux.(fluxType).absolute_flux_limit = absolute_flux_limit;
cleanFlux.(fluxType).binLimits = binLimits;
cleanFlux.(fluxType).BinWidth = BinWidth;

for chNum=chToProcess

    % --------------- Extract data -----------------------
    tv = chamberOut.chamber(chNum).tv;
    doy = tv-datenum(2019,1,0);

    rmse_firstChoice = chamberOut.chamber(chNum).flux.(fluxType).(firstChoice).rmse;
    rmse_secondChoice = chamberOut.chamber(chNum).flux.(fluxType).(secondChoice).rmse;
    dcdt_firstChoice = chamberOut.chamber(chNum).flux.(fluxType).(firstChoice).dcdt;
    dcdt_secondChoice = chamberOut.chamber(chNum).flux.(fluxType).(secondChoice).dcdt;
    flux_firstChoice = chamberOut.chamber(chNum).flux.(fluxType).(firstChoice).flux;
    flux_secondChoice = chamberOut.chamber(chNum).flux.(fluxType).(secondChoice).flux;

    nPoints = length(rmse_firstChoice);


    % When cleaning CH4 data, remove all exp_B data when dcdt_lin_B < 1e-4. When dcdt is
    % this low, the exp fit is not reliable. The value might be conservative (I had this before
    % at 0.3e-4) but better safe than sorry.
%     if strcmpi(fluxType,'ch4') 
%         if strcmpi(firstChoice,'lin_B')
%             flux_secondChoice(abs(dcdt_firstChoice)<3e-5) = 9999;
%         else
%             flux_firstChoice(abs(dcdt_secondChoice)<3e-5) = 9999;
%         end
%     end

    % ------------- remove all outliers --------------------
    indOutlier_absFluxLimit_firstChoice  = flux_firstChoice  < absolute_flux_limit(1)| flux_firstChoice  >= absolute_flux_limit(2) ;
    indOutlier_absFluxLimit_secondChoice = flux_secondChoice < absolute_flux_limit(1)| flux_secondChoice >= absolute_flux_limit(2) ;

    indOutlier_absRmseLimit_firstChoice  = rmse_firstChoice  > absolute_rmse_limit;
    indOutlier_absRmseLimit_secondChoice = rmse_secondChoice > absolute_rmse_limit;

    indOutlier_spikesRmse_firstChoice    = abs(rmse_firstChoice  - mean(rmse_firstChoice (~isnan(rmse_firstChoice))))  > std_multiplier*std(rmse_firstChoice (~isnan(rmse_firstChoice)));
    indOutlier_spikesRmse_secondChoice   = abs(rmse_secondChoice - mean(rmse_secondChoice(~isnan(rmse_secondChoice)))) > std_multiplier*std(rmse_secondChoice(~isnan(rmse_secondChoice)));

    indOutlier_spikesFlux_firstChoice    = abs(flux_firstChoice  - mean(flux_firstChoice (~isnan(rmse_firstChoice))))  > std_multiplier*std(flux_firstChoice (~isnan(flux_firstChoice)));
    indOutlier_spikesFlux_secondChoice   = abs(flux_secondChoice - mean(flux_secondChoice(~isnan(rmse_secondChoice)))) > std_multiplier*std(flux_secondChoice(~isnan(flux_secondChoice)));

    indOutlier_FluxNans_firstChoice      = isnan(flux_firstChoice);
    indOutlier_FluxNans_secondChoice     = isnan(flux_secondChoice);

    indOutlier_firstChoice = indOutlier_absFluxLimit_firstChoice ...
                 |  indOutlier_absRmseLimit_firstChoice...
                 |  indOutlier_spikesRmse_firstChoice...
                 |  indOutlier_spikesFlux_firstChoice...
                 |  indOutlier_FluxNans_firstChoice;

    indOutlier_secondChoice = indOutlier_absFluxLimit_secondChoice ...
                 |  indOutlier_absRmseLimit_secondChoice...
                 |  indOutlier_spikesRmse_secondChoice...
                 |  indOutlier_spikesFlux_secondChoice...
                 |  indOutlier_FluxNans_secondChoice;

    rmse_firstChoice(indOutlier_firstChoice)    = NaN;
    dcdt_firstChoice(indOutlier_firstChoice)    = NaN;
    flux_firstChoice(indOutlier_firstChoice)    = NaN;
    
    % Decide on whether to use data filling by the secondChoice fits
    if fillFlag
        rmse_secondChoice(indOutlier_secondChoice)  = NaN;    
        dcdt_secondChoice(indOutlier_secondChoice)  = NaN;
        flux_secondChoice(indOutlier_secondChoice)  = NaN;
    else
        rmse_secondChoice(1:end)  = NaN;    
        dcdt_secondChoice(1:end)  = NaN;
        flux_secondChoice(1:end)  = NaN;
    end
    
    % ----------- Do a bit of filtering if desired ---------------------
    if useMedFilt
        dcdt_filtered_firstChoice   = medfilt1(dcdt_firstChoice, medFiltPoints,'omitnan'); %#ok<*UNRCH>
        dcdt_filtered_secondChoice  = medfilt1(dcdt_secondChoice,medFiltPoints,'omitnan');
        flux_filtered_firstChoice   = medfilt1(flux_firstChoice, medFiltPoints,'omitnan');
        flux_filtered_secondChoice  = medfilt1(flux_secondChoice,medFiltPoints,'omitnan');
    else
        dcdt_filtered_firstChoice   = dcdt_firstChoice;
        dcdt_filtered_secondChoice  = dcdt_secondChoice;
        flux_filtered_firstChoice   = flux_firstChoice;
        flux_filtered_secondChoice  = flux_secondChoice;
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
    fprintf('                   %s          %s\n',firstChoice,secondChoice);
    fprintf('AbsFluxLim:   %8d       %8d\n',sum(indOutlier_absFluxLimit_firstChoice),sum(indOutlier_absFluxLimit_secondChoice));
    fprintf('AbsRmseLim:   %8d       %8d\n',sum(indOutlier_absRmseLimit_firstChoice),sum(indOutlier_absRmseLimit_secondChoice));
    fprintf('spikesRmse:   %8d       %8d\n',sum(indOutlier_spikesRmse_firstChoice),sum(indOutlier_spikesRmse_secondChoice));
    fprintf('spikesFlux:   %8d       %8d\n',sum(indOutlier_spikesFlux_firstChoice),sum(indOutlier_spikesFlux_secondChoice));
    fprintf('NaNs      :   %8d       %8d\n\n',sum(indOutlier_FluxNans_firstChoice),sum(indOutlier_FluxNans_secondChoice));

    fprintf('Removing %5d (out of %5d) outliers from %s fit\n',sum(indOutlier_firstChoice),length(flux_firstChoice),firstChoice);
    fprintf('Removing %5d (out of %5d) outliers from %s fit\n',sum(indOutlier_secondChoice),length(flux_secondChoice),secondChoice);


    fig = 0;

    %------------------------------------------------------------------------
    % First plot the input data:
    %  - rmse (before and after spike filtering)
    %  - dcdt (before and after spike filtering) 
    %  - flux (before and after spike filtering)
    fig = fig+1;
    figure(fig)
    clf
    %--- firstChoice ---
    ax_1(1) = subplot(3,2,1);
    plot(doy,[rmse_firstChoice rmse_firstChoice],'.')
    grid on
    %ylim([0 10])
    legend('Original','Filtered')
    title([fluxType ' (' firstChoice ')'],'interp','none')
    ylabel('rmse (ppm)')
    ax_1(2) = subplot(3,2,3);
    plot(doy,[dcdt_firstChoice dcdt_filtered_firstChoice],'.')
    %ylim(absolute_flux_limit/10)
    ylabel('dcdt (ppm s^{-1})')
    grid on
    ax_1(3) = subplot(3,2,5);
    plot(doy,[flux_firstChoice flux_filtered_firstChoice],'.')
    %ylim(absolute_flux_limit)
    ylabel('flux (ppm m^{-2} sec^{-1})')
    grid on
    zoom on

    %--- secondChoice ---
    ax_1(4) = subplot(3,2,2);
    plot(doy,[rmse_secondChoice rmse_secondChoice],'.')
    grid on
    %ylim([0 10])
    legend('Original','Filtered')
    title([fluxType ' (' secondChoice ')'],'interp','none')
    ylabel('rmse (ppm)')
    ax_1(5) = subplot(3,2,4);
    plot(doy,[dcdt_secondChoice dcdt_filtered_secondChoice],'.')
    %ylim(absolute_flux_limit/10)
    ylabel('dcdt (ppm s^{-1})')
    grid on
    ax_1(6) = subplot(3,2,6);
    plot(doy,[flux_secondChoice flux_filtered_secondChoice],'.')
    %ylim(absolute_flux_limit)
    ylabel('flux (ppm m^{-2} sec^{-1})')
    grid on
    zoom on
    linkaxes(ax_1,'x')

    xlim([170 240])
    for xC = 1:3
        yLim1 = ylim(ax_1(xC));
        yLim2 = ylim(ax_1(xC+3));
        yLimNew(1) = min(yLim1(1), yLim2(1));
        yLimNew(2) = max(yLim1(2), yLim2(2));
        subplot(3,2,1+(xC-1)*2)
        ylim(yLimNew)
        subplot(3,2,2+(xC-1)*2)
        ylim(yLimNew)
    end

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
    h1 = histogram(rmse_firstChoice(~isnan(rmse_firstChoice)),'BinLimits',binLimits,'BinWidth',BinWidth);
    grid on
    title([fluxType ' (' firstChoice ')'],'interp','none')
    xlabel('rmse (ppm)')
    ylabel('Number of points')
    hist_cumsum_rmse_firstChoice = cumsum(h1.Values)/sum(h1.Values);                  % normalized cumsum of all the bins
    hist_bin_edges_firstChoice =  h1.BinEdges(2:end);
    ind_tmp = find(hist_cumsum_rmse_firstChoice > percent_of_points_to_keep);
    rmse_threshold_firstChoice_1 = hist_bin_edges_firstChoice(ind_tmp(1));
    rmse_std_firstChoice = std(rmse_firstChoice(~isnan(rmse_firstChoice)));
    rmse_threshold_firstChoice_2 =  mean(rmse_firstChoice(~isnan(rmse_firstChoice)))   + rmse_std_firstChoice * std_multiplier;
    rmse_threshold_firstChoice_3 =  median(rmse_firstChoice(~isnan(rmse_firstChoice))) + rmse_std_firstChoice * std_multiplier;

    fprintf('%s:\n',firstChoice);
    fprintf('   Threshold = %12.8f if keeping %d %% of points\n',rmse_threshold_firstChoice_1,percent_of_points_to_keep*100);
    fprintf('   Threshold = %12.8f if using mean(rmse)   + %d x std(rmse)\n',rmse_threshold_firstChoice_2,std_multiplier);
    fprintf('   Threshold = %12.8f if using median(rmse) + %d x std(rmse)\n',rmse_threshold_firstChoice_3,std_multiplier);

    ax(2) = subplot(2,2,3);
    h2 = histogram(rmse_secondChoice(~isnan(rmse_secondChoice)),'BinLimits',binLimits,'BinWidth',BinWidth);
    title([fluxType ' (' secondChoice ')'],'interp','none')
    grid on
    zoom on
    xlabel('rmse (ppm)')
    ylabel('Number of points')

    yLim1 = ylim(ax(1));
    yLim2 = ylim(ax(2));
    yLimNew(1) = min(yLim1(1), yLim2(1));
    yLimNew(2) = max(yLim1(2), yLim2(2));
    subplot(ax(1))
    ylim(yLimNew)
    subplot(ax(2))
    ylim(yLimNew)

    hist_cumsum_rmse_secondChoice = cumsum(h2.Values)/sum(h2.Values);                  % normalized cumsum of all the bins
    hist_bin_edges_secondChoice =  h2.BinEdges(2:end);
    ind_tmp = find(hist_cumsum_rmse_secondChoice > percent_of_points_to_keep);
    if ~isempty(ind_tmp)
        rmse_threshold_secondChoice_1 = hist_bin_edges_secondChoice(ind_tmp(1));
    else
        rmse_threshold_secondChoice_1 = 9999;
    end
    rmse_std_secondChoice = std(rmse_secondChoice(~isnan(rmse_secondChoice)));
    rmse_threshold_secondChoice_2 = mean(rmse_secondChoice(~isnan(rmse_secondChoice)))   + rmse_std_secondChoice * std_multiplier;
    rmse_threshold_secondChoice_3 = median(rmse_secondChoice(~isnan(rmse_secondChoice))) + rmse_std_secondChoice * std_multiplier;

    fprintf('%s:\n',secondChoice);
    fprintf('   Threshold = %12.8f if keeping %d %% of points\n',rmse_threshold_secondChoice_1,percent_of_points_to_keep*100);
    fprintf('   Threshold = %12.8f if using mean(rmse)   + %4.2f x std(rmse)\n',rmse_threshold_secondChoice_2,std_multiplier);
    fprintf('   Threshold = %12.8f if using median(rmse) + %4.2f x std(rmse)\n',rmse_threshold_secondChoice_3,std_multiplier);

    switch type_of_threshold
        case 1
            rmse_threshold = min([rmse_threshold_firstChoice_1 rmse_threshold_secondChoice_1]);
            fprintf('\nUse the minimum threshold min(exp_B,lin_B) based on keeping %d %% of all points\n',percent_of_points_to_keep*100);
        case 2
            rmse_threshold = min([rmse_threshold_firstChoice_2 rmse_threshold_secondChoice_2]);
            fprintf('\nUse the minimum threshold min(exp_B,lin_B) based on (mean rmse errors) * %4.2f\n',std_multiplier);
        case 3
            rmse_threshold = min([rmse_threshold_firstChoice_3 rmse_threshold_secondChoice_3]);
            fprintf('\nUse the minimum threshold min(exp_B,lin_B) based on (median rmse errors) * %4.2f\n',std_multiplier);
    end

    fprintf('    Threshold to apply: %12.8f\n',rmse_threshold);

    indBadFirstChoice  = rmse_firstChoice  > rmse_threshold | isnan(rmse_firstChoice);
    indBadSecondChoice = rmse_secondChoice > rmse_threshold | isnan(rmse_secondChoice);

    % Pick the best data. 
    %   1. Use exp_B if good, 
    %   2. replace bad exp_B points with good lin_B points when possible
    %   3. reject the points when both are bad
    % 
    % indGood_filled = ~indBad_exp_B | (indBad_exp_B & ~indBad_lin_B);

    % Initiate an array of NaNs
    goodDCDT   = NaN(nPoints,1);
    goodFlux   = NaN(nPoints,1);
    goodTv     = NaN(nPoints,1);
    goodRMSE   = NaN(nPoints,1);

    % use good exp_B points if they are good
    goodDCDT(~indBadFirstChoice) = dcdt_filtered_firstChoice(~indBadFirstChoice);
    goodFlux(~indBadFirstChoice) = flux_filtered_firstChoice(~indBadFirstChoice);
    goodRMSE(~indBadFirstChoice)   = goodRMSE(~indBadFirstChoice);
    goodTv(~indBadFirstChoice)   = tv(~indBadFirstChoice);

    % fill in the bad exp_B points with good lin_B points if those exist
    goodDCDT(indBadFirstChoice & ~indBadSecondChoice)   = dcdt_filtered_secondChoice(indBadFirstChoice & ~indBadSecondChoice);
    goodFlux(indBadFirstChoice & ~indBadSecondChoice)   = flux_filtered_secondChoice(indBadFirstChoice & ~indBadSecondChoice);
    indGood_filled = ~isnan(goodDCDT);                                      % or: indGood_filled = ~indBad_exp_B | (indBad_exp_B & ~indBad_lin_B);
    goodRMSE(indBadFirstChoice & ~indBadSecondChoice)   = goodRMSE(indBadFirstChoice & ~indBadSecondChoice);
    goodTv(indBadFirstChoice & ~indBadSecondChoice)     = tv(indBadFirstChoice & ~indBadSecondChoice);


    cleanFlux.(fluxType).chamber(chNum).tv              = goodTv;
    cleanFlux.(fluxType).chamber(chNum).flux            = goodFlux;
    cleanFlux.(fluxType).chamber(chNum).dcdt            = goodDCDT;
    cleanFlux.(fluxType).chamber(chNum).rmse            = goodRMSE;
    cleanFlux.(fluxType).chamber(chNum).rmseThreshold   =  rmse_threshold;
     
    cleanFlux.(fluxType).chamber(chNum).indFirstChoice = ~indBadFirstChoice;
    cleanFlux.(fluxType).chamber(chNum).indSecondChoice = indBadFirstChoice & ~indBadSecondChoice;
    


    N1 = sum(~indBadFirstChoice);
    N2 = sum(indBadFirstChoice & ~indBadSecondChoice);
    fprintf('Points filled using %s: %5d\n',firstChoice,N1);
    fprintf('Points filled using %s: %5d\n',secondChoice,N2);
    fprintf('Total points: %5d of %d (%d%%)\n',N1+N2,length(goodDCDT),round((N1+N2)/length(goodDCDT)*100));

    ax(3)= subplot(2,2,2);
    plot(hist_bin_edges_firstChoice,hist_cumsum_rmse_firstChoice,[1 1 ]*rmse_threshold, [0 1])
    xlabel('rmse (ppm)')
    ylabel('Normalized cumsum(rmse)')
    grid on
    zoom on

    ax(4)= subplot(2,2,4);
    plot(hist_bin_edges_secondChoice,hist_cumsum_rmse_secondChoice,[1 1 ]*rmse_threshold, [0 1])
    xlabel('rmse (ppm)')
    ylabel('Normalized cumsum(rmse)')
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
    plot(doy,flux_filtered_firstChoice,'.',...
        doy,flux_filtered_secondChoice,'.', ...
        doy(indGood_filled),goodFlux(indGood_filled),'o'...
        )
    %ylim([-1 1])
    ylabel('flux')
    legend(firstChoice,secondChoice,'good','location','eastoutside','Interpreter','none')
    title(sprintf('%s for chamber #%d',fluxType,chNum))
    grid on
    zoom on

    bx(2) = subplot(3,1,2);
    plot(doy(indGood_filled),goodFlux(indGood_filled),'.',...
         doy(indBadFirstChoice & ~indBadSecondChoice),goodFlux(indBadFirstChoice & ~indBadSecondChoice),'b.')
    bx_chi = get(bx(2),'chi');
    set(bx_chi(1),'color',[0.8500 0.3250 0.0980]);
    try,set(bx_chi(2),'color',[0 0.4470 0.7410]);end
     ylabel('flux')
    legend('good',[secondChoice '-filled'],'location','eastoutside','Interpreter','none')
     grid on
    zoom on

    bx(3) = subplot(3,1,3);
    plot(doy,rmse_firstChoice,'.',...
         doy,rmse_secondChoice,'.', ...
         doy(indBadFirstChoice & ~indBadSecondChoice),rmse_secondChoice(indBadFirstChoice & ~indBadSecondChoice),'o', ...
         doy([1 end]),[1 1]*rmse_threshold,'-k')
    ylabel('rmse')
    xlabel('DOY')
    legend(firstChoice,secondChoice,[secondChoice '-filled'],'location','eastoutside','Interpreter','none')
    grid on
    zoom on

    linkaxes(bx,'x')
    posGood = get(bx(3),'pos');
    posBad = get(bx(1),'pos');
    set(bx(1),'pos',[posBad(1:2) posGood(3:4)])

    %----------------------------------------------
    % Forth plot
    %----------------------------------------------

    fig = fig+1;
    figure(fig)
    clf
    dx(1) = subplot(3,1,1);
    plot(doy,flux_filtered_firstChoice,'.',...
        doy,flux_filtered_secondChoice,'.')
    %ylim([-1 1])
    ylabel('flux')
    legend(firstChoice,secondChoice,'location','eastoutside','Interpreter','none')
    title(sprintf('%s for chamber #%d',fluxType,chNum))
    grid on
    zoom on

    dx(2) = subplot(3,1,2);
    plot(doy,~indOutlier_absFluxLimit_firstChoice,'o',...
         doy,~indOutlier_absRmseLimit_firstChoice,'x',...
         doy,~indOutlier_spikesRmse_firstChoice,'+',...
         doy,~indOutlier_spikesFlux_firstChoice,'*',...
         doy,~indOutlier_FluxNans_firstChoice,'d')
    % dx_chi = get(dx(2),'chi');
    % set(dx_chi(1),'color',[0.8500 0.3250 0.0980]);
    % set(dx_chi(2),'color',[0 0.4470 0.7410]);
     ylabel('Removed points')
     title(firstChoice,'interp','none')
    legend('AbsFluxLim','AbsRmseLim','spikesRmse','spikesFlux','FluxNans','location','eastoutside','Interpreter','none')
     grid on
     ylim([-0.5 0.5])
    zoom on

    dx(3) = subplot(3,1,3);
    plot(doy,~indOutlier_absFluxLimit_secondChoice,'o',...
         doy,~indOutlier_absRmseLimit_secondChoice,'x',...
         doy,~indOutlier_spikesRmse_secondChoice,'+',...
         doy,~indOutlier_spikesFlux_secondChoice,'*',...
         doy,~indOutlier_FluxNans_secondChoice,'d')
    % dx_chi = get(dx(2),'chi');
    % set(dx_chi(1),'color',[0.8500 0.3250 0.0980]);
    % set(dx_chi(2),'color',[0 0.4470 0.7410]);
     ylabel('Removed points')
     title(secondChoice,'interp','none')
    legend('AbsFluxLim','AbsRmseLim','spikesRmse','spikesFlux','FluxNans','location','eastoutside','Interpreter','none')
     grid on
     ylim([-0.5 0.5])
    zoom on

    linkaxes(dx,'x')
    xlim([170 240])
    posGood = get(dx(3),'pos');
    posBad = get(dx(1),'pos');
    set(dx(1),'pos',[posBad(1:2) posGood(3:4)])
    
    pause
end
