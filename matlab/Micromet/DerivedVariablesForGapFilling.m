function [data_out,clean_tv] = DerivedVariablesForGapFilling(SiteID,FirstYear,trace_names,read_or_write,interpolate,moving_avg);
    % Written by June Skeeter
    % Jan 30, 2024
    % Dump full time-series of met traces to Derived Variables so they can be used for second stage gap-filling of other met variables

    arg_default('SiteID','BB');
    arg_default('FirstYear',2014);
    arg_default('trace_names',{'TA_1_1_1','RH_1_1_1','P_1_1_1'});
    arg_default('read_or_write',1) % 0 = read, 1 = write
    arg_default('interpolate',1); % 0 = don't interpolate, 1 = do interpolate
    arg_default('moving_avg',1); % 0 = don't get moving averages, 1 = do get moving averages
    current_year = year(datetime);
    
    Derived_Variables = setFolderSeparator(fullfile(db_pth_root,'Calculation_Procedures/TraceAnalysis_ini/',SiteID,'/Derived_Variables/'));
    Database_path = setFolderSeparator(fullfile(db_pth_root,string(FirstYear),SiteID,'Clean/SecondStage'));
    for i=1:length(trace_names)
        trace_name = trace_names{i};
        if read_or_write == 1 & exist(setFolderSeparator(fullfile(Database_path,trace_name))) == 2
            [trace,clean_tv] = read_db([FirstYear:current_year],SiteID,'Clean/SecondStage',trace_name);
            if interpolate == 1
                trace = interp1(clean_tv(isfinite(trace)),trace(isfinite(trace)),clean_tv);
            end
            fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,trace_name)),'w');
            fwrite(fileID,trace,'float32');
            fclose(fileID);
        
            if moving_avg == 1
                % Daily Mean
                daily =  movmean(trace,[1 0],'omitnan','SamplePoints',clean_tv);
                fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,strcat(trace_name,'_moving_daily_mean'))),'w');
                fwrite(fileID,daily,'float32');
                fclose(fileID);
                % Monthly Mean
                monthly =  movmean(trace,[30 0],'omitnan','SamplePoints',clean_tv);
                fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,strcat(trace_name,'_moving_monthly_mean'))),'w');
                fwrite(fileID,monthly,'float32');
                fclose(fileID);
                % Seasonal Mean
                seasonal =  movmean(trace,[90 0],'omitnan','SamplePoints',clean_tv);
                fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,strcat(trace_name,'_moving_seasonal_mean'))),'w');
                fwrite(fileID,seasonal,'float32');
                fclose(fileID);
            end
            data_out = NaN;
        elseif read_or_write == 0
            if i == 1
                fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,"Met_tv")),'r');
                clean_tv = fread(fileID,'float64');
                fclose(fileID);
                data_out = NaN(length(clean_tv),length(trace_names));
            end
            fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,trace_name)),'r');
            data_out(:,i) = fread(fileID,'float32');
            fclose(fileID);
        else
            sprintf('Could not find: %s',setFolderSeparator(fullfile(Database_path,trace_name)))
        end
    end
    
    if read_or_write == 1
        fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,'Met_tv')),'w');
        fwrite(fileID,clean_tv,'float64');
        fclose(fileID);
    end
    
end