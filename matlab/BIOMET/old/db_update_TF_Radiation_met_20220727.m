function db_update_TF_Radiation_met(yearIn)
    % Totem Field Radiation data Processing
    %
    % user can input yearIn
    %
    %                                       file created:  Oct  26, 2020
    %                                       last modified: July 13, 2022
    %

    % function based on db_update_YF_met

    % Revisions:
    %
    % July 13, 2022 (Zoran)
    %   - blocked the program from being used on the years before 2021. The
    %     data between 2017 and Apr 2021 has been recorded using PST time.
    %     Then we switched to GMT time on Apr 13, 2020. To align these
    %     traces with the rest of our database, the data has been manually
    %     altered using the program:
    %     climateStation_TF_radiation_time_correction.m. This is a one-time
    %     change so that's why this program has to be prevented of altering
    %     the data again.
    % July 11, 2022 (Zoran)
    %   - added creating 30-minute database files from 10-min files
    %   - simplified the lines by removing a bunch of eval statements.
    %

    if yearIn < 2021
        fprintf('This program cannot be used for data before 2021!\n');
        fprintf('The data has been manually altered after the original database conversion\n');
        fprintf('to adjust the time from PST to GMT (see file:climateStation_TF_radiation_time_correction.m\n');
        fprintf('Exiting...\n');
        error('Do not use this program for years before 2021!');
    end

    dv=datevec(now);
    arg_default('yearIn',dv(1));
    arg_default('sites',{'UBC_Totem'});
    Site = 'UBC_Totem';
    % Add file renaming + copying to \\paoa001
    pth_db = db_pth_root;

    for k=1:length(yearIn)

        % Progress list for TF (CR1000) logger (10-min MET data)
        progressList_UBC_Totem_Radiation_30min_MET_Pth = fullfile(pth_db,sprintf('UBC_Totem_TF_Radiation_progressList_%d.mat',yearIn(k)));

        % Progress list for TF (CR1000) logger (10-min RAW data)
        progressList_UBC_Totem_Radiation_30min_RAW_Pth = fullfile(pth_db,sprintf('UBC_Totem_TF_Radiation_RAW_progressList_%d.mat',yearIn(k)));

        % Climate database path
        UBC_Totem_ClimateDatabase_Pth = fullfile(pth_db,'yyyy\UBC_Totem\Radiation\');


        % Process TF CR1000  logger

        % RAW Table
        filesToProcess = fullfile('D:\sites\UBC\CSI_net\Totem_Radiometer_Data',sprintf('CR1000_TF_Radiation_RAW.%d*',yearIn(k)));
        [numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(filesToProcess,[],[],[],progressList_UBC_Totem_Radiation_30min_RAW_Pth,fullfile(UBC_Totem_ClimateDatabase_Pth,'TABLE_RAW'),2,0,10);

        fprintf('%s CR1000_TF_Radiation_RAW (%d): Number of files processed = %d, Number of samples = %d\n',Site,yearIn(k),numOfFilesProcessed,numOfDataPointsProcessed)


        % MET Table
        filesToProcess = fullfile('D:\sites\UBC\CSI_net\Totem_Radiometer_Data',sprintf('CR1000_TF_Radiation_MET.%d*',yearIn(k)));
        [numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(filesToProcess,[],[],[],progressList_UBC_Totem_Radiation_30min_MET_Pth,UBC_Totem_ClimateDatabase_Pth,2,0,10);

        fprintf('%s CR1000_TF_Radiation_MET(%d): Number of files processed = %d, Number of samples = %d\n',Site,yearIn(k),numOfFilesProcessed,numOfDataPointsProcessed)

        %======================
        % Update 30min MET data
        %======================
        convert_10min_to_30min_data(UBC_Totem_ClimateDatabase_Pth,yearIn(k))
        %======================
        % Update 30min RAW data
        %======================
        convert_10min_to_30min_data(fullfile(UBC_Totem_ClimateDatabase_Pth,'TABLE_RAW'),yearIn(k))

    end %k
end


function convert_10min_to_30min_data(inputPath,yearIn)
    % create the 30min folder if it doesn't exist already
    pth10min = inputPath;
    indYYYY = strfind(pth10min,'yyyy');
    pth10min(indYYYY:indYYYY+3) = sprintf('%d',yearIn);
    pth30min = fullfile(pth10min,'30min');
    mkdir(pth30min);
    % Create the time vector
    tv = fr_round_time(datenum(yearIn,1,1,0,30,0):1/48:datenum(yearIn+1,1,1,0,0,0))';
    % Load up all data traces from the 10-min RAW_TABLE folder
    s = dir(pth10min);
    for cntFile = 1:length(s)
        traceName = s(cntFile).name;
        if ~s(cntFile).isdir & ~(strcmpi(traceName,'Clean_tv') | strcmpi(traceName, 'TimeVector')) %#ok<*OR2,*AND2>
            data_10min = read_bor(fullfile(pth10min,traceName));
            data_30min = fastavg(data_10min,3);
            % save 30-min data
            save_bor(fullfile(pth30min,traceName),1,data_30min);
            % special processing for year 2017. For this year we have
            % Andreas' 30-min processed data (folder ..\30min\original_30min_do_not_delete
            % and a bit of 10-min data. For this year only, join these
            % files
            if yearIn==2017
                try
                    data30min_original = read_bor(fullfile(pth30min,'original_30min_do_not_delete',traceName));
                    dataNew = data30min_original;
                    indPointToFill = 12000:length(dataNew);
                    dataNew(indPointToFill) = data_30min(indPointToFill);
                    save_bor(fullfile(pth30min,traceName),1,dataNew);
                catch
                end
            end
        end
    end
    % save time vectors
    save_bor(fullfile(pth30min,'TimeVector'),8,tv);
    save_bor(fullfile(pth30min,'Clean_tv'),8,tv);
end