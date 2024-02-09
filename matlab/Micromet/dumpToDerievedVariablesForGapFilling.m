function dumpToDerievedVariablesForGapFilling(SiteID,FirstYear,trace_names);
    % Written by June Skeeter
    % Jan 30, 2024
    % Dump full time-series of met traces to Derived Variables so they can be used for second stage gap-filling of other met variables

    arg_default('SiteID','BB');
    arg_default('FirstYear',2014);
    arg_default('trace_names',{'TA_1_1_1','RH_1_1_1','P_1_1_1'});
    current_year = year(datetime);
    
    Derived_Variables = setFolderSeparator(fullfile(db_pth_root,'Calculation_Procedures/TraceAnalysis_ini/',SiteID,'/Derived_Variables/'));

    for i=1:length(trace_names)
        trace_name = trace_names{i};
        [trace,clean_tv] = read_db([FirstYear:current_year],SiteID,'Clean/SecondStage',trace_name);
        
        fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,trace_name)),'w');
        fwrite(fileID,trace,'float32');
        fclose(fileID);
        
        daily =  movmean(trace,[1 0],'omitnan','SamplePoints',clean_tv);
        fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,strcat(trace_name,'_moving_daily_mean'))),'w');
        fwrite(fileID,daily,'float32');
        fclose(fileID);
        
        monthly =  movmean(trace,[30 0],'omitnan','SamplePoints',clean_tv);
        fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,strcat(trace_name,'_moving_monthly_mean'))),'w');
        fwrite(fileID,monthly,'float32');
        fclose(fileID);
    
        seasonal =  movmean(trace,[90 0],'omitnan','SamplePoints',clean_tv);
        fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,strcat(trace_name,'_moving_seasonal_mean'))),'w');
        fwrite(fileID,seasonal,'float32');
        fclose(fileID);
    end
    
    fileID = fopen(setFolderSeparator(fullfile(Derived_Variables,'Met_tv')),'w');
    fwrite(fileID,clean_tv,'float64');
    fclose(fileID);
    
end