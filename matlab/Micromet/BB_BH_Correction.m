function [Bog_Height,Snow_Depth,tv] = BB_BH_Correction(WTH,PH,TA,db_ini,inspect);
% Written by June Skeeter Jan 15, 2024
% Clean the Bog Height Data for BB1 to snow events and noise
% Output an estimated snow depth as a byproduct

arg_default('inspect',0)

SiteID = 'BB';
FirstYear = 2014;
FirstYear_BH = 2018;

current_year = year(datetime);

[BH_raw,BH_tv] = read_db([FirstYear_BH:current_year],'BB','Met/Clean','Bog_Height');
DT_BH = datetime(BH_tv,"ConvertFrom","datenum");

% Reference the data to a known point
GNS_Survey_Date = datetime("2020-03-18 12:00:00","InputFormat","yy-MM-dd HH:mm:ss");
s = DT_BH == GNS_Survey_Date;
Bog_Height_Survey = 345.2094;
BH_raw = BH_raw + Bog_Height_Survey-BH_raw(s);


[SW_IN,tv] = read_db([FirstYear:current_year],'BB','Met/Clean','SW_IN_1_1_1');
[SW_OUT,~] = read_db([FirstYear:current_year],'BB','Met/Clean','SW_OUT_1_1_1');

% Extend the trace BH to match the others
BH_In = NaN(size(SW_IN));
[~,BH_Index] = intersect(tv,BH_tv,"stable");
BH_In(BH_Index) = BH_raw;
DT = datetime(tv,"ConvertFrom","datenum");




[BH_Daily,tv_day,dt_day,Map_to_Group,Map_from_Group] = Resample(BH_In,tv,'day',{'median','count','IQR'});

Drop = logical(zeros(length(BH_Daily),1));
Drop(BH_Daily(:,2)<48/3)=1;

%Flag days with median bogh height > 1cm above previous day as possible snowfall events
[~,Possible_Snowfall] = SpikeFilter(BH_Daily(:,1),tv,1,[-inf 1],"natural");

% Use mid-day albedo around snowfall events to confirm
Albedo_thresh = 0.35;
Albedo = SW_OUT./SW_IN;
Albedo(Albedo>0.9) = 0.9;
Albedo(or(hour(DT)<10,hour(DT)>14)) = NaN;
Albedo_mx = Resample(Albedo,tv,'day',{'max'});
Snow_Check = zeros(length(Albedo_mx),1);
Snow_Check(Albedo_mx>Albedo_thresh)=1;
Snow_Check(or((circshift(Snow_Check,1)),(circshift(Snow_Check,-1))))=1;

% Use minimum air temperature as second check
TA_mn = Resample(TA,tv,'day',{'min'});
Snow_Check(TA_mn>5)=0;


Snowfall_event = logical(Possible_Snowfall.*Snow_Check);
Snow_Day = logical(movsum(Snowfall_event,[14 1]).*Snow_Check);
% Drop(and(Possible_Snowfall,~Snowfall_event))=1;
Drop(Snow_Day)=1;
Drop(and(BH_Daily(:,3)>1.5,~Snow_Day))=1;

Daily_Median_Bog_Height = BH_Daily(:,1);
Daily_Median_Bog_Height(Drop) = NaN;

% Gap fill the filtered daily trace to get estimates of BH before snow-depth sensor was installed
WTH = Resample(WTH,tv,'day',{'median'});
PH = Resample(PH,tv,'day',{'median'});

% Correct for sensor drift using manual observations
Comp = and(isfinite(Daily_Median_Bog_Height),isfinite(PH));
offset = Daily_Median_Bog_Height-PH;
drift = movmean(offset(Comp),3);
Drift_correction = Daily_Median_Bog_Height*NaN;
Drift_correction(Comp)=drift;
Drift_correction = fillmissing(Drift_correction,"linear","MaxGap",365,'SamplePoints',tv_day);
Daily_Median_Bog_Height = Daily_Median_Bog_Height-Drift_correction;

if inspect == 1
    figure
    hold on
    plot(DT,BH_In)
    plot(dt_day,Daily_Median_Bog_Height)
    plot(dt_day,PH,'kx')
    legend('Raw BH','Cleaned and Drift Corrected Daily Median','PH Observation')
    grid on;

end

% if inspect == 1
%     figure
%     hold on
%     plot(dt_day,PH,'kx')
%     plot(dt_day,Daily_Median_Bog_Height)
%     grid on;
% end




% Comp = and(isfinite(Daily_Median_Bog_Height),isfinite(PH));
% X_fill = [ones(size(PH)),PH];
% X_fit = X_fill(Comp,:);
% y_fit = Daily_Median_Bog_Height(Comp);
% b = X_fit\y_fit;
% yCalc1 = X_fit*b;
% PH_Scaled = X_fill*b;

% if inspect == 1
    
%     figure
%     hold on;
%     scatter(X_fit(:,2),y_fit)
%     scatter(X_fit(:,2),yCalc1)
%     ylabel('Bog Height')
%     xlabel('Pipe Height')
%     grid on
    
%     RMSE = mean((y_fit -yCalc1).^2).^.5;
%     Rsq1 = 1 - sum((y_fit - yCalc1).^2)/sum((y_fit - mean(y_fit)).^2);
%     title(sprintf('PH to BH Scaling Coefficients: offset %.4f, slope %.4f\nRMSE %.4f r2 %.4f',b(1),b(2),RMSE,Rsq1))
    
% end



% Comp = and(isfinite(Daily_Median_Bog_Height),isfinite(PH_Scaled));
% X_trend = [ones(size(tv_day)),tv_day];
% X_trend_fit = X_trend(Comp,:);
% y_fit_BH = Daily_Median_Bog_Height(Comp);
% y_fit_PH = PH(Comp);
% b_BH = X_trend_fit\y_fit_BH;
% disp(sprintf('Trendline for BH: offset %.5f, slope %.5f',b_BH(1),b_BH(2)))
% b_PH = X_trend_fit\y_fit_PH;
% disp(sprintf('Trendline for PH: offset %.5f, slope %.5f',b_PH(1),b_PH(2)))

% BH_trend = X_trend*b_BH-mean(Daily_Median_Bog_Height,'omitnan');
% PH_trend = X_trend*b_PH-mean(PH(Comp),'omitnan');
% % Daily_Median_Bog_Height = Daily_Median_Bog_Height-BH_trend+PH_trend;
% Daily_Median_Bog_Height = Daily_Median_Bog_Height;

Comp = and(isfinite(WTH),isfinite(PH));
X_fill = [ones(size(WTH)),WTH,tv_day];
y_fit_PH = PH(Comp);
X_fit = X_fill(Comp,:);
b = X_fit\y_fit_PH;
yCalc1 = X_fit*b;
PH_Est = X_fill*b;

if inspect == 1
    figure
    hold on
    scatter(Daily_Median_Bog_Height,PH_Est)
    title('Estimated vs. Drift Corrected Observation')
end


Daily_Median_Bog_Height = fillmissing(Daily_Median_Bog_Height,"linear","MaxGap",30);
Daily_Median_Bog_Height(isnan(Daily_Median_Bog_Height)) = PH_Est(isnan(Daily_Median_Bog_Height));

Bog_Height = BH_In*NaN;
[~,HH_ix,~] = intersect(Map_to_Group,Map_from_Group);
Bog_Height(HH_ix+23)=Daily_Median_Bog_Height;
Bog_Height=fillmissing(Bog_Height,"linear","MaxGap",48);

Snow_Groups = Map_from_Group;
Snow_Groups(~Snow_Day)=NaN;
Snow_flag = ismember(Map_to_Group,Snow_Groups);

Snow_Depth = BH_In;
Snow_Depth = fillmissing(Snow_Depth,"linear","MaxGap",48);
Snow_Depth = Snow_Depth-Bog_Height;
Snow_Depth(~Snow_flag)=0;
Snow_Depth(Snow_Depth<0)=0;

if inspect == 1   

    figure
    hold on;
    plot(dt_day,Daily_Median_Bog_Height)
    plot(dt_day,PH_Est)
    plot(dt_day,PH,'kx')
    legend('Detrended Daily BH','PH Estimate','PH_Scaled')
    grid on
    RMSE = mean((y_fit_PH -yCalc1).^2).^.5;
    Rsq1 = 1 - sum((y_fit_PH - yCalc1).^2)/sum((y_fit_PH - mean(y_fit_PH)).^2);
    title(sprintf('BH Estimation Coefficients: offset %.4f, slope (WTH %.4f) (TV %.4f)\nRMSE %.4f r2 %.4f',b(1),b(2),b(3),RMSE,Rsq1))

    figure
    hold on;
    scatter(dt_day(Snowfall_event),BH_Daily(Snowfall_event,1),'rx')
    scatter(dt_day(Snow_Day),BH_Daily(Snow_Day,1),'bs')
    plot(DT,BH_In)
    plot(DT,Bog_Height)
    grid on
    ylabel('cm')
    xlabel('Date')
    legend(sprintf('Snowfall Events %i',sum(Snowfall_event)),sprintf('Snow Days %i',sum(Snow_Day)),'Raw Data','Interpolated Daily Median')

    figure
    hold on;
    plot(DT,Snow_Depth)
    grid on
    ylabel('cm')
    xlabel('Date')
    legend('Snow Depth')
end



BH_save = setFolderSeparator(fullfile(db_ini,'Calculation_Procedures/TraceAnalysis_ini/BB/Derived_Variables/Bog_Height'));
fileID = fopen(BH_save,'w');
fwrite(fileID,Bog_Height,'float32');
fclose(fileID);

SD_save = setFolderSeparator(fullfile(db_ini,'Calculation_Procedures/TraceAnalysis_ini/BB/Derived_Variables/Snow_Depth'));
fileID = fopen(SD_save,'w');
fwrite(fileID,Snow_Depth,'float32');
fclose(fileID);

TV_save = setFolderSeparator(fullfile(db_ini,'Calculation_Procedures/TraceAnalysis_ini/BB/Derived_Variables/BH_tv'));
fileID = fopen(TV_save,'w');
fwrite(fileID,tv,'float64');
fclose(fileID);


end