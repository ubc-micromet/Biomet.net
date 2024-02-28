
function SubSurfaceGapfilling(SiteID,var_name_root);
% Written by June Skeeter
% Jan 30, 2024
% Gap-fill sub-surface data for BB sites (accounting for sensor movement/issues at BB1)

arg_default('SiteID','BB');
arg_default('var_name_root','VWC');
arg_default('inspect',0);
arg_default('recalc',0);
arg_default('fill_vars',{'TA_1_1_1','RH_1_1_1','P_1_1_1'})

gap_fill_id='_gap-filled';


Derived_Variables = setFolderSeparator(fullfile(db_pth_root,'Calculation_Procedures/TraceAnalysis_ini/',SiteID,'/Derived_Variables/'));
SecondStage = setFolderSeparator(fullfile(db_pth_root,sprintf('%i',year(datetime('now'))),SiteID,'Clean/SecondStage'));
files = dir(strcat(SecondStage,'\',var_name_root,'_*_*_*'));


if strcmp(SiteID,'BB')
    FirstYear = 2014;
elseif strcmp(SiteID,'BB2')
    FirstYear = 2019;
else
    FirstYear = 2023;
end



for i=1:length(files)
    if ~contains(files(i).name,gap_fill_id)
        fill_name = files(i).name;


    [y_fill,clean_tv] = read_db([FirstYear:2024],SiteID,'Clean/SecondStage',fill_name);
    DT = datetime(clean_tv,"ConvertFrom","datenum");
    y_index = isfinite(y_fill);
    
    intercept = ones(size(clean_tv));
    DOY = day(DT,'dayofyear');
    % start hydrologic year on vernal equinox
    DHY = DOY-264;
    DHY(DHY<0) = DHY(DHY<0)+(365);
    Season = intercept;
    Season(and(month(DT)>=3,month(DT)<=5))=2;
    Season(and(month(DT)>=6,month(DT)<=8))=3;
    Season(and(month(DT)>=9,month(DT)<=11))=4;
    X_fill = [ones(size(clean_tv)),DHY,Season];
    
    names = cell(1,1);
    names{1} = 'intercept';
    names{2} = 'season';
    names{3} = 'day of hydrologic year';
    if isfile(setFolderSeparator(fullfile(Derived_Variables,"Met_tv")))
        disp(sprintf('Loading Derrived Met Data to fill %s',fill_name))
        fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,"Met_tv")),'r');
        Met_tv = fread(fileID,'float64');
        fclose(fileID);
        [~,ix] = intersect(Met_tv,clean_tv,"stable");
    
        for i=1:length(fill_vars)
            trace_name=fill_vars{i};
            fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,trace_name)),'r');
            trace = fread(fileID,'float32');
            fclose(fileID);
            X_fill(:,end+1) = trace(ix);
            names{length(names)+1}=trace_name;
    
            trace_name=strcat(fill_vars{i},'_moving_daily_mean');
            fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,trace_name)),'r');
            daily = fread(fileID,'float32');
            fclose(fileID);
            X_fill(:,end+1) = daily(ix);
            names{length(names)+1}=trace_name;
       
            trace_name=strcat(fill_vars{i},'_moving_monthly_mean');
            fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,trace_name)),'r');
            monthly = fread(fileID,'float32');
            fclose(fileID);
            X_fill(:,end+1) = monthly(ix);
            names{length(names)+1}=trace_name;

            trace_name=strcat(fill_vars{i},'_moving_seasonal_mean');
            fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,trace_name)),'r');
            seasonal = fread(fileID,'float32');
            fclose(fileID);
            X_fill(:,end+1) = seasonal(ix);
            names{length(names)+1}=trace_name;
        end
    
    end
    X_index = isfinite(X_fill);
    
    ix = and(y_index,min(X_index,[],2));
    X_sub = X_fill(ix,:);
    y_sub = y_fill(ix);
    
    sample=zeros(size(y_sub));
    sample(1:round(length(y_sub)*.75))=1;
    sample=logical(sample(randperm(length(sample))));
    
    X_train=X_sub(sample,:);
    y_train=y_sub(sample);
    
    X_test=X_sub(~sample,:);
    y_test=y_sub(~sample);
    
    % figure
    % hold on;
    
    coeffs = X_train\y_train;
    yCalc1 = X_test*coeffs;
    % scatter(y_test,yCalc1)
    Benchmark = 1 - sum((y_test - yCalc1).^2)/sum((y_test - mean(y_test)).^2);
    disp('')
    drop = zeros(size(coeffs));
    coeff_ix=1:length(coeffs);
    flag = 0;
    for i=1:length(coeffs)-1
        Rsq = [];
        for j=1:length(coeffs)
            if ~ismember(j,coeff_ix(logical(max(drop,[],2))))
                test_ix=logical(ones(length(coeffs),1));
                test_ix(j)=0;
                X_train_prune = X_train(:,and(~max(drop,[],2),test_ix));
                X_test_prune = X_test(:,and(~max(drop,[],2),test_ix));
    
                alt = X_train_prune\y_train;
                yalt = X_test_prune*alt;
                Rsq(end+1,1) = 1 - sum((y_test - yalt).^2)/sum((y_test - mean(y_test)).^2);
            else
                Rsq(end+1,1) = 0;
            end
        end
    
        drop(:,end+1) = Rsq == max(Rsq);
        X_train_prune = X_train(:,~max(drop,[],2));
        X_test_prune = X_test(:,~max(drop,[],2));
        newcoeffs = X_train_prune\y_train;
        yCalc1 = X_test_prune*newcoeffs;
        newBenchmark = 1 - sum((y_test - yCalc1).^2)/sum((y_test - mean(y_test)).^2);
    
    
        if newBenchmark<Benchmark-Benchmark*.025
            drop=drop(:,1:end-1);
            X_train_prune = X_train(:,~max(drop,[],2));
            X_test_prune = X_test(:,~max(drop,[],2));
            newcoeffs = X_train_prune\y_train;
            yCalc1 = X_test_prune*newcoeffs;
            % scatter(y_test,yCalc1)
            % grid on
            R2 = 1 - sum((y_test - yCalc1).^2)/sum((y_test - mean(y_test)).^2);
            RMSE = mean((y_test -yCalc1).^2).^.5;
            disp(sprintf('Threshold Reached, Validation Metrics: R2 %.3f RMSE %.3f',R2, RMSE))
            % disp(sprintf('%',names{~max(drop,[],2)}))
            break
        end
    
    
    end
    
    X_fill_prune = X_fill(:,~max(drop,[],2));
    y_estimate = X_fill_prune*newcoeffs;
    y_fill(isnan(y_fill)) = y_estimate(isnan(y_fill));
    
    shift = clean_tv(2)-clean_tv(1);
    DT = datetime(clean_tv-shift,"ConvertFrom","datenum");
    yyyy = year(DT);
    
    for yr=min(yyyy):max(yyyy)
    
        out = setFolderSeparator(fullfile(db_pth_root,sprintf('%i',yr),SiteID,'Clean/SecondStage',strcat(fill_name,gap_fill_id)));
        
        d_out = y_fill(yyyy==yr);
        fileID = fopen(out,'w');
        fwrite(fileID,d_out,'float32');
        fclose(fileID);
        % 
    end

    end
end

