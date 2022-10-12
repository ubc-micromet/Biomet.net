%% Micromet function to run EddyPro recalc on a date range datesIn
%
% Inputs:
datesIn = datetime("July 15, 2022"):datetime("July 17, 2022");
strStartDate = datestr(datesIn(1),'yyyymmdd');
strEndDate = datestr(datesIn(end),'yyyymmdd');
% calculations are done for the entire day so time span goes:
strStartTime = '23:00';
strEndTime = '23:59';
% site name
siteID = 'DSM';
% HF data path
%hfRootPath = 'y:/';
hfRootPath = 'y:';


% Express or advanced
run_mode = 0;  % 1 - Express, 0 - Advanced


%%
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
    fprintf('%s ---> Processing: %s. Please wait.\n',datetime("now"),datestr(currentDateIn));
    [~,cmdOut] = system(pathToBatchFile);   % system(pathToBatchFile,'-echo') - to see the batch output while processing
    fprintf('%s ---> Done!\n',datetime("now"));
    
    % copy results to the the folder where database program can process them
    
    toc
end

% run database program




