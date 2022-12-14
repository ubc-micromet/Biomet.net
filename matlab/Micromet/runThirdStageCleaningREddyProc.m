function runThirdStageCleaningREddyProc(yearIn,siteID,Ustar_scenario,yearsToProcess,do_REddyProc)
% runThirdStageCleaningREddyProc(yearIn,siteID)
%
% This function invokes Micromet third-stage cleaning R-script.
% Usually, it's called from fr_automated_cleaning()
%
% Arguments
%   yearIn          - year to clean
%   Ustar_scenario  - 'fast' (default) and 'full' (see REddyProc for details)
%   yearsToProcess  - 1 (default) or more. REddyProc can use more years 
%                     for gap-filling even when outputing one year only
%
% Zoran Nesic               File created:       Oct 25, 2022
%                           Last modification:  Nov  7, 2022
%

% Revisions
%
% Nov 7, 2022 (Zoran)
%  - Changed yearsToProcess from 1 to 99. Now all data for the site will be
%    used for gap filling
% Nov 6, 2022 (Zoran)
%  - Added some comments
% Nov 5, 2022 (Zoran)
%  - changed the way ini data gets transfered to R. Instead of having a csv
%    ini file siteID_ThirdStageCleaningParameters.ini, we'll use an 
%    R script named: siteID '_setThirdStageCleaningParameters.R
%    Much easier for the users.
% Nov 2, 2022 (Zoran)
%  - changed the name of main R script to Run_ThirdStage_REddyProc.R
%  - arguments for R script are now passed mostly as data in an ini
%    file: siteID_ThirdStageCleaningParameters.ini. Only the path to
%    the ini file is passed directly as an input argument to Run_ThirdStage_REddyProc.R

    if ~ispc
        error('This function is not compatible with macOS, yet!\n');
    end
    
    % Prepare input parameters, create defaults if needed
    arg_default('Ustar_scenario','fast')  % use fast processing (other option is 'full')
    arg_default('yearsToProcess',99);     % Use all years since the site was established for gap filling
    arg_default('do_REddyProc',1);


    % find path to R database_functions folder
    pthBiometR = findBiometRpath;
    pthBiometR(strfind(pthBiometR,"\"))="/";  % Convert the separator to R's prefered.
    
    % find path to database
    pthDatabase = findDatabasePath;
    pthDatabase(strfind(pthDatabase,"\"))="/"; % Convert the separator to R's prefered.
    
    % This one should be under ../Database/Calculation_procedures\TraceAnalysis_ini\siteID:
    pthIni = fullfile(pthDatabase,'Calculation_Procedures','TraceAnalysis_ini',siteID);
    pthIni(strfind(pthIni,"\"))="/";       % Convert the separator to R's prefered.
    
    % Find path to the newest version of Rscript
    pthRbin = findRPath;    

    % create all file paths
    % log files go under ../database/Calculation_Procedures\TraceAnalysis_ini\siteID\log
    if ~exist(fullfile(pthIni,'log'),'dir')
        mkdir(fullfile(pthIni,'log'))
    end    
    pthLogFile = fullfile(pthIni,'log',[siteID '_ThirdStageCleaning.log']);
    pthLogFile(strfind(pthLogFile,"\"))="/";       % Convert the separator to R's prefered.
    
    % the *.bat file that runs Rscript also goes into the log folder 
    pthBatchFile = fullfile(pthIni,'log',[siteID '_ThirdStageCleaning.bat']);
    
    % The cleaning script Run_REddyProc_ThirdStage_siteID.R is under ../Biomet.net/R
    pthCleaningScript = fullfile(pthBiometR,'Run_ThirdStage_REddyProc.R');
    pthCleaningScript(strfind(pthCleaningScript,"\"))="/";       % Convert the separator to R's prefered.
    
    
    % Create an input file for StageThreeREddyProc() function and pass 
    % all the arguments to it. Store that file with .bat and .log files:
    pthSetClParam = fullfile(pthIni,'log',[siteID '_setThirdStageCleaningParameters.R']);
    
    % Get the function stack (it will be needed to extract this function's name)
    st=dbstack;
    
    % Store the ini parameters in pthSetClParam
    fidIni = fopen(pthSetClParam,'w');
    if fidIni <0
        error('Could not open %s file!\n',pthSetClParam);
    end
    fprintf(fidIni,'#-------------------------------------------------------------\n');
    fprintf(fidIni,'# This file is automatically generated by the Matlab function:\n');
    fprintf(fidIni,'# %s.m\n',st(1).name);
    fprintf(fidIni,'# %s\n',datestr(now));
    fprintf(fidIni,'#--------------------------------------------------------------\n');
    fprintf(fidIni,'site    <- "%s"\n',siteID);
    fprintf(fidIni,'yrs     <- %d\n',yearIn);
    fprintf(fidIni,'db_root <- "%s"\n',pthDatabase);
    fprintf(fidIni,'fx_path <- "%s"\n',pthBiometR);
    fprintf(fidIni,'Ustar_scenario <- "%s"\n',Ustar_scenario);
    fprintf(fidIni,'do_REddyProc   <- %d\n',do_REddyProc);
    fprintf(fidIni,'yearsToProcess <- %d\n',yearsToProcess);
    fprintf(fidIni,'pthDatabase    <- "%s"\n',pthDatabase);
    fprintf(fidIni,'pthBiometR     <- "%s"\n',pthBiometR);
    fprintf(fidIni,'pthLogFile     <- "%s"\n',pthLogFile);
    fprintf(fidIni,'ini_path       <- "%s"\n',pthIni);
    fclose(fidIni);
    
    
    % create the batch file command line 
    cmdLine = ['"' pthRbin '" "'  pthCleaningScript '" "' pthBiometR '" "' pthSetClParam '" '...
               ' 2> "' pthLogFile '" 1>&2'];
    tic;
    tv_start = now;
    % Create the batch file that calls R
    fidBatch = fopen(pthBatchFile,'w');
    if fidBatch <0
        error('Could not open %s file!\n',fidBatch);
    end
    fprintf(fidBatch,'REM ----------------------------------------------------------\n');
    fprintf(fidBatch,'REM  This file is automatically generated by Matlab function:\n');
    fprintf(fidBatch,'REM  %s.m\n',st(1).name);
    fprintf(fidBatch,'REM  %s\n',datestr(now));
    fprintf(fidBatch,'REM ----------------------------------------------------------\n');
    fprintf(fidBatch,'%s\n',cmdLine);
    fclose(fidBatch);
    [~,cmdOutput] = system(pthBatchFile); %#ok<ASGLU>

    % When R is finshed, print the footer in the log file
    fidLog = fopen(pthLogFile,'a');      
    if fidLog > 0    
        fprintf(fidLog,'\n\n\n\n');
        fprintf(fidLog,'=============================================================\n');
        fprintf(fidLog,'Rscript:      %s\n',pthRbin);
        fprintf(fidLog,'Start:        %s\n',datestr(tv_start));
        fprintf(fidLog,'End:          %s\n',datestr(now));
        fprintf(fidLog,'Elapsed time: %6.1f min\n',toc/60);
        fprintf(fidLog,'==============================================================\n'); 
        fclose(fidLog);
    end

end

function biometRpath = findBiometRpath
    funA = which('read_bor');     % First find the path to Biomet.net by looking for a standard Biomet.net functions
    tstPattern = [filesep 'Biomet.net' filesep];
    indFirstFilesep=strfind(funA,tstPattern);
    biometRpath = fullfile(funA(1:indFirstFilesep-1),tstPattern,'R', 'database_functions');
end

function databasePath = findDatabasePath
    databasePath = biomet_path('yyyy');
    indY = strfind(databasePath,'yyyy');
    databasePath = databasePath(1:indY-2); 
end

function Rpath = findRPath
    pathMatlab = matlabroot;
    indY = strfind(upper(pathMatlab),[filesep 'MATLAB']);
    pathBin = fullfile(pathMatlab(1:indY-1));
    s = dir(fullfile(pathBin,'R','R-*')); 
    if length(s) < 1
        error ('Cannot find location of R inside of %s\n',pathBin);
    end
    Rpath = "";
    N = 0;
    for cntFolders = 1:length(s)
        if s(cntFolders).name > Rpath
            Rpath = s(cntFolders).name;
            N = cntFolders;
        end
    end
    Rpath = fullfile(s(N).folder,s(N).name,'bin','Rscript.exe');
end
        

