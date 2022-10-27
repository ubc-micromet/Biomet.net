function runEddyPro(datesIn,siteID,hfRootPath,pthRootFullOutput,run_mode,strStartTime,strEndTime)
%% Micromet function to run EddyPro recalc on a date range datesIn
%
% This function uses an EddyPro template ini file, edits it and 
% then runs EddyPro calculations for the given range of days (datesIn - datetime type).
% 
% Inputs:
%    datesIn            -   Range of days to recalculate: datetime("Jul 1,2022"):datetime("Jul 31, 2022")
%    siteID             -   Site name ('DSM' or 'RBM'...)
%    hfRootPath         -   Root path of the drive where all high-frequency data is (//micrometdrive.geog.ubc.ca/highfreq)
%                           All EddyPro templates, outputs and bin files are storred there too.
%                           Use only the drive letter. If highfreq is
%                           mapped to "y:\" use: 'y:'.
%    pthRootFullOutput  -   The summary of daily outputs ( *_full_output_*_adv.csv file) will be copied
%                           here. Those files will be then converted to database files.
%    run_mode           -   EddyPro mode:  1 - Express, 0 - Advanced (default)
%    strStartTime       -   Start time for calculations. Usually we do entire days, default is "00:00")
%    strEndTime         -   End time  for calculations. Usually we do entire days, default is "23:59")
%
% Examples:
%  Simplest call:
%     runEddyPro(datetime("Jul 1,2022"):datetime("Jul 31, 2022"),'DSM','y:/','P:/Sites')
%       (assuming that Matlab runs on vinimet, y:/ - is mapped to 'micrometdrive.geog.ubc.ca'
%        and the Sites folder is on P: drive)
%  Calculate only the last two 30-minute periods for the same 
%  range of days and the same path assumptions as above:
%      runEddyPro(datetime(2022,7,1):datetime(2022,7,31),'DSM','y:','P:/Sites',0,'23:00','23:59')
%
% Zoran Nesic               File created:           Oct 14, 2022
%                           Last modification:      Oct 18, 2022

%
% Revisions:
%
% Oct 18, 2022 (Zoran)
%   - Changed all channel numbers to -1 under assumptiong that this will make
%     EddyPro find the channels on its own.
%   - Saved the output of EddyPro run into a log file
%



    arg_default('strStartTime',"00:00");
    arg_default('strEndTime',"23:59");
    arg_default('run_mode',0);          % 1 - Express, 0 - Advanced
    
    % remove trailing '\' or '/' from hfRootPath
    if strcmp(hfRootPath(end),'/') || strcmp(hfRootPath(end),'\')
        hfRootPath = hfRootPath(1:end-1);
    end
    
    if run_mode == 0
        strRunMode = 'adv';
    else
        strRunMode = 'exp';
    end
    hfPath = fullfile(hfRootPath,siteID);

    % path to the exe file for EddyPro 
    % NOTE: EddyPro bin folder has to be copied here.
    pathEddyProExe = fullfile(hfPath,'bin');

    % eddypro project template for this site
    strTemplateFileName = fullfile(hfRootPath,siteID,'EP_templates',sprintf('%s_template.eddypro',siteID));

    % file name of eddypro ini file (../ini/processing.eddypro)
    strEddyProFileName = fullfile(hfRootPath,siteID,'ini','processing.eddypro');
    % eddypro outputs
    strEddyProOutput = fullfile(hfRootPath,siteID,'EP_outputs');

    % additional eddypro outputs
    strBinSpectraPath = fullfile(hfRootPath,siteID,'EP_outputs','eddypro_binned_cospectra');
    strBinFullSpectraPath = fullfile(hfRootPath,siteID,'EP_outputs','eddypro_full_cospectra');
    %strexFilePath = fullfile(hfRootPath,siteID,'EP_outputs','eddypro_full_cospectra');

    %% Cycle, one day at the time
    for currentDateIn = datesIn

        % Location of the high-frequency data
        strEddyProHFinput = fullfile(hfRootPath,siteID,'raw',datestr(currentDateIn,'yyyy'),datestr(currentDateIn,'mm'));


        % Create an appropriate eddypro ini file starting from the template.
        % Copy the lines that do not have keywords in them. (leave them as they are, 
        % they should be changed in the template using EddyPro)
        % Modify the lines that have the keywords.

        fidOut = fopen(strEddyProFileName,'w');
        if fidOut < 0
            error('Output file: %s cannot be opened!',strEddyProFileName);
        end
        tic

        % Read the template
        ss = fileread(strTemplateFileName);
        % Copy data 
        ss1=ss;

        % project_id 
        strProjectID = sprintf('%s_%s',siteID,datestr(currentDateIn,'yyyymmdd'));

        % replace project_id and run_mode
        ss1 = regexprep(ss1,'project_id=\w*',['project_id=' strProjectID]);
        ss1 = regexprep(ss1,'run_mode=\w*',sprintf('run_mode=%d',run_mode));

        % Replace file_name
        if filesep=='\'        
            modStrEddyProFileName = regexprep(strEddyProFileName,'\\','/');
        else
            modStrEddyProFileName = strEddyProFileName;
        end
        ss1 = regexprep(ss1,'file_name=.*?\r',sprintf('file_name=%s\r',modStrEddyProFileName));

        % Replace all relevant dates and times 
        ss1 = regexprep(ss1,'pr_start_date=....-..-..',['pr_start_date=' datestr(currentDateIn,'yyyy-mm-dd')]);
        ss1 = regexprep(ss1,'pr_end_date=....-..-..',['pr_end_date=' datestr(currentDateIn,'yyyy-mm-dd')]);
        ss1 = regexprep(ss1,'pr_start_time=..:..',['pr_start_time=' strStartTime]);
        ss1 = regexprep(ss1,'pr_end_time=..:..',['pr_end_time=' strEndTime]);

        ss1 = regexprep(ss1,'sa_start_date=....-..-..',['sa_start_date=' datestr(currentDateIn,'yyyy-mm-dd')]);
        ss1 = regexprep(ss1,'sa_end_date=....-..-..',['sa_end_date=' datestr(currentDateIn,'yyyy-mm-dd')]);
        ss1 = regexprep(ss1,'sa_start_time=..:..',['sa_start_time=' strStartTime]);
        ss1 = regexprep(ss1,'sa_end_time=..:..',['sa_end_time=' strEndTime]);

        ss1 = regexprep(ss1,'pf_start_date=....-..-..',['pf_start_date=' datestr(currentDateIn,'yyyy-mm-dd')]);
        ss1 = regexprep(ss1,'pf_end_date=....-..-..',['pf_end_date=' datestr(currentDateIn,'yyyy-mm-dd')]);
        ss1 = regexprep(ss1,'pf_start_time=..:..',['pf_start_time=' strStartTime]);
        ss1 = regexprep(ss1,'pf_end_time=..:..',['pf_end_time=' strEndTime]);

        ss1 = regexprep(ss1,'to_start_date=....-..-..',['to_start_date=' datestr(currentDateIn,'yyyy-mm-dd')]);
        ss1 = regexprep(ss1,'to_end_date=....-..-..',['to_end_date=' datestr(currentDateIn,'yyyy-mm-dd')]);
        ss1 = regexprep(ss1,'to_start_time=..:..',['to_start_time=' strStartTime]);
        ss1 = regexprep(ss1,'to_end_time=..:..',['to_end_time=' strEndTime]);


        %%  Replace all the paths 

        % For regular expression replacements below to work, the control
        % characters '\' need to be replaced with double control characters
        % first '\\'. 
        if filesep=='\'
        %     modStrEddyProOutput  = regexprep(strEddyProOutput,'\\','\\\\');
        %     modStrEddyProHFinput = regexprep(strEddyProHFinput,'\\','\\\\');
            modStrEddyProOutput  = regexprep(strEddyProOutput,'\\','/');
            modStrEddyProHFinput = regexprep(strEddyProHFinput,'\\','/');    
            modStrBinSpectraPath = regexprep(strBinSpectraPath,'\\','/');
            modStrBinFullSpectraPath = regexprep(strBinFullSpectraPath,'\\','/');  
            modpathEddyProExe = regexprep(pathEddyProExe,'\\','/');
        else
            modStrEddyProOutput  = strEddyProOutput;
            modStrEddyProHFinput = strEddyProHFinput;
            modStrBinSpectraPath = strBinSpectraPath;
            modStrBinFullSpectraPath = strBinFullSpectraPath; 
            modpathEddyProExe = pathEddyProExe;
        end

        % (find a string of characted between "out_path=" 
        %  until the first "\r". Doesn't work without "?" because instead of
        %  stopping at the first "\r" it grabs the last one at the end of the file.
        ss1 = regexprep(ss1,'out_path=.*?\r',sprintf('out_path=%s\r',modStrEddyProOutput));
        ss1 = regexprep(ss1,'data_path=.*?\r',sprintf('data_path=%s\r',modStrEddyProHFinput));
        ss1 = regexprep(ss1,'sa_bin_spectra=.*?\r',sprintf('sa_bin_spectra=%s\r',modStrBinSpectraPath));
        ss1 = regexprep(ss1,'sa_full_spectra=.*?\r',sprintf('sa_full_spectra=%s\r',modStrBinFullSpectraPath));

        % Replace the fixed channel numbers with generic ones (-1)
        ss1 = regexprep(ss1,'col_co2=.*?\r',sprintf('col_co2=-1\r'));
        ss1 = regexprep(ss1,'col_h2o=.*?\r',sprintf('col_h2o=-1\r'));
        ss1 = regexprep(ss1,'col_ch4=.*?\r',sprintf('col_ch4=-1\r'));
        ss1 = regexprep(ss1,'col_n2o=.*?\r',sprintf('col_n2o=-1\r'));
        ss1 = regexprep(ss1,'col_int_t_1=.*?\r',sprintf('col_int_t_1=-1\r'));
        ss1 = regexprep(ss1,'col_int_t_2=.*?\r',sprintf('col_int_t_2=-1\r'));
        ss1 = regexprep(ss1,'col_int_p=.*?\r',sprintf('col_int_p=-1\r'));
        ss1 = regexprep(ss1,'col_air_t=.*?\r',sprintf('col_air_t=-1\r'));
        ss1 = regexprep(ss1,'col_air_p=.*?\r',sprintf('col_air_p=-1\r'));
        ss1 = regexprep(ss1,'col_cell_t=.*?\r',sprintf('col_cell_t=-1\r'));
        ss1 = regexprep(ss1,'col_diag_75=.*?\r',sprintf('col_diag_75=-1\r'));
        ss1 = regexprep(ss1,'col_diag_72=.*?\r',sprintf('col_diag_72=-1\r'));
        ss1 = regexprep(ss1,'col_diag_77=.*?\r',sprintf('col_diag_77=-1\r'));
        ss1 = regexprep(ss1,'col_diag_anem=.*?\r',sprintf('col_diag_anem=-1\r'));
        ss1 = regexprep(ss1,'col_ts=.*?\r',sprintf('col_ts=-1\r'));
        ss1 = regexprep(ss1,'biom_ta=.*?\r',sprintf('biom_ta=-1\r'));
        ss1 = regexprep(ss1,'biom_pa=.*?\r',sprintf('biom_pa=-1\r'));
        ss1 = regexprep(ss1,'biom_lwin=.*?\r',sprintf('biom_lwin=-1\r'));
        ss1 = regexprep(ss1,'biom_ppfd=.*?\r',sprintf('biom_ppfd=-1\r'));
        
        
        % Save the new template and close the file handle
        fprintf(fidOut,'%s',ss1);
        fclose(fidOut);

        %% Create EddyPro batch file
        pathToBatchFile = fullfile(pathEddyProExe,'runEddyPro.bat'); 
        fidEP = fopen(pathToBatchFile,'w');
        if fidEP < 0
            error('Output file: %s cannot be opened!',fullfile(tempdir,'runEddyPro.bat'));
        end
        %fprintf(fidEP,'set PATH=%%PATH%%;%s\n',pathEddyProExe);
        fprintf(fidEP,'%s\n',hfRootPath);
        fprintf(fidEP,['cd "' modpathEddyProExe '"\n']);
        fprintf(fidEP,'eddypro_rp.exe\n');
        fprintf(fidEP,'eddypro_fcc.exe\n');
        fclose(fidEP);


        % Run the batch file
        fprintf('%s ---> EddyPro processing %s site: %s . Please wait.\n',datetime("now"),siteID,datestr(currentDateIn));
        [~,cmdOut] = system(pathToBatchFile);   % system(pathToBatchFile,'-echo') - to see the batch output while processing
        fprintf('   %s ---> Done!\n',datetime("now"));
        
        % Save cmdOut
        fidLog = fopen(fullfile(strEddyProOutput,['eddypro_' strProjectID '.log']),'w');
        if fidLog > 0
            fprintf(fidLog,'%s',cmdOut);
            fclose(fidLog);
        end
        
        

        %%
        % copy results to the the folder where database program can process them
        %  - search for all old calculations for the same date and move them to the
        %    old folder (keep the EP_outputs clean, one day -> one data set regardless of
        %    how many re-calcs have been done on that day.
        %  - search for all files with name "eddypro_siteID_yyyymmdd_full_output*.csv"
        %    for the currentDate
        %  - find the newest recalc for that date
        %  - copy it to the folder where _full_output_ files go
        %  - we should keep only the newest _full_output_ files and move the older ones
        %    under .\old 

        % Find older recalcs and move them to the old folder
        fprintf('   Moving older recalcs under %s/old folders.\n',strEddyProOutput);
        wildCard = sprintf('*_%s_full_output*.*',strProjectID);
        filesMoved = findAndMoveOldFiles(strEddyProOutput,fullfile(strEddyProOutput,'old'),wildCard); %#ok<*NASGU>
%         fprintf('%d (%s) files moved\n',filesMoved,wildCard);
        
        wildCard = sprintf('*_%s_biomet_*.*',strProjectID);
        filesMoved = findAndMoveOldFiles(strEddyProOutput,fullfile(strEddyProOutput,'old'),wildCard);
%         fprintf('%d (%s) files moved\n',filesMoved,wildCard);

        wildCard = sprintf('*_%s_fluxnet_*.*',strProjectID);
        filesMoved = findAndMoveOldFiles(strEddyProOutput,fullfile(strEddyProOutput,'old'),wildCard);
%         fprintf('%d (%s) files moved\n',filesMoved,wildCard);
        
        wildCard = sprintf('*_%s_metadata_*.*',strProjectID);
        filesMoved = findAndMoveOldFiles(strEddyProOutput,fullfile(strEddyProOutput,'old'),wildCard);
%         fprintf('%d (%s) files moved\n',filesMoved,wildCard);
        
        wildCard = sprintf('*_%s_qc_details_*.*',strProjectID);
        filesMoved = findAndMoveOldFiles(strEddyProOutput,fullfile(strEddyProOutput,'old'),wildCard);
%         fprintf('%d (%s) files moved\n',filesMoved,wildCard);
        
        % Move to ./old all eddypro ini file but the latest one. 
        % File names start with wildCard in the format processing_yyyy*.* 
        wildCard = 'processing_2*.*';
        filesMoved = findAndMoveOldFiles(strEddyProOutput,fullfile(strEddyProOutput,'old'),wildCard);
%         fprintf('%d (%s) files moved\n',filesMoved,wildCard);

        % rename the last ini file to processing_YYYYMMDD of the currentDateIn
        s = dir(fullfile(strEddyProOutput,wildCard));
        if length(s) >= 1
            try
                movefile(fullfile(strEddyProOutput,s(1).name),...
                    fullfile(strEddyProOutput,sprintf('processing_%s_%s.eddypro',strProjectID,strRunMode)))
            catch
            end
        end
           
        %% Copy _full_output_ files to pthRootFullOutput (Usually: vinimet p:/sites)        
        % Make sure that the final file destination exists and it's reachable
        % File path to the location (usually ./Sites/siteID/Flux/EP_outputs)
        pthFullOutputFiles = fullfile(pthRootFullOutput,siteID,'Flux','EP_outputs');
        % check if the output folder exists, create if needed
        if ~exist(pthFullOutputFiles,'dir')
            mkdir(pthFullOutputFiles)
        end        
        
        % find the _full_output_ file
        outputFiles = dir(fullfile(strEddyProOutput,sprintf('eddypro_%s_full_output*.csv',strProjectID)));
        if length(outputFiles) >= 1
            % if file found copy it to the final destination
            sourceFile      = fullfile(outputFiles(1).folder,outputFiles(1).name);
            destinationFile = fullfile(pthFullOutputFiles,outputFiles(1).name); 
            try
                copyfile(sourceFile,destinationFile);
            catch
                fprintf('   File %s could not be copied to %s!\n',sourceFile,destinationFile)
            end            
        end
        % move the old eddypro files for the same date from the pthRootFullOutput into 
        % pthFullOutputFiles/old folder
        wildCard = sprintf('eddypro_%s_full_output*.csv',strProjectID);
        filesMoved = findAndMoveOldFiles(pthFullOutputFiles,fullfile(pthFullOutputFiles,'old'),wildCard);
%         fprintf('%d (%s) files moved\n',filesMoved,wildCard);
        
        fprintf('   Elapsed time is %6.2f\n',toc);
    end

    % run database program on the folder with _full_output_ files
    %   - process only the newest files
end


function filesMoved = findAndMoveOldFiles(sourceFolder, destinationFolder,wildCard,flagMoveEverything)
    arg_default('flagMoveEverything',false);
    filesMoved = 0;
    
    % find all files that fit the wildCard in the sourceFolder
    allRecalcs = dir(fullfile(sourceFolder,wildCard));
    
    if length(allRecalcs) > 1       
        % find the index of the newest file
        dateNewest = datenum(1990,1,1);
        cntNewest = 0;
        for cntFiles = 1:length(allRecalcs)
            if allRecalcs(cntFiles).datenum > dateNewest
                dateNewest = allRecalcs(cntFiles).datenum;
                cntNewest = cntFiles;
            end
        end 
        
        % check if the output folder exists, create if needed
        if ~exist(destinationFolder,'dir')
            mkdir(destinationFolder)
        end
        % move all but the newest file to destinationFolder
        filesMoved = 0;
        for cntFiles = 1:length(allRecalcs)
            if (cntFiles ~= cntNewest) && ~flagMoveEverything
                sourceFile = fullfile(allRecalcs(cntFiles).folder,allRecalcs(cntFiles).name);
                destinationFile = fullfile(allRecalcs(cntFiles).folder,'old',allRecalcs(cntFiles).name);
                try
                    movefile(sourceFile,destinationFile);
                    filesMoved = filesMoved+1;
                catch
                    fprintf('File %s could not be copied to %s!\n',sourceFile,destinationFile)
                end
            end
        end 
        
    end
    
    
end


