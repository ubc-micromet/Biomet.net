% Written by June Skeeter

% Clean and correect

inspect = 1;
close all

cumtinue = 0;

%Don't forget - delete the end at the end
if cumtinue == 1

% Step1
% Import manual data, use line of best fit between WT and PH to filter out
% bad measurements

[WT_manual,TV] = read_db([2015:2023],'BB','Met/Clean','WT_manual');
[PH_manual,TV] = read_db([2015:2023],'BB','Met/Clean','Pipe_Height');
Comp = and(isfinite(WT_manual),isfinite(PH_manual));

X = PH_manual(Comp);
y = WT_manual(Comp);
[c,sig_a,r,y_cl95] = linreg(X,y);
y_err = y-(X*c(1)+c(2));

% Z-norm'd errors (z>3) are bad measurements
[~,Flag] = Detect_Spikes(y_err);

Flag

TV_Flag = TV(Comp);
[sharedvals,Drop_Flag] = intersect(TV,TV_Flag(Flag),"stable");
PH_manual(Drop_Flag)=NaN;
WT_manual(Drop_Flag)=NaN;
WTD_manual = PH_manual-WT_manual;

if inspect == 1
    figure
    hold on
    lgnd = cell(1,1);
    scatter(X,y)
    lgnd{1}=sprintf('Observations');
    mnmx=[min(X),max(X)];
    plot(mnmx,mnmx*c(1)+c(2))
    lgnd{2}=sprintf('R2 %0.2f',r^2);
    
    if sum(Flag) > 0 & length(Flag) == length(X)
        plot(X(Flag),y(Flag),'xr')
        lgnd{3}=sprintf("Flagged %i Values",sum(Flag));
    end
    legend(lgnd);
    xlabel('Manual PH');
    ylabel('Manual WT');
    title('Flagging Manual Data');
    grid on
    hold off
end


[WT_manual_daily,~,~,~,~,~,Day] = Daily_Resample(WT_manual,TV);
[PH_manual_daily,~,~,~,~,~,Day] = Daily_Resample(PH_manual,TV);
WTD_manual_daily = PH_manual_daily-WT_manual_daily;

% Step2
% Import automated data WTH data, calculate moving median of WTH using asymmetric 24hr window
% Data are broken into periods - Period 1 is most recent - good quality data, 2+ are historic w/ poor quality data
% For each period - calculate line of best fit between WTH and manual data
% Use 24hr moving median for automated data to reduce noise

%Periods = [[datetime("2017-10-27 12:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("now")];
%[datetime("2017-01-20 13:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("2017-10-26 15:00:00","InputFormat","yy-MM-dd HH:mm:ss")];
%[datetime("2016-10-21"),datetime("2017-01-01")];
%[datetime("2015-12-11"),datetime("2016-10-21")];
%[datetime("2015-12-11"),datetime("2017-01-01")];
%];

Periods = [[datetime("2017-10-27 12:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("now")];
[datetime("2017-01-20 13:00:00","InputFormat","yy-MM-dd HH:mm:ss"),datetime("2017-10-26 15:00:00","InputFormat","yy-MM-dd HH:mm:ss")];
%[datetime("2016-10-21"),datetime("2017-01-01")];
%[datetime("2015-12-11"),datetime("2016-10-21")];
[datetime("2015-12-11"),datetime("2017-01-01")];
];

[WTH_Temp,TV] = read_db([2015:2023],'BB','Met/Clean',['WTH_1_1_1']);
DT = datetime(TV,"ConvertFrom","datenum");

% Do a very rough/quick clean
for (i = 1:size(Periods,1))
    Set = isbetween(DT,Periods(i,1),Periods(i,2));
    % Remove Very Large Magnitude Local Deviations, Leave Moderate Noise
    WTH_Temp(Set) = Detect_Spikes(WTH_Temp(Set),[0],[14],[4]);
end

[WTH_Daily,~,~,~,~,~,Day] = Daily_Resample(WTH_Temp,TV);
Date = datetime(Day,"ConvertFrom","datenum");

LR_coefs = zeros(4,2);
for (i = 1:size(Periods,1)),
    Comp = and(isfinite(WTD_manual_daily),isfinite(WTH_Daily));
    Comp = and(Comp,isbetween(Date,Periods(i,1),Periods(i,2)));
    
    X = WTH_Daily(Comp);
    y = WT_manual_daily(Comp);
    [a,sig_a,r,y_cl95] = linreg(X,y);
    LR_coefs(i,1) = a(1);
    LR_coefs(i,2) = a(2);
end

if inspect == 1

    figure
    hold on
    lgnd = cell(6,1);
    count = 1;
    for (i = 1:size(Periods,1)),
        Comp = and(isfinite(WTD_manual_daily),isfinite(WTH_Daily));
        Comp = and(Comp,isbetween(Date,Periods(i,1),Periods(i,2)));
        X = WTH_Daily(Comp);
        y = WT_manual_daily(Comp);
        y_est = X*LR_coefs(i,1)+LR_coefs(i,2);
        Rsq2 = 1 - sum((y - y_est).^2)/sum((y - mean(y)).^2);
        RMSE = mean((y-y_est).^2).^5;
        scatter(X,y)
        lgnd{count}=sprintf('%i Observations',sum(Comp));
        count = count + 1;
        mnmx=[min(X),max(X)];
        plot(mnmx,mnmx*LR_coefs(i,1)+LR_coefs(i,2))
        lgnd{count}=sprintf('R2 %0.2f; RMSE %0.1f cm',Rsq2,RMSE);
        count = count + 1;
    end
    legend(lgnd);
    xlabel('Automated WT');
    ylabel('Manual WT');
    title('Estimating "Manual WT" at BB1');
    grid on
    hold off
end

% Step 3
% Invert the line of best fit for period 1 only

Comp = and(isfinite(WTD_manual_daily),isfinite(WTH_Daily));
Comp = and(Comp,isbetween(Date,Periods(1,1),Periods(1,2)));
X = WT_manual_daily(Comp);
y = WTH_Daily(Comp);
[inverse_fit,sig_a,r,y_cl95] = linreg(X,y);

if inspect == 1
    figure
    hold on
    lgnd = cell(1,1);
    scatter(X,y)
    lgnd{1}=sprintf('%i Observations',sum(Comp));
    mnmx=[min(X),max(X)];
    plot(mnmx,mnmx*inverse_fit(1)+inverse_fit(2))
    lgnd{2}=sprintf('R2 %0.2f',r^2);
    legend(lgnd);
    xlabel('Manual WT');
    ylabel('Automated WT');
    title('Estimating "WT" at BB1');
    grid on
    hold off
end


% Step 4
% Reconstruct the historic WTH data (Periods 2+)
% Use best fit line from Step 2 to scale to manual observation
% Then use best fit line from Step 3 to scale to Corrupted Periods

P1 = isbetween(DT,Periods(1,1),Periods(1,2));
WTH = movmean(WTH_Temp,48,'omitnan');
Reconstructed_WTH = WTH_Temp*NaN;
Reconstructed_WTH(P1) = WTH_Temp(P1);

for (i = 2:size(Periods,1)),
    P = isbetween(DT,Periods(i,1),Periods(i,2));
    P_manual_scaled = WTH(P)*LR_coefs(i,1)+LR_coefs(i,2);
    Reconstructed_WTH(P) = P_manual_scaled*inverse_fit(1)+inverse_fit(2);
end

if inspect == 1
    figure
    hold on
    lgnd = cell(3,1);
    Comp = and(isfinite(Reconstructed_WTH),isbetween(DT,Periods(1,1),Periods(1,2)));
    X = DT(Comp);
    y = Reconstructed_WTH(Comp);
    plot(X,y)
    lgnd{1}=sprintf('No Adjustment',sum(Comp));

    Comp = and(isfinite(Reconstructed_WTH),isbetween(DT,Periods(length(Periods),1),Periods(2,2)));
    X = DT(Comp);
    y = Reconstructed_WTH(Comp);
    y_old = WTH_Temp(Comp);
    plot(X,y,X,y_old)
    lgnd{2}=sprintf('Corrected',sum(Comp));
    lgnd{3}=sprintf('Raw',sum(Comp));
    legend('Raw WT Data','Adjusted WT Data')
    title('Correcting Historic WTH Data at BB1')
    hold off
    grid on
    
    % Validate by estimating manual observations for P2 & P3 from Reconstructed_WTH using LR_coefs from P1
    Comp = and(isfinite(WTD_manual),isfinite(isfinite(Reconstructed_WTH)));
    Comp = and(Comp,isbetween(DT,Periods(length(Periods),1),Periods(2,2)));
    X = WT_manual(Comp);
    y = Reconstructed_WTH(Comp);
    y_est = X*LR_coefs(1,1)+LR_coefs(1,2);
    Rsq2 = 1 - sum((y - y_est).^2)/sum((y - mean(y)).^2);
    RMSE = mean((y-y_est).^2).^5;
    figure
    scatter(y,y_est)
    legend(sprintf('n %i; R2 %0.2f; RMSE %0.2f cm',size(y,1),Rsq2,RMSE));
    xlabel('Manual WT');
    ylabel('Estimated Manual WT');
    title('Validating the correction');
    grid on
end



% Step 5
% Import and clean Bog_Height
% Only available since Dec 2018
[BH_Temp,TV_BH] = read_db([2018:2023],'BB','Met/Clean','Bog_Height');
DT_BH = datetime(TV_BH,"ConvertFrom","datenum");
[sharedvals,idx_BH,idx_WT] = intersect(TV_BH,TV,"stable");
BH = WTH_Temp*NaN;
BH(idx_WT) = BH_Temp;
BH_raw = BH;

% Using a spike filter flag z-normalized raw data (|z|>3) and nth order derivatives (|z|>1)
[~,Flagged_values] = Detect_Spikes(BH,[0],48*7,[3]);
[~,Flagged_derivatives] = Detect_Spikes(BH,[1 2],[],[1]);
Spike_Flag = Flagged_values|Flagged_derivatives;

% 5.2 Use stage 1 SW data to identify snow events
% Calculate half-hourly ablbedo (restricted to 10:00-14:00) then fill using
% moving 24-hour maximum and filter Bog Height where Albedo > .2
[SW_IN,TV] = read_db([2015:2023],'BB','Met/Clean','SW_IN_1_1_1');
[SW_OUT,~] = read_db([2015:2023],'BB','Met/Clean','SW_OUT_1_1_1');
Albedo = SW_OUT./SW_IN;
Albedo(Albedo>1) = 1;
Albedo(hour(DT)<10) = NaN;
Albedo(hour(DT)>14) = NaN;
Albedo = movmax(Albedo,48,'omitnan');
Snow = logical(ones(size(Albedo)));
Snow(Albedo<.2) = 0;

Flag = Snow|Spike_Flag;
BH(Flag) = NaN;

Comp = and(isfinite(Reconstructed_WTH),isfinite(BH));

X = movmean(Reconstructed_WTH,3*48,'omitnan');
x = X(Comp);
y = BH(Comp);

sigEq = fittype(@(a, b, c, d, x) a./(1+exp(b*x+c))+d,'independent', {'x'},'dependent', 'y');

Coefficients = 'WT_and_BH_Correction_Coefficents.mat';
if isfile(Coefficients)
    load(Coefficients)
    refit = 0;
else
    refit = 1
    BH_coeffs = [max(y)-min(y) -.1 std(x) min(y)];
end

%Re-fit once a month on the 2nd
if day(datetime(now,'ConvertFrom','datenum'))==2 & timeofday(datetime(now,'ConvertFrom','datenum'))>'23:00:00'
    refit = 1
end

if refit == 1
    figure;
    hold on;
    f=fit(x, y ,sigEq,'Start', BH_coeffs);
    scatter(x,y);
    scatter(x,f(x));
    if isequal(coeffvalues(f),BH_coeffs)
    else
        BH_coeffs = coeffvalues(f);
        sprintf('Update coeficients')
        save(Coefficients,'BH_coeffs')
    end
    grid on;
end

if inspect == 1
    yCalc1 = sigEq(BH_coeffs(1),BH_coeffs(2),BH_coeffs(3),BH_coeffs(4),x);
    Rsq1 = 1 - sum((y - yCalc1).^2)/sum((y - mean(y)).^2);
    RMSE = mean((y -zCalc1).^2).^.5;
    figure 
    hold on
    lgnd = cell(1,1);
    scatter(y,zCalc1)
    plot([min(y):max(y)],[min(y):max(y)])
    grid on
    lgnd{1}=sprintf('R2 %0.2f; RMSE %0.2f: n = %i',Rsq1,RMSE,size(y,1));
    lgnd{2}=sprintf('1:1');
    legend(lgnd);
    xlabel('Manual PH');
    ylabel('Automated BH');
        
    figure
    hold on
    plot(DT,BH_est,DT,BH)
    grid on
end

BH_est = sigEq(BH_coeffs(1),BH_coeffs(2),BH_coeffs(3),BH_coeffs(4),X);




if inspect == 1
    DT_BH = datetime(TV_BH,"ConvertFrom","datenum");
    figure;
    hold on;
    lgnd = cell(1,1);
    plot(DT_BH,BH_Temp,'Color',[0,0.7,0.9]);
    lgnd{1}=sprintf('Data In');
    plot(DT,BH);
    lgnd{2}=sprintf('Data Out, n = %i',sum(~isnan(BH_out)-~isnan(BH_Temp)));
    plot(Date_BH,BH_Daily,'ok')
    lgnd{3}=sprintf('Daily Mean');
    legend(lgnd);
    title(sprintf('Filtering'))
    grid on
end


% Step 6
% Compare Bog Height (raw and estimated) to observed pipe height

% Use daily means
[BH_Daily_raw,~,~,~,~,~,Day] = Daily_Resample(BH_raw,TV);
[BH_Daily_est,~,~,~,~,~,Day] = Daily_Resample(BH_est,TV);
Date_BH = datetime(Day,"ConvertFrom","datenum");

Comp = and(isfinite(PH_manual_daily),isfinite(BH_Daily_raw));
Hist = and(isfinite(PH_manual_daily),isfinite(BH_Daily_est));

X = PH_manual_daily(Comp);
Xhist= PH_manual_daily(Hist);
y1 = BH_Daily_raw(Comp);
y2 = BH_Daily_est(Hist);
[PH_fit_BH_raw,sig_a,r_raw,y_cl95] = linreg(X,y1);
[PH_fit_BH_est,sig_a,r_est,y_cl95] = linreg(Xhist,y2);

if inspect == 2
    figure
    hold on
    lgnd = cell(1,1);
    scatter(X,y1)
    lgnd{1}=sprintf('Raw: n = %i',size(y1,1));
    scatter(Xhist,y2)
    lgnd{2}=sprintf('Est.: n = %i',size(y2,1));
    mnmx=[min(Xhist),max(Xhist)];
    plot(mnmx,mnmx*PH_fit_BH_raw(1)+PH_fit_BH_raw(2))
    lgnd{3}=sprintf('Raw: R2 %0.2f',r_raw^2);
    plot(mnmx,mnmx*PH_fit_BH_est(1)+PH_fit_BH_est(2))
    lgnd{4}=sprintf('Est: R2 %0.2f',r_est^2);
    legend(lgnd);
    xlabel('Manual PH');
    ylabel('Automated BH');
    title('Pipe Height vs. Bog Height');
    grid on
    hold off
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
%             plot(DT(ix),z_norm,'-o')
        end
        flag = and(z_norm>z_range(1),z_norm<z_range(2));
        Keep(ix,i) = flag;
        Drop(ix,i) = ~flag;
    end
    Z_Flag = min(Drop,[],2);
    data_out = data_in;
    data_out(~Z_Flag)=NaN;
end


function [u,s,m,mx,mn,C,T] = Daily_Resample(x,TV);
    % Since clean_tv starts at 00:30 instead of 00:00 each year 
    rnd = TV(1)-floor(TV(1));
    G = findgroups(floor(TV-rnd));
    T = splitapply(@mean,floor(TV-rnd),G);
    u = splitapply(@(y)mean(y,'omitnan'),x,G);
    s = splitapply(@(y)std(y,'omitnan'),x,G);
    m = splitapply(@(y)median(y,'omitnan'),x,G);
    mx = splitapply(@max,x,G);
    mn = splitapply(@min,x,G);
    C = splitapply(@sum,isfinite(x),G);
end