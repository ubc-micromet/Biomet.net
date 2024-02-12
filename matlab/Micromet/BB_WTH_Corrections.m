function [trace_out] = BB_WTD_Corrections(SiteID,tv_in,trace_out_name,recalc,inspect);

    % Written by June Skeeter
    % Get WT data from derived variables or run correction if they don't exist
    % Recalculate overnight

    arg_default('SiteID','BB');
    arg_default('inspect',0);
    arg_default('recalc',0);


    Derived_Variables = setFolderSeparator(fullfile(db_pth_root,'Calculation_Procedures/TraceAnalysis_ini/',SiteID,'/Derived_Variables/'));
    if (hour(datetime) < 1 & strcmp(SiteID,'BB')) | ~isfile(setFolderSeparator(fullfile(Derived_Variables,"WT_tv")))
        % if strcmp(SiteID,'BB')
            recalc = 1;
        % end
    end

    if recalc == 1
        disp(sprintf('Recalculating WT Corrections'))
        Apply_WTD_Correction(SiteID,inspect)
    end
    
    if isfile(setFolderSeparator(fullfile(Derived_Variables,"WT_tv")))
        disp(sprintf('Loading WT Data'))
        fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,"WT_tv")),'r');
        tv_out = fread(fileID,'float64');
        fclose(fileID);
    
        fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,trace_out_name)),'r');
        trace = fread(fileID,'float32');
        fclose(fileID);
        [~,ix] = intersect(tv_out,tv_in,"stable");
        trace_out = trace(ix);
    else
        disp(sprintf('Request not processed, returning NAN'))
        trace_out = NaN(size(tv_in));
    end
end

function Apply_WTD_Correction(SiteID_in,inspect_plot);

% Clean and correct the water table data for the Burns Bog Flux Sites
% Written by June Skeeter January 2024
% Procedures:
%   Step 1. Read & filter manual WTD & Pipe Height observations
%   Step 2. Regress correct and gap-fill automated WTH with manual WTD
%   Step 3. (BB1 only) correct and gap-fill Bog Height with manual Pipe Height
%   Step 4. (BB2 & BBS only) Regress BB1 Bog Height with manual Pipe Height
%   Step 5. Calculate manual WTD relative to Bog Height

current_year = year(datetime);

Sites = {'BB','BB2','BBS'};

for i = 1:length(Sites)
    SiteID = Sites{i};
    if strcmp(SiteID,SiteID_in) & inspect_plot == 1
        inspect = 1;
    else
        inspect = 0;
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
    
    % Reference the data to a known point - only applies to BB1 for now
    % Arbitrarily applying to others as well until a valid observation is obtained
    GNS_Survey_Date = datetime("2020-03-18 12:00:00","InputFormat","yy-MM-dd HH:mm:ss");

    Pipe_Height_Survey = 447.3047;

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
                Z = abs((y_err-mean(y_err))/std(y_err));
                Flag = logical(zeros(size(Z)));
                Flag(Z>z_flag)=1;
                tv_Flag = tv(Obs);
                [sharedvals,Drop_Flag] = intersect(tv,tv_Flag(Flag),"stable");
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

    Offset = WTH(:,w,1)*NaN;
    ct = WTD(:,w,1)*0+1;
    correction_window=60;
    mct = movsum(ct,correction_window,"omitnan",'SamplePoints',tv);
    mct(mct<1)=NaN;
    mct(mct>1)=1;
    Drift_correction = WTH(:,w,1)*NaN;
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
            Comp = and(F,P);
            
            X = WTH(Comp,w,2);
            y = WTD(Comp,w,1);

            Offset(P) = WTH(P,w,2)-WTD(P,w,1);
            Drift_correction(P) = smoothdata(Offset(P),'gaussian',correction_window,'SamplePoints',tv(P));
            Drift_correction(P) = Drift_correction(P).*mct(P);
            Drift_correction(P) = fillmissing(Drift_correction(P),"linear");

            WTH(P,1,3) = WTH(P,1,2)-Drift_correction(P);
            
        end
        
    end

    if inspect == 1
        figure
        hold on
        plot(DT,WTH(:,1,1)-mean(WTH(:,1,2),'omitnan'))
        plot(DT,WTH(:,1,2)-mean(WTH(:,1,2),'omitnan'))
        plot(DT,WTH(:,1,3)-mean(WTH(:,1,3),'omitnan'))
        legend('Raw','Despiked','Drift Corrected')
        grid on
        
        title(sprintf('Cleaning and Correcting WTH at %s',SiteID))
    end


    for w=1:n_wells

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
            title(sprintf('WTH Estimation at %s\nRMSE %.4f r2 %.4f',SiteID,RMSE,Rsq1))
            
            disp(sprintf('WTH FIll Coefficients\nRMSE %.4f r2 %.4f\n',RMSE,Rsq1));
            for i=1:length(b)
                disp(sprintf('%.5f',b(i)))
            end
        end
    
        WTH(:,w,4) = fillmissing(WTH(:,w,3),"linear",'SamplePoints',tv,"MaxGap",14);
        fill = isnan(WTH(:,w,4));
        WTH(fill,w,4)=X_fill(fill,:)*b;

        Mask = logical(zeros(size(tv)));
        Mask(tv>now) = 1;
        WTH(Mask)=NaN;
        
    
        if inspect == 1
            
            figure
            hold on
            plot(DT,WTH(:,w,4),'r')
            plot(DT,WTH(:,w,3),'b')
            title(sprintf('Gap-filled WTH at %s',SiteID))
    
        end
    end
    
    Derived_Variables = setFolderSeparator(fullfile(db_pth_root,'Calculation_Procedures/TraceAnalysis_ini/BB/Derived_Variables/'));

    if strcmp(SiteID,'BB')
        [Bog_Height,tv_BH] = Bog_Height_Correction(WTH(:,1,4),PH(:,1,2),TA,db_pth_root,inspect);
    else
        fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,'Bog_Height')),'r');
        BH = fread(fileID,'float32');
        fclose(fileID);

        fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,'BH_tv')),'r');
        BH_tv = fread(fileID,'float64');
        fclose(fileID);
        [~,BH_Index] = intersect(tv,BH_tv,"stable");
        Bog_Height = NaN(size(WTH(:,w,4)));
        Bog_Height = BH(BH_Index);

    end


    for w=1:n_wells
        if strcmp(SiteID,'BB') & w==1
            PH(:,w,3) = Bog_Height;
        else
            Comp = and(isfinite(Bog_Height),isfinite(PH(:,w,2)));
            X_fill = [ones(size(Bog_Height)), Bog_Height];
            X_fit = X_fill(Comp,:);
            y_fit = PH(Comp,w,2);
            b = X_fit\y_fit;
            yCalc1 = X_fit*b;
            Rsq1 = 1 - sum((y_fit - yCalc1).^2)/sum((y_fit - mean(y_fit)).^2);
            RMSE = mean((y_fit -yCalc1).^2).^.5;
            PH(:,w,3) = X_fill*b;
            
            if inspect == 1
                figure
                hold on
                scatter(X_fit(:,2),y_fit)
                plot(X_fill(:,2),X_fill*b)
                legend(sprintf('Observations: n = %i',length(X)),sprintf('Linear Regression: R2 %0.2f',r^2));
                xlabel('Bog Height');
                ylabel('Estimate at Pipe Base');
                title(sprintf('Estimating Bog Height at Pipe Base at %s',SiteID))
                grid on
            end
        end

        WTD(:,w,3) = WTH(:,w,4)-PH(:,w,3);
        
        if inspect == 1
            
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
            yline(0)
            legend('Estimated Water Table Depth','Manual Water Table Depth');
            xlabel('Date');
            ylabel('Scaled WTD');
            title(sprintf('Water Table Depth (relative to surface) for %s',SiteID));
            grid on
            
        end

    end

    Derived_Variables = setFolderSeparator(fullfile(db_pth_root,'Calculation_Procedures/TraceAnalysis_ini/',SiteID,'/Derived_Variables/'));

    fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,"WT_tv")),'w');
    fwrite(fileID,tv,'float64');
    fclose(fileID);

    for w=1:n_wells

        % WTH_save = setFolderSeparator(fullfile(Derived_Variables,sprintf("WTH_%i_1",w)));
        fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,sprintf("WTH_%i",w))),'w');
        fwrite(fileID,WTH(:,w,end),'float32');
        fclose(fileID);

        % WTD_save = setFolderSeparator(fullfile(Derived_Variables,sprintf("WTD_%i_1",w)));
        fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,sprintf("WTD_%i",w))),'w');
        fwrite(fileID,WTD(:,w,end),'float32');
        fclose(fileID);

        % PH_save = setFolderSeparator(fullfile(Derived_Variables,sprintf("Ground_Height_Estimate_%i",w)));
        fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,sprintf("Bog_Height_at_Well_%i",w))),'w');
        fwrite(fileID,PH(:,w,end),'float32');
        fclose(fileID);

    end

end

end

function [Bog_Height,tv] = Bog_Height_Correction(WTH,PH,TA,db_pth_root,inspect);
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
    
    
    Offset = Daily_Median_Bog_Height-PH;
    ct = Offset*0+1;
    correction_window=60;
    mct = movsum(ct,correction_window,"omitnan",'SamplePoints',tv_day);
    mct(mct<1)=NaN;
    mct(mct>1)=1;
    Drift_correction = PH*NaN;
    
    Drift_correction = smoothdata(Offset,'gaussian',correction_window,'SamplePoints',tv_day);
    Drift_correction = Drift_correction.*mct;
    Drift_correction = fillmissing(Drift_correction,"linear");
    
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
    
    Mask = logical(zeros(size(tv)));
    Mask(tv>now) = 1;
    Bog_Height(Mask)=NaN;
    
    Snow_Groups = Map_from_Group;
    Snow_Groups(~Snow_Day)=NaN;
    Snow_flag = ismember(Map_to_Group,Snow_Groups);
    
    Snow_Depth = BH_In;
    Snow_Depth = fillmissing(Snow_Depth,"linear","MaxGap",48);
    Snow_Depth = Snow_Depth-Bog_Height;
    Snow_Depth(~Snow_flag)=0;
    Snow_Depth(Snow_Depth<0)=0;
    Snow_Depth(Mask)=NaN;
    
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

    Derived_Variables = setFolderSeparator(fullfile(db_pth_root,'Calculation_Procedures/TraceAnalysis_ini/BB/Derived_Variables/'));
    % BH_save = setFolderSeparator(fullfile(Derived_Variables,'Bog_Height'));
    fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,'Bog_Height')),'w');
    fwrite(fileID,Bog_Height,'float32');
    fclose(fileID);
    
    % SD_save = setFolderSeparator(fullfile(db_pth_root,'Calculation_Procedures/TraceAnalysis_ini/BB/Derived_Variables/Snow_Depth'));
    fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,'Snow_Depth')),'w');
    fwrite(fileID,Snow_Depth,'float32');
    fclose(fileID);
    
    % TV_save = setFolderSeparator(fullfile(db_pth_root,'Calculation_Procedures/TraceAnalysis_ini/BB/Derived_Variables/BH_tv'));
    fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,'BH_tv')),'w');
    fwrite(fileID,tv,'float64');
    fclose(fileID);
    
    
end