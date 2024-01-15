% Written by June Skeeter

% Clean and correct the water table data for the Burns Bog Flux Sites
% Written by June Skeeter January 2024
% Procedures:
%   Step 1. Read & filter manual WTD & Pipe Height observations
%   Step 2. Regress automated WTH with manual WTD
% 
% Intended to be called ~ 1/month to re-train models as manual observations are collected
% 
% 
% 

inspect = 1;
stop = 1;
if inspect == 1
    close all
end

% Step 0
% Assign site and do some "book keeping

if ~exist('SiteID','var')
    SiteID = 'BB';
end


if strcmp(SiteID,'BB')
    FirstYear = 2015;
    n_wells = 1;
elseif strcmp(SiteID,'BB2')
    FirstYear = 2019;
    n_wells = 1;
else
    FirstYear = 2023;
    n_wells = 6;
end
rng(42)
colormap = rand(n_wells,3);
 

% year is a method, but is overwritten as a variable in somewhere in the processing pipeline
if exist('year','var')
    year_var = year;
    clear year
    current_year = year(datetime);
    year = year_var;
else
    current_year = year(datetime);
end

% Step 0: Real all traces for all wells
% For each well - up to 9 traces:
% 1: manual WTD
% 2: manual Pipe Height
% 3: raw WTH from pressure transducer
% 4: cleaned/corrected WTH
% 5: Scaled WTD from WTH & manual observations
% 6: Estimated Bog Height from Pipe Height & Scaled WTD
% 7: Estimated WTD relative to Bog Surface (5-6)
for w=1:n_wells
    if w == 1
        [wtd,tv] = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTD_%i_1_1',w)); 
        DT = datetime(tv,"ConvertFrom","datenum");
        % 4 WTD variables per well:
        % 1: Manual from pipe top
        % 2: Automated scaled to pipe top
        % 3: Manual scaled to surface
        % 4: Automated scaled to surface
        WTD = NaN(size(wtd,1),n_wells,4);
        WTD(:,w,1)=wtd;

        
        WTH = NaN(size(wtd,1),n_wells,4);
        PH = NaN(size(wtd,1),n_wells,4);
        BH = NaN(size(wtd,1),n_wells,4);
        PH(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('Pipe_Height_%i_1_1',w));   
        WTH(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTH_%i_1_1',w));    

        WT_Data = NaN(size(wtd,1),n_wells,7);
        WT_Data(:,w,1)=wtd;
    else
        WT_Data(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTD_%i_1_1',w)); 
        WTD(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTD_%i_1_1',w)); 


    end

    PH(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('Pipe_Height_%i_1_1',w));   
    WTH(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTH_%i_1_1',w));    

    WT_Data(:,w,2) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('Pipe_Height_%i_1_1',w));   
    WT_Data(:,w,3) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTH_%i_1_1',w));    
    sprintf('WTD %i',w)
end

% Step1
% Import and clean manual observations Water Table Depth (WTD_manual) and Pipe Height (PH_manual) for BB1 & BB2 (extend to BBS once manual data is ready)
% Use line of best fit between WT and PH to filter out bad measurements: Bad measurement defined as residual error > |3std|
    

if inspect == 1
    figure
    hold on
    lgnd = cell(1,0);
end

for w=1:n_wells

    filter = 2;
    while filter > 0
        % Obs = and(isfinite(WT_Data(:,w,1)),isfinite(WT_Data(:,w,2)));
        % X = WT_Data(Obs,w,1);
        % y = WT_Data(Obs,w,2);
        Obs = and(isfinite(WTD(:,w,1)),isfinite(PH(:,w,1)));
        X = WTD(Obs,w,1);
        y = PH(Obs,w,1);
        [c,sig_a,r,y_cl95] = linreg(X,y);
        if filter == 2
            y_err = y-(X*c(1)+c(2));
            % Z-normalize errors and drop (z>2)
            [~,Flag] = Detect_Spikes(y_err,[0],[],2);
            tv_Flag = tv(Obs);
            [sharedvals,Drop_Flag] = intersect(tv,tv_Flag(Flag),"stable");
            % WT_Data(Drop_Flag,w,1)=NaN;
            % WT_Data(Drop_Flag,w,2)=NaN;
            WTD(Drop_Flag,w,1)=NaN;
            PH(Drop_Flag,w,1)=NaN;
            if inspect == 1 & filter == 2
                scatter(X,y,"MarkerEdgeColor","k","MarkerFaceColor",colormap(w,:))
                lgnd{size(lgnd,2)+1}=sprintf('Well %i; n=%i; X=%i dropped',w,length(y),sum(Flag));
            end
            if sum(Flag) > 0
                filter = filter - 1;
                if inspect == 1
                    plot(X(Flag),y(Flag),'x',"MarkerEdgeColor",colormap(w,:),'MarkerSize',12,'LineWidth',2,'HandleVisibility','off')
                end
            else
                filter = filter - 2;
            end
        else
            filter = filter - 1;
        end
    WTD(:,1,2) = PH(:,1,1)-WTD(:,1,1);
    end


    if inspect == 1
        mnmx=[min(X),max(X)];
        plot(mnmx,mnmx*c(1)+c(2),'Color',colormap(w,:))
        lgnd{size(lgnd,2)+1}=sprintf('R2 %0.2f; PH=%0.2fWTD+%0.2f',r^2,c(1),c(2));
    end
end

if inspect == 1
    
    legend(lgnd);
    ylabel(sprintf('Pipe Height (PH) cm',w));
    xlabel(sprintf('Water Table Depth (WTD) cm',w));
    title(sprintf('Flagging Manual Data for %s',SiteID));
    grid on
    hold off
end



% Step2
% Scale the automated WTH observations from the pressure transducer to the manual WTD observations with linear regression
% Use 24hr moving median for automated data to reduce noise

if strcmp(SiteID,'BB') 
    % For BB1: Correct the historic data prior before Oct 27, 2017
    % Data are broken into periods - Period 1 is most recent - good quality data, 2+ are historic w/ poor quality data
    Periods = [[datetime("2017-10-27 12:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("now")];
    [datetime("2017-01-20 13:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("2017-10-26 15:00:00","InputFormat","yy-MM-dd HH:mm:ss")];
    [datetime("2015-07-28 12:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("2017-01-01 00:00:00","InputFormat","yy-MM-dd HH:mm:ss")];
    ];

    Bad_Cal = [datetime("2015-07-28 12:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("2015-12-10 12:00:00","InputFormat","yy-MM-dd HH:mm:ss")];
    Correct = isbetween(DT,Bad_Cal(1),Bad_Cal(2));
    % Judging from historic logger programs - it looks like the calibration coefficient was updated on December 10th, 2015.
    % Correcting for it removes a systematic jump of approximately 14 cm in WTH on Dec 10th 2015
    CALIB_WaterLevel_Mult_bad = 39.68;
    CALIB_WaterLevel_Off_bad = 14.23;
    WTH_raw = (WTH(Correct,1,1)+CALIB_WaterLevel_Off_bad )/CALIB_WaterLevel_Mult_bad ;
    CALIB_WaterLevel_Mult_good    =  41.68;
    CALIB_WaterLevel_Off_good     =  3.23;
    WTH(:,1,2) = WTH(:,1,1);
    WTH(Correct,1,2) = (WTH_raw*CALIB_WaterLevel_Mult_good-CALIB_WaterLevel_Off_good);
    if inspect == 1
        figure
        hold on
        plot(DT,WTH(:,1,2))
        plot(DT(Correct),WTH(Correct,1,1))
        legend('WTH','Before Calibration Correction 2015-12-10')
        
        ylabel(sprintf('Water Table Height cm',w));
        xlabel(sprintf('Date'));
        title(sprintf('Flagging Manual Data for %s',SiteID));
        grid on
    end
else
    Periods = [[datetime("2019-01-01 12:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("now")];];
    WTH(:,1,2) = WTH(:,1,1);
end

Periods_index = cell(length(Periods),1);

LR_coefs = zeros(size(Periods,1),2);
for (period = 1:size(Periods,1))
    P = isbetween(DT,Periods(period,1),Periods(period,2));
    % Remove Very Large Magnitude Local (14-day) Deviations, Leave the rest of the noise in-tact - only applicable for "good data"
    WTH(P,1,2) = Detect_Spikes(WTH(P,1,2),[0],[48*14],[4]);
    if period > 1
        % For historic periods with poor quality data, use rolling median instead of instantaneous value
        WTH(P,1,2) = movmedian(WTH(P,1,2),48,'includenan');
    end

    F = and(isfinite(WTH(:,1,2)),isfinite(WTD(:,1,1)));
    Periods_index{period} = and(F,P);
    
    X = WTH(Periods_index{period},1,2);
    y = WTD(Periods_index{period},1,1);
    [a,sig_a,r,y_cl95] = linreg(X,y);
    LR_coefs(period,1) = a(1);
    LR_coefs(period,2) = a(2);
    if period == 1
        [LR_coefs_inverted,sig_a,r_inverted,y_cl95] = linreg(y,X);
    end

end

if inspect == 1
    figure
    hold on
    lgnd = cell(2,1);
    count = 1;
    for (period = 1:size(Periods,1))
        X = WTH(Periods_index{period},1,2);
        y = WTD(Periods_index{period},1,1);
        y_est = X*LR_coefs(period,1)+LR_coefs(period,2);
        Rsq2 = 1 - sum((y - y_est).^2)/sum((y - mean(y)).^2);
        RMSE = mean((y-y_est).^2).^.5;
        scatter(X,y)
        lgnd{count}=sprintf('%i Observations',sum(Periods_index{period}));
        count = count + 1;
        mnmx=[min(X),max(X)];
        plot(mnmx,mnmx*LR_coefs(period,1)+LR_coefs(period,2))
        lgnd{count}=sprintf('R2 %0.2f; RMSE %0.1f cm',Rsq2,RMSE);
        count = count + 1;
    end
    legend(lgnd);
    xlabel('Automated WTH');
    ylabel('Manual WTD');
    title(sprintf('Estimating Manual WTD at %s',SiteID));
    grid on
    hold off
end

P1 = isbetween(DT,Periods(1,1),Periods(1,2));

for (index = 1:size(Periods,1)),
    P = isbetween(DT,Periods(index,1),Periods(index,2));
    if index == 1
        WTD(P,1,3) = WTH(P,1,2)*LR_coefs(index,1)+LR_coefs(index,2);
    else
        WTD(P,1,3) = WTH(P,1,2)*LR_coefs(index,1)+LR_coefs(index,2);
        WTH(P,1,2) = WTD(P,1,3)*LR_coefs_inverted(1)+LR_coefs_inverted(2);
    end
end

if inspect == 1
    figure
    hold on
    lgnd = cell(3,1);
    plot(DT,WTH(:,1,1))
    plot(DT,WTH(:,1,2))
    plot(DT,WTD(:,1,3))
    legend('Raw WTH','Filtered/Corrected WTH','Scaled WTD')
    title(sprintf('Scaling WTH to WTD Data at %s',SiteID))
    hold off
    grid on
    
    if strcmp(SiteID,'BB')
        % Validate by estimating manual observations for P2 & P3 from WTD_1_1_2 using LR_coefs from P1
        Correction_period = Periods_index{2}|Periods_index{3};
        y = WTD(Correction_period,1,1);
        y_est = WTD(Correction_period,1,3);
        Rsq2 = 1 - sum((y - y_est).^2)/sum((y - mean(y)).^2);
        RMSE = mean((y-y_est).^2).^.5;

        figure
        scatter(y,y_est)
        legend(sprintf('R2 %0.2f; RMSE %0.2f cm: n = %i',r^2,RMSE,size(y,1)));
        xlabel('Manual WTD');
        ylabel('Estimated Manual WTD');
        title(sprintf('Validating the WTD correction for historic periods at %s',SiteID))
        grid on
    end
end



% Step 3
% Working with Bog Height
% Option 1 ignores the snow depth data and just uses pipe height data

Comp = and(isfinite(WTD(:,1,3)),isfinite(PH(:,1,1)));
X = WTD(Comp,1,3);
y = PH(Comp,1,1);
[ph_fit,sig_a,r,y_cl95] = linreg(X,y);
yCalc1 = X*ph_fit(1)+ph_fit(2);
RMSE = mean((y -yCalc1).^2).^.5;

if inspect == 1
    figure
    hold on
    scatter(X,y)
    mnmx=[min(X),max(X)];
    plot(mnmx,mnmx*ph_fit(1)+ph_fit(2))
    legend('Observations',sprintf('Linear Regression: R2 %0.2f',r^2));
    xlabel('Scaled WTD');
    ylabel('Manual PH PH');
    title('Validating the correction');
    grid on
end

% Estimate PH trace then use it to calculate scaled WTD referenced to surface

PH(:,1,2) = WTD(:,1,3)*ph_fit(1)+ph_fit(2);
WTD(:,1,4) = PH(:,1,2)-WTD(:,1,3);



if inspect == 1
    figure
    hold on
    plot(DT,WTD(:,1,4))
    plot(DT,WTD(:,1,2),'ko')
    % plot(DT,WTD_Joe)
    yline(0)
    % legend('Estimated Water Table Depth','Manual Water Table Depth','Water Table relative to mean January Bog Surface','Bog Surface');
    xlabel('Date');
    ylabel('Scaled WTD');
    title('Water Table Depth (relative to surface)');
    grid on
end





if stop == 2






% WTH_1_1_1 = WTH_Temp*NaN;
% WTH_rolling = WTH_1_1_1;
% WTD_1_1_2 = WTH_1_1_1;
% LR_coefs = zeros(size(Periods,1),2);
% for (period = 1:size(Periods,1))
%     P = isbetween(DT,Periods(period,1),Periods(period,2));
%     % Remove Very Large Magnitude Local (14-day) Deviations, Leave the rest of the noise in-tact - only applicable for "good data"
%     WTH_1_1_1(P) = Detect_Spikes(WTH_Temp(P),[0],[48*14],[4]);
%     WTH_rolling(P) = movmedian(WTH_1_1_1(P),48,'includenan');
    
%     F = and(isfinite(WTH_rolling),isfinite(WTD_manual));
%     Periods_index{period} = and(F,P);
    
%     if period == 1
%         X = WTH_Temp(Periods_index{period});
%     else
%         X = WTH_rolling(Periods_index{period});
%     end
%     y = WTD_manual(Periods_index{period});
%     [a,sig_a,r,y_cl95] = linreg(X,y);
%     LR_coefs(period,1) = a(1);
%     LR_coefs(period,2) = a(2);
%     if period == 1
%         [LR_coefs_inverted,sig_a,r_inverted,y_cl95] = linreg(y,X);
%     end

% end

% if inspect == 1
%     figure
%     hold on
%     lgnd = cell(2,1);
%     count = 1;
%     for (period = 1:size(Periods,1)),
%         if period>1
%             X = WTH_rolling(Periods_index{period});
%         else
%             X = WTH_Temp(Periods_index{period});
%         end
%         y = WTD_manual(Periods_index{period});
%         y_est = X*LR_coefs(period,1)+LR_coefs(period,2);
%         Rsq2 = 1 - sum((y - y_est).^2)/sum((y - mean(y)).^2);
%         RMSE = mean((y-y_est).^2).^.5;
%         scatter(X,y)
%         lgnd{count}=sprintf('%i Observations',sum(Periods_index{period}));
%         count = count + 1;
%         mnmx=[min(X),max(X)];
%         plot(mnmx,mnmx*LR_coefs(period,1)+LR_coefs(period,2))
%         lgnd{count}=sprintf('R2 %0.2f; RMSE %0.1f cm',Rsq2,RMSE);
%         count = count + 1;
%     end
%     legend(lgnd);
%     xlabel('Automated WTH');
%     ylabel('Manual WTD');
%     title(sprintf('Estimating Manual WTD at %s',SiteID));
%     grid on
%     hold off
% end

% P1 = isbetween(DT,Periods(1,1),Periods(1,2));

% for (index = 1:size(Periods,1)),
%     P = isbetween(DT,Periods(index,1),Periods(index,2));
%     if index == 1
%         WTD_1_1_2(P) = WTH_1_1_1(P)*LR_coefs(index,1)+LR_coefs(index,2);
%     else
%         WTD_1_1_2(P) = WTH_rolling(P)*LR_coefs(index,1)+LR_coefs(index,2);
%         WTH_1_1_1(P) = WTD_1_1_2(P)*LR_coefs_inverted(1)+LR_coefs_inverted(2);
%     end
% end

% if inspect == 1
%     figure
%     hold on
%     lgnd = cell(3,1);
%     P1 = and(isfinite(WTD_1_1_2),isbetween(DT,Periods(1,1),Periods(1,2)));
%     plot(DT,WTD_1_1_2)
%     plot(DT,WTH_1_1_1)
%     plot(DT,WTH_Temp)
%     legend('Scaled WTD','Filtered/Corrected WTH','Raw WTH')
%     title(sprintf('Scaling WTH to WTD Data at %s',SiteID))
%     hold off
%     grid on
    
%     if strcmp(SiteID,'BB')
%         % Validate by estimating manual observations for P2 & P3 from WTD_1_1_2 using LR_coefs from P1
%         Correction_period = Periods_index{2}|Periods_index{3};
%         y = WTD_manual(Correction_period);
%         y_est = WTD_1_1_2(Correction_period);
%         Rsq2 = 1 - sum((y - y_est).^2)/sum((y - mean(y)).^2);
%         RMSE = mean((y-y_est).^2).^.5;

%         figure
%         scatter(y,y_est)
%         legend(sprintf('R2 %0.2f; RMSE %0.2f cm: n = %i',r^2,RMSE,size(y,1)));
%         xlabel('Manual WTD');
%         ylabel('Estimated Manual WTD');
%         title(sprintf('Validating the WTD correction for historic periods at %s',SiteID))
%         grid on
%     end
% end



















% if inspect == 1
%     figure
%     hold on
%     lgnd = cell(1,0);
% end







    

% for w=n_wells:-1:1
%     [WTD_manual,tv] = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTD_%i_1_1',w));   
%     [PH_manual,~] = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('Pipe_Height_%i_1_1',w));   
%     sprintf('WTD %i',w)

%     filter = 2;
%     while filter > 0
%         Obs = and(isfinite(WTD_manual),isfinite(PH_manual));
%         X = WTD_manual(Obs);
%         y = PH_manual(Obs);
%         [c,sig_a,r,y_cl95] = linreg(X,y);
%         if filter == 2
%             y_err = y-(X*c(1)+c(2));
%             % Z-normalize errors and drop (z>2)
%             [~,Flag] = Detect_Spikes(y_err,[0],[],2);
%             tv_Flag = tv(Obs);
%             [sharedvals,Drop_Flag] = intersect(tv,tv_Flag(Flag),"stable");
%             PH_manual(Drop_Flag)=NaN;
%             WTD_manual(Drop_Flag)=NaN;
%             if inspect == 1 & filter == 2
%                 scatter(X,y,"MarkerEdgeColor","k","MarkerFaceColor",colormap(w,:))
%                 lgnd{size(lgnd,2)+1}=sprintf('Well %i; n=%i; X=%i dropped',w,length(y),sum(Flag));
%             end
%             if sum(Flag) > 0
%                 filter = filter - 1;
%                 if inspect == 1
%                     plot(X(Flag),y(Flag),'x',"MarkerEdgeColor",colormap(w,:),'MarkerSize',12,'LineWidth',2,'HandleVisibility','off')
%                 end
%             else
%                 filter = filter - 2;
%             end
%         else
%             filter = filter - 1;
%         end
%     end


%     if inspect == 1
%         mnmx=[min(X),max(X)];
%         plot(mnmx,mnmx*c(1)+c(2),'Color',colormap(w,:))
%         lgnd{size(lgnd,2)+1}=sprintf('R2 %0.2f; PH=%0.2fWTD+%0.2f',r^2,c(1),c(2));
%     end
% end

% if inspect == 1
    
%     legend(lgnd);
%     ylabel(sprintf('Pipe Height (PH) cm',w));
%     xlabel(sprintf('Water Table Depth (WTD) cm',w));
%     title(sprintf('Flagging Manual Data for %s',SiteID));
%     grid on
%     hold off
% end

% % Step2
% % Scale the automated WTH observations from the pressure transducer to the manual WTD observations with linear regression
% % Use 24hr moving median for automated data to reduce noise

% if strcmp(SiteID,'BB') 
%     % For BB1: Correct the historic data prior before Oct 27, 2017
%     % Data are broken into periods - Period 1 is most recent - good quality data, 2+ are historic w/ poor quality data
%     Periods = [[datetime("2017-10-27 12:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("now")];
%     [datetime("2017-01-20 13:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("2017-10-26 15:00:00","InputFormat","yy-MM-dd HH:mm:ss")];
%     [datetime("2015-12-11 00:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("2017-01-01 00:00:00","InputFormat","yy-MM-dd HH:mm:ss")];
%     ];
% else
%     Periods = [[datetime("2020-01-01 12:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("now")];];
% end

% Periods_index = cell(length(Periods),1);
% [WTH_Temp,TV] = read_db([FirstYear:current_year],SiteID,'Met/Clean',['WTH_1_1_1']);
% WTH_1_1_1 = WTH_Temp*NaN;
% WTH_rolling = WTH_1_1_1;
% WTD_1_1_2 = WTH_1_1_1;
% LR_coefs = zeros(size(Periods,1),2);
% for (period = 1:size(Periods,1))
%     P = isbetween(DT,Periods(period,1),Periods(period,2));
%     % Remove Very Large Magnitude Local (14-day) Deviations, Leave the rest of the noise in-tact - only applicable for "good data"
%     WTH_1_1_1(P) = Detect_Spikes(WTH_Temp(P),[0],[48*14],[4]);
%     WTH_rolling(P) = movmedian(WTH_1_1_1(P),48,'includenan');
    
%     F = and(isfinite(WTH_rolling),isfinite(WTD_manual));
%     Periods_index{period} = and(F,P);
    
%     if period == 1
%         X = WTH_Temp(Periods_index{period});
%     else
%         X = WTH_rolling(Periods_index{period});
%     end
%     y = WTD_manual(Periods_index{period});
%     [a,sig_a,r,y_cl95] = linreg(X,y);
%     LR_coefs(period,1) = a(1);
%     LR_coefs(period,2) = a(2);
%     if period == 1
%         [LR_coefs_inverted,sig_a,r_inverted,y_cl95] = linreg(y,X);
%     end

% end

% if inspect == 1
%     figure
%     hold on
%     lgnd = cell(2,1);
%     count = 1;
%     for (period = 1:size(Periods,1)),
%         if period>1
%             X = WTH_rolling(Periods_index{period});
%         else
%             X = WTH_Temp(Periods_index{period});
%         end
%         y = WTD_manual(Periods_index{period});
%         y_est = X*LR_coefs(period,1)+LR_coefs(period,2);
%         Rsq2 = 1 - sum((y - y_est).^2)/sum((y - mean(y)).^2);
%         RMSE = mean((y-y_est).^2).^.5;
%         scatter(X,y)
%         lgnd{count}=sprintf('%i Observations',sum(Periods_index{period}));
%         count = count + 1;
%         mnmx=[min(X),max(X)];
%         plot(mnmx,mnmx*LR_coefs(period,1)+LR_coefs(period,2))
%         lgnd{count}=sprintf('R2 %0.2f; RMSE %0.1f cm',Rsq2,RMSE);
%         count = count + 1;
%     end
%     legend(lgnd);
%     xlabel('Automated WTH');
%     ylabel('Manual WTD');
%     title(sprintf('Estimating Manual WTD at %s',SiteID));
%     grid on
%     hold off
% end

% P1 = isbetween(DT,Periods(1,1),Periods(1,2));

% for (index = 1:size(Periods,1)),
%     P = isbetween(DT,Periods(index,1),Periods(index,2));
%     if index == 1
%         WTD_1_1_2(P) = WTH_1_1_1(P)*LR_coefs(index,1)+LR_coefs(index,2);
%     else
%         WTD_1_1_2(P) = WTH_rolling(P)*LR_coefs(index,1)+LR_coefs(index,2);
%         WTH_1_1_1(P) = WTD_1_1_2(P)*LR_coefs_inverted(1)+LR_coefs_inverted(2);
%     end
% end

% if inspect == 1
%     figure
%     hold on
%     lgnd = cell(3,1);
%     P1 = and(isfinite(WTD_1_1_2),isbetween(DT,Periods(1,1),Periods(1,2)));
%     plot(DT,WTD_1_1_2)
%     plot(DT,WTH_1_1_1)
%     plot(DT,WTH_Temp)
%     legend('Scaled WTD','Filtered/Corrected WTH','Raw WTH')
%     title(sprintf('Scaling WTH to WTD Data at %s',SiteID))
%     hold off
%     grid on
    
%     if strcmp(SiteID,'BB')
%         % Validate by estimating manual observations for P2 & P3 from WTD_1_1_2 using LR_coefs from P1
%         Correction_period = Periods_index{2}|Periods_index{3};
%         y = WTD_manual(Correction_period);
%         y_est = WTD_1_1_2(Correction_period);
%         Rsq2 = 1 - sum((y - y_est).^2)/sum((y - mean(y)).^2);
%         RMSE = mean((y-y_est).^2).^.5;

%         figure
%         scatter(y,y_est)
%         legend(sprintf('R2 %0.2f; RMSE %0.2f cm: n = %i',r^2,RMSE,size(y,1)));
%         xlabel('Manual WTD');
%         ylabel('Estimated Manual WTD');
%         title(sprintf('Validating the WTD correction for historic periods at %s',SiteID))
%         grid on
%     end
% end



% % Step 3
% % Working with Bog Height
% % Option 1 ignores the snow depth data and just uses pipe height data

% % 3.1
% % Reconstruct the historic WTH data (for the periods with flawed observations)
% % Use best fit line from Step 2.1 to scale to manual observation
% % Then use best fit line from Step 2.2 to scale to Corrupted Periods

% Comp = and(isfinite(WTD_1_1_2),isfinite(PH_manual));
% X = WTD_1_1_2(Comp);
% y = PH_manual(Comp);
% [ph_fit,sig_a,r,y_cl95] = linreg(X,y);
% yCalc1 = X*ph_fit(1)+ph_fit(2);
% RMSE = mean((y -yCalc1).^2).^.5;

% if inspect == 1
%     figure
%     hold on
%     scatter(X,y)
%     mnmx=[min(X),max(X)];
%     plot(mnmx,mnmx*ph_fit(1)+ph_fit(2))
%     legend('Observations',sprintf('Linear Regression: R2 %0.2f',r^2));
%     xlabel('Scaled WTD');
%     ylabel('Manual PH');
%     title('Validating the correction');
%     grid on
% end



% % Estimate PH trace then use it to calculate scaled WTD referenced to surface

% PH_1_1_1 = WTD_1_1_2*ph_fit(1)+ph_fit(2);
% WTD_1_1_2 = PH_1_1_1-WTD_1_1_2;

% WTD_manual = PH_manual-WTD_manual;


% if inspect == 1
%     figure
%     hold on
%     plot(DT,WTD_1_1_2)
%     plot(DT,WTD_manual,'ko')
%     % plot(DT,WTD_Joe)
%     yline(0)
%     % legend('Estimated Water Table Depth','Manual Water Table Depth','Water Table relative to mean January Bog Surface','Bog Surface');
%     xlabel('Date');
%     ylabel('Scaled WTD');
%     title('Water Table Depth (relative to surface)');
%     grid on
% end

if strcmp(SiteID,'BB')

% Step 3.2
% Estimate Bog_Height from snow-depth sensor at BB1 - this requires the curve fitting extension
% Idea is that bog height will follow a signmoid relationship with WTD
% Sigmoid curve performs a bit better than linear regression, but also requires more resources
% If using site other than BB1, will need to read BB1 WTD

[BH_Temp,TV_BH] = read_db([2018:current_year],'BB','Met/Clean','Bog_Height');
DT_BH = datetime(TV_BH,"ConvertFrom","datenum");
[sharedvals,idx_BH,idx_WT] = intersect(TV_BH,TV,"stable");
BH_raw = WTH_Temp*NaN;
BH_raw(idx_WT) = BH_Temp;
% Using a spike filter flag z-normalized raw data (|z|>3) and nth order derivatives (|z|>1)
[~,Flagged_values] = Detect_Spikes(BH_raw,[0],48*7,[3]);
[~,Flagged_derivatives] = Detect_Spikes(BH_raw,[1 2],[],[1]);
Spike_Flag = Flagged_values|Flagged_derivatives;

% Use stage 1 SW data to identify and filter out probable snow events
% Calculate half-hourly albedo (restricted to 10:00-14:00) then fill using
% moving 24-hour maximum and filter Bog Height where Albedo > .4
[SW_IN,TV] = read_db([2018:current_year],'BB','Met/Clean','SW_IN_1_1_1');
[SW_OUT,~] = read_db([2018:current_year],'BB','Met/Clean','SW_OUT_1_1_1');
Albedo = SW_OUT./SW_IN;
Albedo(Albedo>1) = 1;
Albedo(hour(DT)<10) = NaN;
Albedo(hour(DT)>14) = NaN;
Albedo = movmax(Albedo,48,'omitnan');
Snow = logical(ones(size(Albedo)));
Snow(Albedo<.4) = 0;
Flag = Snow|Spike_Flag;
BH_raw(Flag) = NaN;

% Fit snow depth data to a sigmoid curve
Comp = and(isfinite(WTD_1_1_2),isfinite(BH_raw));
X = movmean(WTD_1_1_2,1*48,'omitnan');
x = X(Comp);
y = BH_raw(Comp);
sigEq = fittype(@(a, b, c, x) a./(1+exp(b*x+c))+min(BH_raw)*.95,'independent', {'x'},'dependent', 'y');

Coefficients = 'WT_and_BH_Correction_Coefficents.mat';
if isfile(Coefficients)
    load(Coefficients)
    refit = 1;
else
    refit = 1
    BH_coeffs = [max(y)-min(y) -.1 std(x)];
end

%Re-fit once a month on the 2nd
if day(datetime(now,'ConvertFrom','datenum'))==2 & timeofday(datetime(now,'ConvertFrom','datenum'))>'23:00:00'
    refit = 1;
end

if refit == 1
    figure;
    hold on;
    f=fit(x, y ,sigEq,'Start', BH_coeffs);
    scatter(x,y);
    scatter(x,f(x));
    xlabel('Scaled WTD');
    ylabel('Estimated BH');
    title('Sigmoid Fit to Estimate Continuous BH');
    if isequal(coeffvalues(f),BH_coeffs)
    else
        BH_coeffs = coeffvalues(f);
        sprintf('Update coeficients')
        save(Coefficients,'BH_coeffs')
    end
    grid on;
end

if inspect == 1
    yCalc1 = sigEq(BH_coeffs(1),BH_coeffs(2),BH_coeffs(3),x);
    Rsq1 = 1 - sum((y - yCalc1).^2)/sum((y - mean(y)).^2);
    RMSE = mean((y -yCalc1).^2).^.5;
    figure 
    hold on
    lgnd = cell(1,1);
    scatter(y,yCalc1)
    plot([min(y):max(y)],[min(y):max(y)])
    grid on
    lgnd{1}=sprintf('R2 %0.2f; RMSE %0.2f: n = %i',Rsq1,RMSE,size(y,1));
    lgnd{2}=sprintf('1:1');
    legend(lgnd);
    xlabel('Observed BH');
    ylabel('Estimated BH');
        
end

BH_est = sigEq(BH_coeffs(1),BH_coeffs(2),BH_coeffs(3),X);
if inspect == 1
    DT_BH = datetime(TV_BH,"ConvertFrom","datenum");
    figure;
    hold on;
    lgnd = cell(1,1);
    plot(DT_BH,BH_Temp,'Color',[0,0.7,0.9]);
    lgnd{1}=sprintf('Data In');
    plot(DT,BH_raw,'b');
    lgnd{2}=sprintf('Data Out');
    plot(DT,BH_est,'k')
    lgnd{3}=sprintf('Estimated Bog Height');
    legend(lgnd);
    title(sprintf('Filtering'))
    grid on
end

% Next step is to compare that to BH


% Compare Bog Height (raw and estimated) to observed pipe height
Recent = and(isfinite(PH_manual),isfinite(BH_raw));
Historic = and(isfinite(PH_manual),isfinite(BH_est));
Historic = and(Historic,~Recent);

X = PH_manual(Recent);
Xhist= PH_manual(Historic);
y1_obs = BH_raw(Recent);
y1_est = BH_est(Recent);
y2 = BH_est(Historic);
[PH_fit_BH_obs,sig_a,r_raw,y_cl95] = linreg(X,y1_obs);
[PH_fit_BH_est1,sig_a,r_est,y_cl95] = linreg(X,y1_est);
[PH_fit_BH_est2,sig_a,r_hist,y_cl95] = linreg(Xhist,y2);

if inspect == 1
    figure
    hold on
    lgnd = cell(1,1);
    scatter(X,y1_obs,'xb')
    lgnd{1}=sprintf('Observed: n = %i; R2 %0.2f',size(y1_obs,1),r_raw^2);
    scatter(X,y1_est,'ob')
    lgnd{2}=sprintf('Estimated: n = %i; R2 %0.2f',size(y1_est,1),r_est^2);
    scatter(Xhist,y2,'or')
    lgnd{3}=sprintf('Historic Estimates: n = %i; R2 %0.2f',size(y1_est,1),r_hist^2);
    xlabel('Manual PH');
    ylabel('BH');
    title('Pipe Height vs. Bog Height');
    legend(lgnd);
    grid on
    hold off
end

% Step 7 Reference the data to a known point
GNS_Survey_Date = datetime("2020-03-18 12:00:00","InputFormat","yy-MM-dd HH:mm:ss")

Bog_Height_Survey = 345.2094;
Pipe_Height_Survey = 447.3047;
PH_reff = Pipe_Height_Survey-Bog_Height_Survey;
Comp = and(isfinite(PH_manual),isfinite(WTD_1_1_2));

X = WTD_1_1_2(Comp);
y = PH_manual(Comp);

[PH_fit_WTH,sig_a,r,y_cl95] = linreg(X,y);

WT_reff = PH_fit_WTH(1)*WTD_1_1_2+PH_fit_WTH(2);

r^2

if inspect == 1
    figure
    hold on
    plot(DT,WTD_1_1_2)
    yline(0)
    legend('Water Table Depth (PH-WTD)','Surface');
    xlabel('Date');
    ylabel('Scaled WTD');
    title('Validating the correction');
    grid on
end



% out_path = 'C:\Database\2023\BB\Clean\SecondStage';
% file_opts.out_path = out_path;
% file_opts.format   = 'bnc';
% file_opts.days     = [0 367]; % This ensures that the whole trace is exported!
% [Flow_Rate,TV] = read_db([2023],'BB','Flux','flowrate_mean');
% trc.data = Flow_Rate;
% trc.timeVector = TV;
% trc.DOY= TV - datenum(year,1,0);
% trc.DOY= trace_in.DOY - 8/24;
% trc.variableName = 'Test';
% trc.stage = 'second';
% trace_export(file_opts,trc)
% DT = datetime(TV,"ConvertFrom","datenum");
% if exist('year','var')
% year_var = year;
% clear year
% DT_year = year(DT);
% year = year_var;
% else
% DT_year = year(DT);
% end






end


end

function [data_out,Z_Flag]=Detect_Spikes(data_in,order,window,z_thresh,inspect)
    % This function filters outliers using a z-normalized moving window
    % It fitlers the data by deviation from mean, slope (first deriviative), and curvature (second derivative), etc.
    
    % Parameters:
    % data_in - the trace to be filtered
    % tv_in - the time vector of the trace to be filtered
    % order - order of derivatives to be calculated; 0 no derivative, 1,2, ... are 1st, 2nd, etc.
    % window - optional rolling window over which to apply the filter (defaults to length of the data - ie no moving window)
    % z - the scaling value for fitering; a larger z is less restrictive (defalut z = 3)

    arg_default('order',0);
    arg_default('window',length(data_in)*2);
    if window<1
        window=length(data_in)*2;
    end
    arg_default('z_thresh',3);
    arg_default('inspect',2);

%     DT = datetime(tv_in,"ConvertFrom","datenum");
    
    Collapsed = isnan(data_in);
    dropped = zeros(length(order),1);
    Keep = logical(ones(length(data_in),length(order)));
    Drop = logical(zeros(length(data_in),length(order)));
    Keep(Collapsed,1:end)=0;

    j = [0];
    k = [0];
    if inspect == 1
        figure
        hold on
        lgnd = cell(1,1);
    end
    for i=1:length(order)
        d = order(i);
        ix = Keep(:,i);
        if d > 0
            y = [NaN(ceil(d/2),1); diff(data_in(ix),d); NaN(floor(d/2),1)];
        else
            y = data_in(ix);
        end
        u = movmean(y,window,'omitnan');%,'SamplePoints',tv_in(ix));
        s = movstd(y,window,'omitnan');%,'SamplePoints',tv_in(ix));
        z_norm = (y-u)./s;
        if length(z_thresh)>1
            z_range = [z_thresh(1),z_thresh(end)];
        else
            z_range = [-z_thresh,z_thresh];
        end
        if inspect == 1
            lgnd{i}=sprintf('Normalized nth derivative; n=%i',d);
        end
        flag = and(z_norm>z_range(1),z_norm<z_range(2));
        Keep(ix,i) = flag;
        Drop(ix,i) = ~flag;
    end
    Z_Flag = min(Drop,[],2);
    data_out = data_in;
    data_out(Z_Flag)=NaN;
end

