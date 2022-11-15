function out = cumsum_CI_BAMS(data,drange,flux,fig,method,nbins,site)
% This code computes the half-hourly random and gap-filling uncertainty in
% cumulative sums of CO2 and CH4 exchange gap-filled from the Biomet lab L3
% centralized flux processing code.
%
% Random errors in eddy covariance fluxes follow a double exponential
% (laplace) distribution with a standard deviation that varies with the
% flux magnitude (Hollinger and Richardson, 2005). Random error can be
% estimated in two ways:

% 1)The model residuals of
% high performance gap-filling algorithms such as the ANN used in the
% L3 gap-filling code provide a good, if not conservative estimate of the
% random uncertainty (Moffat et al. 2007, Richardson et al. 2008). Thus,
% the variance in the 20 ANN predictions for gap-filled points
% represents the combined random and gap-filling uncertainty (Richardson
% and Hollinger, 2007). For original measured values, the random
% half-hourly uncertainty can be found by using the residuals of the
% median ANN predictions (binned by flux magnitude) to parameterize a
% double exponential distribution (Moffat et al. 2007). Then, the random
% uncertainty of the cumulative sums is estimated using a Monte Carlo
% simulation that randomly draws 1000 random errors for every original
% measurement from the appropriate distribution and computing the variance
% of the cumulative sums.

% 2) Random error can be estimated using the daily differencing approach
% described in Richardson et al., 2006
%
% The combined gap-filling & random
% uncertainty of cumulative sums of gap-filled points is computed from the
% variance of the cumulative sums of the 20 ANN predictions (if you can run
% more ANN predictions, that is better - e.g. 50).

% Finally, Following
% Richardson and Hollinger (2007), the cumulative gap-filling and random
% measurement uncertainties of gap-filled and original values are added in
% quadrature to form the total random uncertainty.
%
% Directions:
% 1. Load the L3 file output from ECfluxL3_main.m
% 2. Change the date range of desired cumulative sum in beginning of code
%    and the flux to indicate (can do CO2 or CH4)
% 3. Run the code running either method 1 or method 2 to estimate random
% uncertainty
%
% Results:
% Results are presented in the structure variable 'out', which contains
% the following fields:
% out.Mdate: the Matlab date vector corresponding with the other outputs
% out.wx_ANNVar: [umol m-2 s-1 for CO2, nmol m-2 s-1 for CH4] gap
%                   filling/random error variance of each gap-filled value
% out.wx_cumANNVar: [g C m-2] gap-filling/random error variance of
%                      cumulative sum of gap-filled values
% out.wx_RandVar: [umol m-2 s-1 for CO2, nmol m-2 s-1 for CH4] random
%                    error variance of each original measured value
% out.wx_cumRandVar: [g C m-2] random error variance of cumulative sum
%                       of original measured values
% out.wx_cumUncStd: [g C m-2] combined gap-filling & random error
%                     uncertainty of cumulative data series. NOTE this is a
%                     standard deviation and not a variance.
% **Note** The output of the cumulative sums and uncertainty are in g C m-2

% This code was originally written by Cover Sturtevant and modified by Sara
% Knox to include the daily differencing approach to estimate random error

% First load data then enter the date range in Matlab format to compute cumulative sums
% over. The format is [min max] date. Values will be retained > min date
% and <= max date.
%load('/Users/saraknox/Google Drive/Documents/MATLAB/FieldSiteData/RushRanch/RR_2014071to2018099_L3.mat')

% Date range
%drange = [datenum(2016,1,1) datenum(2017,1,1)];

% Choose the flux to evaluate. Enter 'wc' for CO2 flux, 'wm' for CH4 flux
%flux = 'wc';

%% Compute cumulative gap-filling uncertainty
% Note: This includes random error (see paragraph above)

% Pull appropriate flux variables
if strcmp(flux,'wc')
%     % CO2 flux
%     wx = data.wc;
%     wxANN = data.wc_ANN;
%     wxANNext = data.wc_ANNext;
%     hhconv = 60*30/1e6*12; % conversion factor to go from umol m-2 s-1 to g C m-2 hh-1
%     edges = [-50:5:0 2:2:40]; % [umol m-2 s-1] Bin edges to eval double exponential distribution according to flux magnitude
%     nunits = '\mumol CO_2 m^{-2} s^{-1}'; % native units
elseif strcmp(flux,'FCH4')
    % CH4 flux
    wx = data.FCH4;
    wxANN = data.FCH4_ANN;
    wxANNext = data.FCH4_ANNext;
    hhconv = 60*30/1e9*12.01; % conversion factor to go from nmol m-2 s-1 to g C m-2 hh-1
    %edges = -100:50:1000; % [nmol m-2 s-1] Bin edges to eval double exponential distribution according to flux magnitude
    nunits = 'nmol CH_4 m^{-2} s^{-1}'; % native units
else
    error('Sorry, didn''t recognize flux type. Check ''flux'' variable in beginning of code')
end

% First replace ANN predictions with any original measured values (we only
% want the gap-filling (random?) uncertainty at this point)
nn = find(~isnan(wx));
data.wx_ANNextNew = wxANNext; % Work on a copy
data.wx_ANNextNew(nn,:) = repmat(wx(nn),1,size(data.wx_ANNextNew,2)); % replace ANN predictions with points we measured

% Now compute the cumulative sum and variance in cumulative sum of ANN
% predictions
jj = find(data.Mdate >= drange(1) & data.Mdate <= drange(2)); % ***** Get indices within the date range *****
if isempty(jj)
    error('No data found within time range. Check ''drange'' variable at beginning of code')
end
out.Mdate = data.Mdate(jj); % output date vector (in matlab date)
out.wx_ANNVar = var(data.wx_ANNextNew(jj,:),0,2); % umol m-2 s-1 gap-filling/random error estimate (variance) of each gap-filled value
wx_cumANN = cumsum(data.wx_ANNextNew(jj,:)*hhconv,1,'omitnan'); % Convert to g C m-2 hh-1 to make direct summing possible
out.wx_cumANNVar = var(wx_cumANN,0,2); % g C m-2 - cumulative ANN gap-filling/random uncertainty (variance)

% Plot histogram and Q-Q plot of cumANN to explore the distribution of the annual (or sub-annual) sums
wx_cumANN_end = wx_cumANN(end,:);

% Plot histogram and normal distrubution

% if fig == 1
%     figure
%     histfit(wx_cumANN_end,10,'normal');
%     
%     % Plot Q-Q plot
%     figure
%     qqplot(wx_cumANN_end)
% end

% Test for normality using - wc distrubution appears to be close to normal
% Lilliefors corrected Kolmogorov-Smirnov test
%[h,p,k,c] = lillietest(wx_cumANN_end);

% Shapiro-Wilk test
%[H, pValue, W] = swtest(wx_cumANN_end, 0.05);

%% Compute random uncertainty - Estimated from the residual between the final (median) ANN prediction and the measured flux (Method 1)

if method == 1
    % Compute residuals
    Res = wxANN-wx;
    
    % Bin this according to NEE magnitude. Others have derived an equation of
    % the random error with flux magnitude by performing a regression, but I
    % find this to be unreliable. Instead, binning by 5 umol m-2 s-1 for FCO2
    % uptake and 2 umol m-2 s-1 for CO2 respiration and 50 nmol m-2 s-1 for
    % FCH4 seems quite reasonable. Feel free to adjust the bins by changing the
    % "edges" variable above.
    %nbins = length(edges)-1; % total # bins
    
    %Plot random flux error--this should look like a laplace distribution
    nbinshist = 100;
    
%     if fig == 1
%         figure
%         histfit(Res,nbinshist,'normal');
%         pd = fitdist(Res,'Normal');
%         % hist(delta,nbins)
%         % ylabel('density')
%         % xlabel('Delta (random flux error)')
%         
%         % Fit Laplace distribution
%         [result, xspan, fx, y] = fit_ML_laplace_SK(Res(~isnan(Res)),nbinshist);
%         hold on
%         plot(xspan, fx, ':g', 'LineWidth', 2)
%         title(site)
%     end
    
    %fit random flux error to both laplace and normal distributions
    %look at RMS error for both fits--Laplace should be smaller
    laplace_res = fit_ML_laplace(Res(~isnan(Res)));
    normal_res = fit_ML_normal(Res(~isnan(Res)));
    
    sigma = sqrt(2).*laplace_res.b; % Overall sigma for the distribution
    norm_RMS = sqrt(2).*normal_res.RMS;
    laplace_RMS = sqrt(2).*laplace_res.RMS;
    
    % Plot by wind speed
    
    % Bin this according to FCH4 magnitude. Others have derived an equation of
    % the random error with flux magnitude by performing a regression, but I
    % find this to be unreliable. Instead, binning 50 nmol m-2 s-1 for
    % FCH4 seems quite reasonable. Feel free to adjust the bins by changing the
    % "edges" variable above.
    %nbins = length(edges)-1; % total # bins
    
    % Initialize variables
    prctile_range = [5 95];
    bin_length=(prctile(wx,prctile_range(end))-prctile(wx,prctile_range(1)))/nbins; % Used 1st and 99th percentiles to avoid influce of large outliers
    DEsigma = NaN(nbins,1); % standard deviations of res for each bin
    FCH4 = DEsigma; % mean FCH4 per bin
    N = FCH4; % N samples per bin
    wxRand = NaN(size(wx)); % estimate of random error
    
    % Loop through each bin, compute the standard deviation of the residuals
    % The residuals should follow a double exponential, for which the standard
    % deviation is the only parameter
    flg = NaN(nbins,1); % flag for forcing the std to an adjacent bin
    bin = NaN(nbins,1);
    for j = 1:nbins
        
        if j==1
            bin(j)=prctile(wx,prctile_range(1))+bin_length;
            Sel=wx>prctile(wx,prctile_range(1))&wx<=bin(j);
        elseif j > 1 && j <= nbins - 1
            bin(j)=bin(j-1)+bin_length;
            Sel=wx<=bin(j)&wx>bin(j-1);
        elseif j == nbins
            bin(j)=bin(j-1)+prctile(wx,prctile_range(end));
            Sel=wx>bin(j-1)&wx<=prctile(wx,prctile_range(end));
        end
        
        ii = find(Sel); % indices in range
        N(j) = length(ii); % sample size
        FCH4(j) = nanmean(wx(ii)); % mean FCH4 of bin
        
        % If number of samples is less than 50, use the standard deviation of
        % the previous bin
        if N(j) < 50
            DEsigma(j) = NaN;
        else
            
            % If we have enough samples, compute standard deviation of the
            % residuals - If follows laplace - should sigma be sqrt(2)*B
            %DEsigma(i) = std(Res(ii)); %Previously calculated just the std, but
            %since follows a Laplace distribution, sigma should be sqrt(2)*B
            beta = sum(abs(Res(ii)-nanmean(Res)))./length(Res(ii)); % LOCAL OR GLOBAL Res??? (Patty uses global!)
            DEsigma(j) = sqrt(2).*beta;
        end
    end
    
    % Make sure there is no missing values
    if sum(isnan(DEsigma)) > 0
        disp([site ' DEsigma missing in bins'])
    end
    
    DEsigma = fillmissing(DEsigma,'nearest');
    %ANN.(site).DEsigma(isnan(ANN.(site).DEsigma)) = ANN.(site).DEsigma(find(isnan(ANN.(site).DEsigma),1,'last')+1);
    
    %split fluxes into positive and negative
    Sel=FCH4>0;
    binned_flux_pos=FCH4(Sel);
    binned_DEsigma_pos=DEsigma(Sel);
    
    Sel=FCH4<0;
    binned_flux_neg=FCH4(Sel);
    binned_DEsigma_neg=DEsigma(Sel);
    
    %fit a linear eq to these data and use that eq to calculate random error
    npos = ~isnan(binned_flux_pos+binned_DEsigma_pos);
    nneg = ~isnan(binned_flux_neg+binned_DEsigma_neg);
    
    if sum(nneg) == 0
        p_neg = [NaN NaN];
    else
        p_neg=polyfit(binned_flux_neg(nneg),binned_DEsigma_neg(nneg),1);
        mdl_neg=fitlm(binned_flux_neg(nneg),binned_DEsigma_neg(nneg));
        Tlb=anova(mdl_neg,'summary');
        F=table2array(Tlb(2,4));
        mdl_neg_pValue=table2array(Tlb(2,5));
    end
    
    if sum(npos) == 0
        p_pos = [NaN NaN];
    else
        p_pos=polyfit(binned_flux_pos(npos),binned_DEsigma_pos(npos),1);
        mdl_pos=fitlm(binned_flux_pos(npos),binned_DEsigma_pos(npos));
        Tlb=anova(mdl_pos,'summary');
        F=table2array(Tlb(2,4));
        mdl_pos_pValue=table2array(Tlb(2,5));
    end
    
    yfit_pos=polyval(p_pos,binned_flux_pos);
    yfit_neg=polyval(p_neg,binned_flux_neg);
    
    if fig == 1
        figure
        plot(binned_flux_pos,binned_DEsigma_pos,'.','MarkerSize',12)
        hold on
        if exist('mdl_pos_pValue') && mdl_pos_pValue < 0.05
            plot(binned_flux_pos,yfit_pos,'r')
        end
        plot(binned_flux_neg,binned_DEsigma_neg,'.','MarkerSize',12)
        if exist('mdl_neg_pValue') && mdl_neg_pValue < 0.05
            plot(binned_flux_neg,yfit_neg,'r')
        end
        xlabel('Flux binned')
        ylabel('SD random error binned')
        title(site)
    end
    
    % If there is a significant relationship with windspeed (for positive fluxes),
    % make a random error estimate for FCH4 by randomly drawing from the
    % double exponential distribution (estimated from the standard deviation
    % of residuals in each NEE bin). Do this 100 times, and compute the
    % variance of the sums to estimate the cumulative random error of the
    % measured measured values.
    
    if mdl_pos_pValue < 0.05
        RandErrorEst = NaN(size(wxANN,1),100);
        edges = bin;
        for i = 1:nbins
            % Find measured values in this FCH4 bin
            if i == 1
                ii = find(wxANN < edges(i));
            elseif i > 1 && i <= nbins - 1
                ii = find(wxANN >= edges(i-1) & wxANN < edges(i));
            elseif i == nbins
                ii = find(wxANN >= edges(i-1)); 
            end
            
            % Randomly draw from the laplace distribution
            for j = 1:100
                RandErrorEst(ii,j) = randraw('laplace',[0 DEsigma(i)],length(ii));
            end
        end
    else
        % Randomly draw from the laplace distribution using the entire
        % database without binning
        for j = 1:100
            RandErrorEst(:,j) = randraw('laplace',[0 sigma],length(wx));
        end
        
    end
    
    % Now get the variability in the summed errors
    RandErrorEst_total = RandErrorEst;
    RandErrorEst_total(isnan(wxANN),:) = 0;
    RandErrorEst(isnan(wx),:) = 0; % Set gap-filled points to zero so when we sum we'll only sum over measured values
    out.wx_RandVar = var(RandErrorEst(jj,:),0,2); % random error estimate (variance) of each original measured value
    wx_cumRand = cumsum(RandErrorEst(jj,:)*hhconv,1); % Convert to g C m-2 hh-1 to make direct summing possible
    out.wx_cumRandVar = var(wx_cumRand,0,2); % g C m-2 - cumulative random uncertainty (variance) of measured values
    
    % Total random error without gaps
    out.wx_RandVar_total = var(RandErrorEst_total(jj,:),0,2); % random error estimate (variance) of each original measured value
    wx_cumRand_total = cumsum(RandErrorEst_total(jj,:)*hhconv,1); % Convert to g C m-2 hh-1 to make direct summing possible
    out.wx_cumRandVar_total = var(wx_cumRand_total,0,2); % g C m-2 - cumulative random uncertainty (variance) of measured values
    
    % Plot histogram and Q-Q plot of cumANN to explore the distribution of the annual (or sub-annual) sums
    wx_cumRand_end = wx_cumRand(end,:);
    
    %     if fig == 1
    %         % Plot histogram and normal distrubution
    %         figure
    %         histfit(wx_cumRand_end,50,'normal');
    %
    %         % Plot Q-Q plot
    %         figure
    %         qqplot(wx_cumRand_end)
    %
    %     end
    %
    % Test for normality using
    % Lilliefors corrected Kolmogorov-Smirnov test
    %[h,p,k,c] = lillietest(wx_cumRand_end);
    
    % Shapiro-Wilk test
    %[H, pValue, W] = swtest(wx_cumRand_end, 0.05);
    
    %% Compute random uncertainty - Estimated using the daily difference approach (Method 2)
    % elseif method == 2
    %
    %     if strcmp(flux,'wc')
    %         [RE_flux,binned_flux,binned_SD_laplace,binned_envir_var,p_pos,p_neg]=daily_diff(floor(data.decday),data.time,wx,3,[data.ubar Metdata.PAR data.TA],[1 75 3]);
    %     elseif strcmp(flux,'wm') % This might need to be modified for methane fluxes - I haven't tested it for methane yet
    %         [RE_flux,binned_flux,binned_SD_laplace,binned_envir_var,p_pos,p_neg]=daily_diff(floor(data.decday),data.time,wx,3,[data.ubar Metdata.PAR data.TA],[1 75 3]);
    %     end
    %
    %     % Monte-Carlo simulation to estimate random error
    %     niterations = 1000;
    %     RandErrorEst = NaN(length(wx),niterations);
    %
    %     for i = 1:length(wx)
    %         if ~isnan(RE_flux(i))
    %             RandErrorEst(i,:)  = randraw('laplace',[0 RE_flux(i)],niterations)'; % CHECK!!!
    %         end
    %     end
    %
    %     % Now get the variability in the summed errors
    %     RandErrorEst(isnan(RandErrorEst)) = 0; % Set gap-filled points to zero so when we sum we'll only sum over measured values
    %     out.wx_RandVar = var(RandErrorEst(jj,:),0,2); % random error estimate (variance) of each original measured value
    %     wx_cumRand = cumsum(RandErrorEst(jj,:)*hhconv,1); % Convert to g C m-2 hh-1 to make direct summing possible
    %     out.wx_cumRandVar = var(wx_cumRand,0,2); % g C m-2 - cumulative random uncertainty (variance) of measured values
    %
    %     % Plot histogram and Q-Q plot of cumANN to explore the distribution of the annual (or sub-annual) sums
    %     wx_cumRand_end = wx_cumRand(end,:);
    %
    %     if fig == 1
    %         % Plot histogram and normal distrubution
    %         figure
    %         histfit(wx_cumRand_end,50,'normal');
    %
    %         % Plot Q-Q plot
    %         figure
    %         qqplot(wx_cumRand_end)
    %     end
    %     % Test for normality using
    %     % Lilliefors corrected Kolmogorov-Smirnov test
    %     %[h,p,k,c] = lillietest(wx_cumRand_end);
    %
    %     % Shapiro-Wilk test
    %     %[H, pValue, W] = swtest(wx_cumRand_end, 0.05);
end

%% Sum the ANN and random measurement uncertainties
% Added in quadrature (as in Richardson and Hollinger 2007)
out.wx_cumUncStd = sqrt(out.wx_cumANNVar + out.wx_cumRandVar);
out.wx_cumANN = wx_cumANN;

if fig == 1
    figure;
    l1 = plot((1:length(jj))/48,median(wx_cumANN,2),'k','linewidth',2); hold on % Highlight the median - should be same as gap filled estimate
    l2 = plot((1:length(jj))/48,median(wx_cumANN,2)+2*out.wx_cumUncStd,'r','linewidth',2);% Highlight the 95% interval estimated from addition of random and gap-filling error
    l3 = plot((1:length(jj))/48,median(wx_cumANN,2)-2*out.wx_cumUncStd,'r','linewidth',2);% Highlight the 95% interval estimated from addition of random and gap-filling error
    ylabel('g C m^{-2}')
    xlabel('Days')
    legend([l1(1);l2(1)],{'Cumulative flux','95% GF + Rand Meas'})
    title('95% confidence bounds of cumulative sums')
    
end

out.wx_cumUncStd_end = out.wx_cumUncStd(end);
out.wx_cumUnc95CI_end = 2.*out.wx_cumUncStd_end;

if fig == 1
    figure; clf
    plot((1:length(jj))/48,2.*sqrt([out.wx_cumANNVar,out.wx_cumRandVar,out.wx_cumRandVar_total]))
    legend('Gap filled (ANN+random)','Random (measured)','Random (total)')
    title('Breakdown of cumulative uncertainty estimates')
    ylabel('2xStandard deviation (g C m^{-2})')
    xlabel('Half-hours')
end


