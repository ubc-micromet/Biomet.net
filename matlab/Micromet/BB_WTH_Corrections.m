function [tv] = BB_WTD_Correction(SiteID,inspect);

% Written by June Skeeter

% Clean and correct the water table data for the Burns Bog Flux Sites
% Written by June Skeeter January 2024
% Procedures:
%   Step 1. Read & filter manual WTD & Pipe Height observations
%   Step 2. Regress automated WTH with manual WTD
% 
% Intended to be called ~ 1/month to re-train models as manual observations are collected


current_year = year(datetime);
arg_default('inspect',0);
arg_default('SiteID','BB');
if ~exist('db_ini','var')
    db_ini = 'C:/Database';
end

stop = 1;
if inspect == 1
    close all
end


if strcmp(SiteID,'BB')
    FirstYear = 2014;
    n_wells = 1;
else
    if strcmp(SiteID,'BB2')
        FirstYear = 2019;
        n_wells = 1;
    else
        FirstYear = 2023;
        n_wells = 6;
    end
end

rng(42)
colormap = rand(n_wells*3,3);
z_flag = 2;

% Step 1 Import the traces
 
% Reference the data to a known point
GNS_Survey_Date = datetime("2020-03-18 12:00:00","InputFormat","yy-MM-dd HH:mm:ss");

Pipe_Height_Survey = 447.3047;
% Comp = and(isfinite(PH(:,1,1)),isfinite(WTD(:,1,4)));

for w=1:n_wells
    if w == 1
        [wtd,tv] = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTD_%i_1_1',w)); 
        DT = datetime(tv,"ConvertFrom","datenum");
        WTD = NaN(size(wtd,1),n_wells,3);
        WTD(:,w,1)=wtd;
        
        PH = NaN(size(wtd,1),n_wells,3);
        PH(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('Pipe_Height_%i_1_1',w));   

        WTH = NaN(size(wtd,1),n_wells,4);
        WTH(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTH_%i_1_1',w));    
        
        TA = read_db([FirstYear:current_year],SiteID,'Met/Clean','TA_1_1_1');    
        TA_fill = read_db([FirstYear:current_year],'BB','Met/Clean','TA_ECCC');   
        TA = calc_avg_trace(tv,TA,TA_fill,-1);

        if strcmp(SiteID,'BBS')
            Gauge = 'BB';
        else
            Gauge = SiteID;
        end
        Precip = read_db([FirstYear:current_year],Gauge,'Met/Clean','P_1_1_1');  
        Precip_fill = read_db([FirstYear:current_year],'BB','Met/Clean','P_ECCC');   
        Precip = calc_avg_trace(tv,Precip,Precip_fill,-1);

    else
        WTD(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTD_%i_1_1',w)); 
        PH(:,w,1) = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('Pipe_Height_%i_1_1',w));   
        wth = read_db([FirstYear:current_year],SiteID,'Met/Clean',sprintf('WTH_%i_1_1',w));    
        if sum(isfinite(wth))==0
            WTH(:,w,1) = WTH(:,w-1,1);
        else
            WTH(:,w,1) = wth;
        end
        Precip = Precip(:,w-1,1);
    end

    PH(:,w,1) = Pipe_Height_Survey-PH(:,w,1);
    WTD(:,w,1) = Pipe_Height_Survey-WTD(:,w,1);

    disp(sprintf('Processing WT Data at %s',SiteID));
end

% Step 2
% Clean manual observations Water Table Depth (WTD_manual) and Pipe Height (PH(:,1,1)) for BB1 & BB2 (extend to BBS once manual data is ready)
% Use line of best fit between WT and PH to filter out bad measurements: Bad measurement defined as residual error > |3std|
    
if inspect == 1
    figure
    hold on
    lgnd = cell(1,0);
end

PH_fill_coefs = zeros(2,n_wells);
for w=1:n_wells

    filter = 2;
    while filter > 0
        Obs = and(isfinite(WTD(:,w,1)),isfinite(PH(:,w,1)));
        X = WTD(Obs,w,1);
        y = PH(Obs,w,1);
        [ph_correction,sig_a,r,y_cl95] = linreg(X,y);
        PH_fill_coefs(:,w) = ph_correction;
        if filter == 2
            y_err = y-(X*ph_correction(1)+ph_correction(2));
            % Z-normalize errors and drop (z>z_flag)
            Z = abs((y_err-mean(y_err))/std(y_err));
            Flag = logical(zeros(size(Z)));
            Flag(Z>z_flag)=1;
            tv_Flag = tv(Obs);
            [sharedvals,Drop_Flag] = intersect(tv,tv_Flag(Flag),"stable");
%             WTD(Drop_Flag,w,1)=NaN;
            PH(Drop_Flag,w,1)=NaN;
            if inspect == 1 & filter == 2
                scatter(X,y,"MarkerEdgeColor","k","MarkerFaceColor",colormap(w,:))
                lgnd{size(lgnd,2)+1}=sprintf('Well %i; n=%i; X=%i dropped',w,length(y),sum(Flag));
            end
            if sum(Flag) > 0
                filter = filter - 1;
                if inspect == 1
                    plot(X(Flag),y(Flag),'x',"MarkerEdgeColor",colormap(w,:),'MarkerSize',12,'LineWidth',2,'HandleVisibility','off')
                    % lgnd{size(lgnd,2)+1}="Dropped obs";
                end
            else
                filter = filter - 2;
            end
        else
            filter = filter - 1;
        end
    end
    
    PH(:,w,2) = PH(:,w,1);
    PH(isnan(PH(:,w,1)),w,2) = WTD(isnan(PH(:,w,1)),w,1)*PH_fill_coefs(1,w)+PH_fill_coefs(2,w);

    WTD(:,w,2) = WTD(:,w,1)-PH(:,w,2);

    if inspect == 1
        mnmx=[min(X),max(X)];
        plot(mnmx,mnmx*ph_correction(1)+ph_correction(2),'Color',colormap(w,:))
        lgnd{size(lgnd,2)+1}=sprintf('R2 %0.2f; PH=%0.2fWTD+%0.2f',r^2,ph_correction(1),ph_correction(2));
        scatter(WTD(isnan(PH(:,w,1)),w,1),PH(isnan(PH(:,w,1)),w,2),'^',"MarkerEdgeColor",colormap(w,:),'LineWidth',2)
        lgnd{size(lgnd,2)+1}="Gap-filled manual obs";
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

if strcmp(SiteID,'BB') 
    % For BB1: Correct the historic data prior before Oct 27, 2017
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


LR_coefs = zeros(size(Periods,1),2,n_wells);
for w=1:n_wells
        
    for (period = 1:size(Periods,1))
        P = isbetween(DT,Periods(period,1),Periods(period,2));
        % Remove Spikes - for good data periods, filter out jump/drops, for bad periods, filter out very large local deviations then get the moving 48-hr median
        if period == 1
            WTH(P,w,2) = SpikeFilter(WTH(P,w,1),tv(P),1,[-.5 1],"natural");
            WTH(P,w,2) = SpikeFilter(WTH(P,w,2),tv(P),0,4,"z-score",14);
        else 
            WTH(P,w,2) = SpikeFilter(WTH(P,w,1),tv(P),0,4,"z-score",14);
            WTH(P,w,2) = movmedian(WTH(P,w,2),48,'includenan');
        end

        F = and(isfinite(WTH(:,w,2)),isfinite(WTD(:,w,1)));
        % P = and(F,P);
        Comp = and(F,P);
        
        X = WTH(Comp,w,2);
        y = WTD(Comp,w,1);


        offset = X-y;
        drift = movmean(offset,3);
        Drift_correction = WTH(:,w,2)*NaN;
        Drift_correction(Comp)=drift;
        Drift_correction = fillmissing(Drift_correction,"linear","MaxGap",365,'SamplePoints',tv);
        Drift_correction = fillmissing(Drift_correction,"nearest");
        WTH(P,1,3) = WTH(P,1,2)-Drift_correction(P);


        % [a,sig_a,r,y_cl95] = linreg(X,y);
        % LR_coefs(period,1,w) = a(1);
        % LR_coefs(period,2,w) = a(2);
        % if period == 1
        %     [LR_coefs_inverted,sig_a,r_inverted,y_cl95] = linreg(y,X);
        % end
        % if inspect == 1
        %     y_est = X*LR_coefs(period,1,w)+LR_coefs(period,2,w);
        %     Rsq2 = 1 - sum((y - y_est).^2)/sum((y - mean(y)).^2);
        %     RMSE = mean((y-y_est).^2).^.5;
        %     scatter(X,y,"MarkerEdgeColor",colormap(period,:))
        %     lgnd{count}=sprintf('%i Observations',sum(P));
        %     count = count + 1;
        %     mnmx=[min(X),max(X)];
        %     plot(mnmx,mnmx*LR_coefs(period,1,w)+LR_coefs(period,2,w),'Color',colormap(period,:))
        %     lgnd{count}=sprintf('R2 %0.2f; RMSE %0.1f cm',Rsq2,RMSE);
        %     count = count + 1;
        % end
    end
    % if inspect == 1
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
    %         WTH(P,w,3) = WTH(P,w,2)*LR_coefs(index,1,w)+LR_coefs(index,2,w);
    %     else
    %         WTH(P,w,3) = WTH(P,w,2)*LR_coefs(index,1,w)+LR_coefs(index,2,w);
    %         WTH(P,w,2) = WTH(P,w,3)*LR_coefs_inverted(1)+LR_coefs_inverted(2);
    %     end
    % end
    
    % WT_err = WTH(:,w,3)-WTD(:,w,1);
    % WT_err_norm = (WT_err-mean(WT_err,'omitnan'))./std(WT_err,'omitnan');
    % WTD(abs(WT_err_norm)>z_flag,w,1)=NaN;

    
end

if inspect == 1
    figure
    hold on
    plot(DT,WTH(:,1,1)-mean(WTH(:,1,2),'omitnan'))
    plot(DT,WTH(:,1,2)-mean(WTH(:,1,2),'omitnan'))
    plot(DT,WTH(:,1,3)-mean(WTH(:,1,3),'omitnan'))
    legend('Raw','Despiked','Drift Corrected')
    grid on
end



%DHY (Start Hydrologic year on Vernal Equinox)
DHY = (day(DT,'dayofyear')-264);
DHY(DHY<0) = DHY(DHY<0)+(365);
Comp = isfinite(WTH(:,w,3));
X_fill = [...
        ones(size(Precip))...
        movsum(Precip,[180 0],'omitnan','SamplePoints',tv)...
        movsum(Precip,[30 0],'omitnan','SamplePoints',tv)...
        movsum(Precip,[1 0],'omitnan','SamplePoints',tv)...
        movmean(TA,[30 0],'omitnan','SamplePoints',tv)...
        DHY...
        ];
        
WTH_coeffs = setFolderSeparator(fullfile(db_ini,'Calculation_Procedures/TraceAnalysis_ini/',SiteID,'/Derived_Variables/WTH_coeffs.mat'));
if hour(now) == 23 | ~isfile(WTH_coeffs)

    X_fit = X_fill(Comp,:);
    y_fit = WTH(Comp,w,3);

    b = X_fit\y_fit;
    yCalc1 = X_fit*b;
    if inspect == 1
        figure
        hold on;
        scatter(y_fit,yCalc1)
        plot([min(y_fit),max(y_fit)],[min(y_fit),max(y_fit)],'k')
        ylabel('WTH Est')
        xlabel('WTH Obs')
        grid on
        
        RMSE = mean((y_fit -yCalc1).^2).^.5;
        Rsq1 = 1 - sum((y_fit - yCalc1).^2)/sum((y_fit - mean(y_fit)).^2);
        title(sprintf('WTH Estimation \nRMSE %.4f r2 %.4f',RMSE,Rsq1))
        
        disp(sprintf('WTH FIll Coefficients\nRMSE %.4f r2 %.4f\n',RMSE,Rsq1));
        for i=1:length(b)
            disp(sprintf('%.5f',b(i)))
        end
    end

    save(WTH_coeffs,'b')
else
    b = load(WTH_coeffs);
    b = b.b;
end


WTH(:,w,4) = fillmissing(WTH(:,w,3),"linear",'SamplePoints',tv,"MaxGap",14);
fill = isnan(WTH(:,w,4));
WTH(fill,w,4)=X_fill(fill,:)*b;

if inspect == 1
    
    figure
    hold on
    plot(DT,WTH(:,w,4),'r')
    plot(DT,WTH(:,w,3),'b')
    title('Gap-filled WTH')


end

BH_path = setFolderSeparator(fullfile(db_ini,'Calculation_Procedures/TraceAnalysis_ini/BB/Derived_Variables/Bog_Height'));
SD_path = setFolderSeparator(fullfile(db_ini,'Calculation_Procedures/TraceAnalysis_ini/BB/Derived_Variables/Snow_Depth'));
TV_path = setFolderSeparator(fullfile(db_ini,'Calculation_Procedures/TraceAnalysis_ini/BB/Derived_Variables/BH_tv'));

if (hour(now) <= 23 & strcmp(SiteID,'BB'))|(~isfile(BH_path) & strcmp(SiteID,'BB'))
    [Bog_Height,Snow_Depth,tv_BH] = BB_BH_Correction(WTH(:,1,4),PH(:,1,2),TA,db_ini,inspect);
else
    fileID = fopen(BH_path,'r');
    BH = fread(fileID,'float32');
    fclose(fileID);

    fileID = fopen(SD_path,'r');
    SD = fread(fileID,'float32');
    fclose(fileID);

    fileID = fopen(TV_path,'r');
    BH_tv = fread(fileID,'float64');
    fclose(fileID);
    [~,BH_Index] = intersect(tv,BH_tv,"stable");
    Bog_Height = NaN(size(WTH(:,w,4)));
    Snow_Depth = Bog_Height;
    Bog_Height = BH(BH_Index);
    Snow_Depth = SD(BH_Index);

end




for w=1:n_wells
    
    Comp = and(isfinite(Bog_Height),isfinite(PH(:,w,2)));
    X_fill = [ones(size(Bog_Height)), Bog_Height];
    X_fit = X_fill(Comp,:);
    y_fit = PH(Comp,w,2);
    b = X_fit\y_fit;
    yCalc1 = X_fit*b;
    Rsq1 = 1 - sum((y_fit - yCalc1).^2)/sum((y_fit - mean(y_fit)).^2);
    RMSE = mean((y_fit -yCalc1).^2).^.5;

    PH(:,w,3) = X_fill*b;

    WTD(:,w,3) = WTH(:,w,4)-PH(:,w,3);
    
    if inspect == 1
        figure
        hold on
        scatter(X_fit(:,2),y_fit)
        plot(X_fill(:,2),X_fill*b)
        legend(sprintf('Observations: n = %i',length(X)),sprintf('Linear Regression: R2 %0.2f',r^2));
        xlabel('Bog Height');
        ylabel('Estimate at Pipe Base');
        title('Estimating Bog Height at Pipe Base');
        grid on
        
        figure
        hold on
        plot(DT,WTH(:,w,4),'b')
        plot(DT,Bog_Height,'r')
        plot(DT,PH(:,w,3),'k')
        plot(DT,PH(:,w,2),'rx')
        plot(DT,WTD(:,w,1),'bo')
        legend('Gap-filled WTH','Bog Height','Estimated Height at Pipe Base','Raw Pipe Height','Raw WTD')
        title(sprintf('Scaling WTH to WTD Data at %s',SiteID))
        hold off
        grid on

        figure
        hold on
        plot(DT,WTD(:,1,3))
        plot(DT,WTD(:,1,2),'ko')
        % plot(DT,WTD_Joe)
        yline(0)
        % legend('Estimated Water Table Depth','Manual Water Table Depth','Water Table relative to mean January Bog Surface','Bog Surface');
        xlabel('Date');
        ylabel('Scaled WTD');
        title('Water Table Depth (relative to surface)');
        grid on
        
    end

end


