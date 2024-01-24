% function [tv] = BB_WTD_Correction(clean_tv,inspect);

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

% Derived Variables & log files
% No default writing


current_year = year(datetime);
arg_default('inspect',0);
if ~exist('db_ini','var')
    db_ini = 'C:/Database';
end
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
    [Bog_Height,Snow_Depth,Bog_Height_tv] = BB_BH_Correction();
else
    if strcmp(SiteID,'BB2')
        FirstYear = 2019;
        n_wells = 1;
    else
        FirstYear = 2023;
        n_wells = 6;
    end
    [Bog_Height,Bog_Height_tv] = read_db([FirstYear:current_year],SiteID,'Clean/SecondStage','Bog_Height'); 
end

rng(69)
colormap = rand(n_wells,3);
 

% Step 0: Real all traces for all wells
% For each well - we'll have multiple traces:
% WTD:
%   Manual: raw WTD (from pipe top) and manual corrected (adjusted to surface)
%   Continuous: Scaled data from the pressure transducer (from pipe top) and (adjusted to surface)
% Pipe Height: 
%   Manual Pipe Height
%   Estimated continuous pipe height
% WTH:
%   Raw & Corrected Water Table height above Pressure Transducer
% BH:
%   Raw & Corrected Bog Height from Snow Depth Sensor


% Step 7 Reference the data to a known point
GNS_Survey_Date = datetime("2020-03-18 12:00:00","InputFormat","yy-MM-dd HH:mm:ss");

Pipe_Height_Survey = 447.3047;
% Comp = and(isfinite(PH(:,1,1)),isfinite(WTD(:,1,4)));

for w=1:n_wells
    if w == 1
        [wtd,tv] = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTD_%i_1_1',w)); 
        DT = datetime(tv,"ConvertFrom","datenum");
        WTD = NaN(size(wtd,1),n_wells,3);
        WTD(:,w,1)=wtd;
        
        PH = NaN(size(wtd,1),n_wells,2);
        PH(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('Pipe_Height_%i_1_1',w));   

        WTH = NaN(size(wtd,1),n_wells,3);
        WTH(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTH_%i_1_1',w));    
        
        BH = NaN(size(wtd,1),n_wells,2);
        [~,BH_index] = intersect(tv,Bog_Height_tv,"stable");
        BH(BH_index,w,1) = Bog_Height;

        TA = NaN(size(wtd,1),n_wells,1);
        TA(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean','TA_1_1_1');    

        
        Precip = NaN(size(wtd,1),n_wells,2);
        if strcmp(SiteID,'BBS')
            Gauge = 'BB'
        else
            Gauge = SiteID
        end
        Precip(:,w,1) = read_db([FirstYear:current_year],Gauge,'Met/Clean','P_1_1_1');    

    else
        WTD(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTD_%i_1_1',w)); 
        PH(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('Pipe_Height_%i_1_1',w));   
        wth = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTH_%i_1_1',w));    
        if sum(isfinite(wth))==0
            WTH(:,w,1) = WTH(:,w-1,1);
        else
            WTH(:,w,1) = wth;
        end
        BH(BH_index,w,1) = Bog_Height;
        Precip(:,w,1) = Precip(:,w-1,1);
    end

    PH(:,w,1) = Pipe_Height_Survey-PH(:,w,1);
    WTD(:,w,1) = Pipe_Height_Survey-WTD(:,w,1);

    disp(sprintf('Processing WT Data at %s',SiteID));
end

% Step1
% Import and clean manual observations Water Table Depth (WTD_manual) and Pipe Height (PH(:,1,1)) for BB1 & BB2 (extend to BBS once manual data is ready)
% Use line of best fit between WT and PH to filter out bad measurements: Bad measurement defined as residual error > |3std|
    
if inspect == 1
    figure
    hold on
    lgnd = cell(1,0);
end

for w=1:n_wells

    filter = 2;
    while filter > 0
        Obs = and(isfinite(WTD(:,w,1)),isfinite(PH(:,w,1)));
        X = WTD(Obs,w,1);
        y = PH(Obs,w,1);
        [ph_correction,sig_a,r,y_cl95] = linreg(X,y);
        if filter == 2
            y_err = y-(X*ph_correction(1)+ph_correction(2));
            % Z-normalize errors and drop (z>2)
            Z = abs((y_err-mean(y_err))/std(y_err));
            Flag = logical(zeros(size(Z)));
            Flag(Z>2)=1;
            tv_Flag = tv(Obs);
            [sharedvals,Drop_Flag] = intersect(tv,tv_Flag(Flag),"stable");
            % WTD(Drop_Flag,w,1)=NaN;
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
    end
    PH(:,w,2) = PH(:,w,1);
    PH(isnan(PH(:,w,1)),w,2) = WTD(isnan(PH(:,w,1)),w,1)*ph_correction(1)+ph_correction(2);

    WTD(:,w,2) = PH(:,w,2)-WTD(:,w,1);

    if inspect == 1
        mnmx=[min(X),max(X)];
        plot(mnmx,mnmx*ph_correction(1)+ph_correction(2),'Color',colormap(w,:))
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
    [datetime("2017-01-20 13:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("2017-10-26 23:00:00","InputFormat","yy-MM-dd HH:mm:ss")];
    [datetime("2015-07-28 12:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("2017-01-01 00:00:00","InputFormat","yy-MM-dd HH:mm:ss")];
    ];
else
    Periods = [[datetime("2019-01-01 12:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("now")];];
end

Periods_index = cell(length(Periods),1);


if inspect == 1
    figure
    hold on
    lgnd = cell(2,1);
    count = 1;
end

for w=1:n_wells
        
    LR_coefs = zeros(size(Periods,1),2,n_wells);
    for (period = 1:size(Periods,1))
        P = isbetween(DT,Periods(period,1),Periods(period,2));
        % Remove Spikes - for good data periods, filter out jump/drops, for bad periods, filter out very large local deviations then get the moving 48-hr median
        if period == 1
            WTH(P,w,2) = SpikeFilter(WTH(P,w,1),tv(P),1,[-.5 2],"natural");
        else 
            WTH(P,w,2) = SpikeFilter(WTH(P,w,1),tv(P),0,4,"z-score",14);
            WTH(P,w,2) = movmedian(WTH(P,w,2),48,'includenan');
        end

        F = and(isfinite(WTH(:,1,2)),isfinite(WTD(:,1,1)));
        P = and(F,P);
        
        X = WTH(P,w,2);
        y = WTD(P,w,1);
        [a,sig_a,r,y_cl95] = linreg(X,y);
        LR_coefs(period,1,w) = a(1);
        LR_coefs(period,2,w) = a(2);
        if period == 1
            [LR_coefs_inverted,sig_a,r_inverted,y_cl95] = linreg(y,X);
        end

        if inspect == 1
            y_est = X*LR_coefs(period,1,w)+LR_coefs(period,2,w);
            Rsq2 = 1 - sum((y - y_est).^2)/sum((y - mean(y)).^2);
            RMSE = mean((y-y_est).^2).^.5;
            scatter(X,y)
            lgnd{count}=sprintf('%i Observations',sum(P));
            count = count + 1;
            mnmx=[min(X),max(X)];
            plot(mnmx,mnmx*LR_coefs(period,1,w)+LR_coefs(period,2,w))
            lgnd{count}=sprintf('R2 %0.2f; RMSE %0.1f cm',Rsq2,RMSE);
            count = count + 1;
        end
    end
    if inspect == 1
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
            WTH(P,w,3) = WTH(P,w,2)*LR_coefs(index,1,w)+LR_coefs(index,2,w);
        else
            WTH(P,w,3) = WTH(P,w,2)*LR_coefs(index,1,w)+LR_coefs(index,2,w);
            WTH(P,w,2) = WTH(P,w,3)*LR_coefs_inverted(1)+LR_coefs_inverted(2);
        end
    end
    
end

for w=1:n_wells

    
    Comp = and(isfinite(BH(:,w,1)),isfinite(PH(:,w,2)));
    X = BH(Comp,w,1);
    y = PH(Comp,w,2);
    [ph_fit,sig_a,r,y_cl95] = linreg(X,y);
    yCalc1 = X*ph_fit(1)+ph_fit(2);
    RMSE = mean((y -yCalc1).^2).^.5;
    
    BH(:,w,2) = BH(:,w,1)*ph_fit(1)+ph_fit(2);
    
    if inspect == 1
        figure
        hold on
        scatter(X,y)
        mnmx=[min(X),max(X)];
        plot(mnmx,mnmx*ph_fit(1)+ph_fit(2))
        legend(sprintf('Observations: n = %i',length(X)),sprintf('Linear Regression: R2 %0.2f',r^2));
        xlabel('Scaled BH');
        ylabel('Manual PH');
        title('Validating the correction');
        grid on
    end

    WTH(:,w,4)=movmean(WTH(:,w,3),[48*7,0],'omitnan');

    TA = movmean(TA,[48*30,0],'omitnan');
    Precip_sum = movsum(Precip(:,w,1),[48*30,0],'omitnan');
    DOY = day(DT, 'dayofyear');
    Year = year(DT);
    Comp = and(isfinite(WTH(:,w,3)),isfinite(BH(:,w,2)));
    X = [ones(length(tv(Comp)),1),WTH(Comp,w,4),TA(Comp),Precip_sum(Comp)];
    y = BH(Comp,w,2);

    b = X\y;
    BH(:,w,3) = b(1)+WTH(:,w,4)*b(2)+TA*b(3)+Precip_sum*b(4);
    yCalc1 = BH(Comp,w,3);
    RMSE = mean((y -yCalc1).^2).^.5;
    sprintf('%.7f\n',b)
    RMSE
    Rsq1 = 1 - sum((y - yCalc1).^2)/sum((y - mean(y)).^2)

    figure
    hold on
    scatter(y,yCalc1)
    plot([min(y),max(y)],[min(y),max(y)])
    ylim([min(y),max(y)])
    xlim([min(y),max(y)])

    
    if inspect == 0
        figure
        hold on
        % plot(DT,WTH(:,w,1))
        % plot(DT,WTH(:,w,2))
        plot(DT,WTH(:,w,3),'b')
        plot(DT,BH(:,w,3),'r')
        plot(DT,BH(:,w,2),'k')
        plot(DT,PH(:,w,2),'ko')
        plot(DT,PH(:,w,1),'bo')
        legend('Scaled WTH','Bog Height (at BB1 well) Est','Bog Height (at BB1 well)','Gap-filled Pipe Height','Raw Pipe Height')
        title(sprintf('Scaling WTH to WTD Data at %s',SiteID))
        hold off
        grid on
        
    end

end


WTD_coeffs = setFolderSeparator(fullfile(db_ini,'Calculation_Procedures/TraceAnalysis_ini/BB/Derived_Variables/WTD_coeffs.mat'));
save(WTD_coeffs,'LR_coefs')


if stop == 2

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
    legend('Observations: n = ',sprintf('Linear Regression: R2 %0.2f',r^2));
    xlabel('Scaled WTD');
    ylabel('Manual PH');
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






if strcmp(SiteID,'BB')

% Step 3.2
% Estimate Bog_Height from snow-depth sensor at BB1 - this requires the curve fitting extension
% Idea is that bog height will follow a signmoid relationship with WTD
% Sigmoid curve performs a bit better than linear regression, but also requires more resources
% If using site other than BB1, will need to read BB1 WTD

% [BH_Temp,tv_BH] = read_db([2018:current_year],'BB','Met/Clean','Bog_Height');
% DT_BH = datetime(tv_BH,"ConvertFrom","datenum");
% [sharedvals,idx_BH,idx_WT] = intersect(tv_BH,tv,"stable");
% BH = WTH(:,1,2)*NaN;
% BH(idx_WT) = BH_Temp;
% % Using a spike filter flag z-normalized raw data (|z|>3) and nth order derivatives (|z|>1)
% [~,Flagged_values] = Detect_Spikes(BH,[0],48*7,[3]);
% [~,Flagged_derivatives] = Detect_Spikes(BH,[1 2],[],[1]);
% Spike_Flag = Flagged_values|Flagged_derivatives;

% % Use stage 1 SW data to identify and filter out probable snow events
% % Calculate half-hourly albedo (restricted to 10:00-14:00) then fill using
% % moving 24-hour maximum and filter Bog Height where Albedo > .4
% [SW_IN,tv] = read_db([FirstYear:current_year],'BB','Met/Clean','SW_IN_1_1_1');
% [SW_OUT,~] = read_db([FirstYear:current_year],'BB','Met/Clean','SW_OUT_1_1_1');

% Albedo = SW_OUT./SW_IN;
% Albedo(Albedo>1) = 1;
% Albedo(hour(DT)<10) = NaN;
% Albedo(hour(DT)>14) = NaN;
% Albedo = movmax(Albedo,48,'omitnan');
% Snow = logical(ones(size(Albedo)));
% Snow(Albedo<.4) = 0;
% Flag = Snow|Spike_Flag;
% BH(Flag) = NaN;

% Fit snow depth data to a sigmoid curve as function of WTH
Comp = and(isfinite(WTH(:,1,2)),isfinite(BH));
X = movmean(WTH(:,1,2),1*48,'omitnan');
x = X(Comp);
y = BH(Comp,1,1);
sigEq = fittype(@(a, b, c, x) a./(1+exp(b*x+c))+min(BH)*.95,'independent', {'x'},'dependent', 'y');



Coefficients = setFolderSeparator(fullfile(db_ini,'Calculation_Procedures/TraceAnalysis_ini/BB/Derived_Variables/WT_and_BH_Correction_Coefficents.mat'));
if isfile(Coefficients)
    load(Coefficients)
    refit = 0;
else
    refit = 1;
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
    figure;
    hold on;
    lgnd = cell(1,1);
    lgnd{1}=sprintf('Clean Bog Height');
    plot(DT,BH,'b');
    lgnd{2}=sprintf('Estimated Bog Height');
    plot(DT,BH_est,'k')
    legend(lgnd);
    title(sprintf('Filtering'))
    grid on
end


% Next step is to compare that to BH


% Compare Bog Height (raw and estimated) to observed pipe height
Recent = and(isfinite(PH(:,1,1)),isfinite(BH));
Historic = and(isfinite(PH(:,1,1)),isfinite(BH_est));
Historic = and(Historic,~Recent);

X = PH(Recent,1,1);
Xhist= PH(Historic,1,1);
y1_obs = BH(Recent);
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
GNS_Survey_Date = datetime("2020-03-18 12:00:00","InputFormat","yy-MM-dd HH:mm:ss");

Bog_Height_Survey = 345.2094;
Pipe_Height_Survey = 447.3047;
PH_reff = Pipe_Height_Survey-Bog_Height_Survey;
Comp = and(isfinite(PH(:,1,1)),isfinite(WTD(:,1,4)));

X = WTD(Comp,1,4);
y = PH(Comp,1,1);

[PH_fit_WTH,sig_a,r,y_cl95] = linreg(X,y);

WT_reff = PH_fit_WTH(1)*WTD(:,1,4)+PH_fit_WTH(2);

r^2;

if inspect == 1
    figure
    hold on
    plot(DT,WTD(:,1,4))
    yline(0)
    legend('Water Table Depth (PH-WTD)','Surface');
    xlabel('Date');
    ylabel('Scaled WTD');
    title('Validating the correction');
    grid on
end



% [~,return_index] = intersect(tv,clean_tv,"stable");
% Bog_Height_return = Bog_Height(return_index);
% Snow_Depth_return = Snow_Depth(return_index);



% out_path = 'C:\Database\2023\BB\Clean\SecondStage';
% file_opts.out_path = out_path;
% file_opts.format   = 'bnc';
% file_opts.days     = [0 367]; % This ensures that the whole trace is exported!
% [Flow_Rate,tv] = read_db([2023],'BB','Flux','flowrate_mean');
% trc.data = Flow_Rate;
% trc.timeVector = tv;
% trc.DOY= tv - datenum(year,1,0);
% trc.DOY= trace_in.DOY - 8/24;
% trc.variableName = 'Test';
% trc.stage = 'second';
% trace_export(file_opts,trc)
% DT = datetime(tv,"ConvertFrom","datenum");
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
% end
