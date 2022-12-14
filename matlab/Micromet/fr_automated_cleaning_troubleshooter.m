%% Script for troubleshooting of fr_automated_cleaning process

% Create output folder that contains:
%   - Open a file in the outputRecalcFolder (recalc.log) with any important 
%     info about the the curent recalcs
%       
%    
%   - Biomet.Net that's being used for the recalcs
%   - TraceAnalysis.ini\siteID folder that's being used
%   - UBC_PC_setup folder that's being used
%
% Setup paths (function recalc_configure)
% Set current Matlab folder to outputFolder name 
% Export (append) the current Matlab path to readme.txt 
% Run ta_automated cleaning 
%   - 1 year, 1:3 stages
% Copy all clean data folders (stages 1:3) to outputRecalcFolder\database
% 
% Return paths back to Biomet defaults (run startup)?
%

colordef white %#ok<COLORDEF>

% *** Be careful to check all the input parameters!!  ***
yearIn = 2021;
siteID = 'MPB1';
originalDatabaseFolder  = '\\annex001\database\'; 
outputRecalcFolder =  'D:\junk\recalc_tests\Test12';
%originalBiometNetFolder = 'D:\Biomet.net_DailyBackups\2022-07-17\Biomet.net\Matlab';
%originalBiometNetFolder = 'D:\Biomet.net_DailyBackups\2022-07-19\Biomet.net\Matlab';
originalBiometNetFolder = 'c:\Biomet.net\Matlab';  % this produces identical outputs if First/Second/ThirdStage.ini files are not edited.
originalSiteSpecificFolder = fullfile('\\paoa001\Sites\',siteID,'ubc_pc_setup\Site_specific');
originalPCSpecificFolder   = 'c:\ubc_pc_setup\pc_specific';
fileFirstStageIni          = sprintf('%s_FirstStage.ini',siteID);
fileSecondStageIni         = sprintf('%s_SecondStage.ini',siteID); %sprintf('%s_SecondStage.ini',siteID);
fileThirdStageIni          = sprintf('%s_ThirdStage.ini',siteID);

folderCreatedNow = 1;  % default is to run database backup of ANNEX001 before running a new test
if ~exist(outputRecalcFolder,'dir')
    mkdir(outputRecalcFolder);   
else
    folderCreatedNow = 0; % the folder already exist. Do not run ANNEX001 backup
    answer = questdlg('Do you want to overwrite all custom TraceAnalysis_ini files with the originals?', ...
                    'First/Second/ThirdStage.ini overwrite', ...
                    'Yes','No','Cancel','No');
    % Handle response
    switch answer
        case 'Yes'
            % no need to create the folder, it's already there
        case {'No','Cancel'}
            error('Program stopped. Change outputRecalcFolder name!');
    end
end

%% Create a log file
fid = fopen(fullfile(outputRecalcFolder,'recalc.log'),'wt');
if fid < 0
    error('File: %s could not be opened. End...\n',fullfile(outputRecalcFolder,'recalc.log'));
end
fprintf(fid,'============================ START =========================\n');
fprintf(fid,'New recalcs:           %s\n\n',datestr(now));
fprintf(fid,'siteID:                %s\n',siteID);
fprintf(fid,'year:                  %d\n',yearIn);
fprintf(fid,'Database source:       %s\n',originalDatabaseFolder);
fprintf(fid,'Main folder:           %s\n',outputRecalcFolder);
fprintf(fid,'Site_specific folder:  %s\n',originalSiteSpecificFolder);
fprintf(fid,'Pc_specific folder:    %s\n',originalPCSpecificFolder);
fprintf(fid,'Biomet.Net folder:     %s\n',originalBiometNetFolder);
fprintf(fid,'First Stage ini file:  %s\n',fileFirstStageIni);
fprintf(fid,'Second Stage ini file: %s\n',fileSecondStageIni);
fprintf(fid,'Third Stage ini file:  %s\n',fileThirdStageIni);
fprintf(fid,'\n');

fprintf(fid,'--------------------------------------------------------\n');
fprintf(fid,'Comments: \n');
fprintf(fid,'Minor syntax changes in FCRN_CO2Flux2NEP_MB_MovWin\n');
fprintf(fid,'Should be no differences between the before and after\n');
fprintf(fid,'----------------------------------------------------------\n');
fprintf(fid,'\n');

matlabVer = ver;
fprintf(fid,'Matlab release: %s\n',matlabVer(1).Release);
fprintf(fid,'Toolboxes:\n');
for cntLine=1:length(matlabVer)
    fprintf(fid,'    %s\n',matlabVer(cntLine).Name);
end

%% Backup current clean data originalDatabaseFolder to outputRecalcFolder
if folderCreatedNow == 1
    backupFolderName = sprintf('database_backup_%s',datestr(now,'yyyymmddhhMMss'));
    fprintf(fid,'\nNew test is running.\n');
    fprintf(fid,'Make a copy of the current status of the clean traces in %s\n',backupFolderName);
    ta_copy_clean_folders(yearIn,siteID,fullfile(outputRecalcFolder,backupFolderName));
    fprintf(fid,'   %s - Finished copying backup folder %s.\n',datestr(now),backupFolderName);
end
%% Copy originalBiometNetFolder into outputRecalcFolder
fprintf(fid,'\nCopying Biomet.Net folder from %s to %s\n',originalBiometNetFolder,fullfile(outputRecalcFolder,'Biomet.net/Matlab'));
try
    s = dir(originalBiometNetFolder);
    if length(s)<2
        error('Folder %s does not exist!\n',originalBiometNetFolder);
    else
        for cntLine = 1:length(s)
            if s(cntLine).isdir && ~strcmp(s(cntLine).name,'.') && ~strcmp(s(cntLine).name,'..')  
                srcFolder = fullfile(s(cntLine).folder,s(cntLine).name);
                % Backup the selected folder using robocopy
                outputPath = fullfile(outputRecalcFolder,'\Biomet.net\Matlab',s(cntLine).name);
                cmdStr = sprintf('robocopy %s %s /R:3 /W:10 /REG /MIR /NDL /NFL /NJH',srcFolder,outputPath); 
                [~,~] = system(cmdStr); 
            end
        end
    end        
catch
    error('Eror copying folder %s!\n',originalBiometNetFolder);
end
fprintf(fid,'   %s - Finished copying Biomet.Net\n',datestr(now));

%% Make Ubc_pc_folder inside of outputRecalcFolder
try
    newFolder = fullfile(outputRecalcFolder,'Ubc_pc_setup');
    fprintf(fid,'Creating .\Ubc_pc_setup folder\n');
    mkdir(newFolder)
catch
    error('   %s - Failed creating %s folder!\n',datestr(now),newFolder);
end
fprintf(fid,'   %s - Finished creating folder.\n',datestr(now));

%% Copy local C:\UBC_PC_setup\PC_Specific  to outputRecalcFolder
fprintf(fid,'Copying %s folder\n',originalPCSpecificFolder);
outputPath = fullfile(outputRecalcFolder,'Ubc_pc_setup','PC_specific');
cmdStr = sprintf('robocopy %s %s /R:3 /W:10 /REG /MIR /NDL /NFL /NJH',originalPCSpecificFolder,outputPath); 
[~,~] = system(cmdStr); 
fprintf(fid,'   %s - Finished copying.\n',datestr(now));

%% Copy  desired \UBC_PC_setup\Site_Specific  to outputRecalcFolder
fprintf(fid,'Copying %s folder\n',originalSiteSpecificFolder);
outputPath = fullfile(outputRecalcFolder,'Ubc_pc_setup','Site_specific');
cmdStr = sprintf('robocopy %s %s /R:3 /W:10 /REG /MIR /NDL /NFL /NJH',originalSiteSpecificFolder,outputPath); 
[~,~] = system(cmdStr); 
fprintf(fid,'   %s - Finished copying.\n',datestr(now));

%%
%----------------------------------------------------------------------------------
% Biomet paths
%----------------------------------------------------------------------------------
biometPath =   char(...
        'c:\ubc_PC_Setup\PC_specific',...
        fullfile(outputRecalcFolder,'ubc_PC_Setup\Site_specific'),...
        fullfile(outputRecalcFolder,'Biomet.net\matlab\UTILS'),...
        fullfile(outputRecalcFolder,'Biomet.net\matlab\SystemComparison'),...
        fullfile(outputRecalcFolder,'Biomet.net\matlab\New_eddy'),...
        fullfile(outputRecalcFolder,'Biomet.net\matlab\MET'),...
        fullfile(outputRecalcFolder,'Biomet.net\matlab\NEW_MET'),...
        fullfile(outputRecalcFolder,'Biomet.net\matlab\BIOMET'),...
        fullfile(outputRecalcFolder,'Biomet.net\matlab\BOREAS'),...
        fullfile(outputRecalcFolder,'Biomet.net\matlab\SoilChambers'),...
        fullfile(outputRecalcFolder,'Biomet.net\matlab\TRACEANALYSIS_FIRSTSTAGE'),...
        fullfile(outputRecalcFolder,'Biomet.net\matlab\TRACEANALYSIS_SECONDSTAGE'),...
        fullfile(outputRecalcFolder,'Biomet.net\matlab\TRACEANALYSIS_TOOLS'),...
        fullfile(outputRecalcFolder,'Biomet.net\matlab\TRACEANALYSIS_FCRN_THIRDSTAGE'),...
        fullfile(outputRecalcFolder,'Biomet.net\matlab\Micromet'));

fprintf(fid,'\nNew Biomet-specific Matlab path:\n');
for cntLine = 1:size(biometPath,1)
    fprintf(fid,'    %s\n',deblank(biometPath(cntLine,:)));
end

%----------------------------------------------------------------------------------
% Set the new Matlab path
%----------------------------------------------------------------------------------
path(pathdef);
for cntLine = size(biometPath,1):-1:1
    % add from the last line to the first to keep the path order same as in the
    % char() array biometPath
    addpath(deblank(biometPath(cntLine,:)),'-begin');
end

%% Copy CalculationProcedures folder
% This is a dangerous operation because the user could overwrite the 
% custom edited First/Second/ThirdStage.ini files that exist only in this folder.
% That is why I use /XO (copy only newer files)
% Even that could be dangerous if the user re-runs this program and gives
% it the same output path. But that would be bad in any case!

outputPath = fullfile(outputRecalcFolder,'database/Calculation_Procedures/TraceAnalysis_ini',siteID);
srcFolder = fullfile(originalDatabaseFolder,'Calculation_Procedures/TraceAnalysis_ini',siteID);
fprintf(fid,'Copying %s folder\n',srcFolder);
cmdStr = sprintf('robocopy %s %s /R:3 /W:10 /REG /XO /NDL /NFL /NJH',srcFolder,outputPath); 
[status,~] = system(cmdStr); 
fprintf(fid,'   %s - Finished copying.\n',datestr(now));

% Modify ini files if needed
% First Stage
iniFileName = sprintf('%s_FirstStage.ini',siteID);
if ~strcmp(fileFirstStageIni,iniFileName)
    % if other version of the FirstStage.ini file is requested,
    % overwrite the existing version with the requested file
    iniFileName = fullfile(outputPath,iniFileName);
    delete(iniFileName);
    newIniFileName = fullfile(outputPath,fileFirstStageIni);
    copyfile(newIniFileName,iniFileName);   
end
% Second Stage
iniFileName = sprintf('%s_SecondStage.ini',siteID);
if ~strcmp(fileSecondStageIni,iniFileName)
    % if other version of the FirstStage.ini file is requested,
    % overwrite the existing version with the requested file
    iniFileName = fullfile(outputPath,iniFileName);
    delete(iniFileName);
    newIniFileName = fullfile(outputPath,fileSecondStageIni);
    copyfile(newIniFileName,iniFileName);   
end


%% Everything is in place now to run fr_automated_cleaning
% The cleaning results will go to originalANNEX001Folder!
% The program will take them from there and copy them here for the 
% record keeping and future comparisons and troubleshooting

% Save the current (pwd) Matlab path. Return it after processing.
originalMatlabPWD = pwd;
% first change the current folder to outputRecalcFolder
fprintf(fid,'Change Matlab pwd folder to: %s \n',outputRecalcFolder);
cd(outputRecalcFolder)

% create biomet_database_default to point to outputRecalcFolder
% to make sure the fr_automated_cleaning uses correct database
fprintf(fid,'Create %s/biomet_database_default folder  \n',outputRecalcFolder);

fidDefaultPath = fopen('biomet_database_default.m','wt');
if fidDefaultPath < 0
    error('File: %s could not be created. End...\n',biomet_database_default);
end
fprintf(fidDefaultPath,'function pth = biomet_database_default\n');
fprintf(fidDefaultPath,'pth = ''%s'';\n',originalDatabaseFolder);
fclose(fidDefaultPath);

%% Run fr_automated_cleaning (the results go into originalDatabaseFolder!)
fprintf(fid,'%s - Running fr_automated_cleaning\n',datestr(now));
iniFilePath = fullfile(outputRecalcFolder,'database');
fr_automated_cleaning(yearIn,{siteID},1:3,[],iniFilePath)
fprintf(fid,'       %s - Finnished running fr_automated_cleaning\n',datestr(now));
fprintf(fid,'================================== END =================================');

%% Copy results from originalDatabaseFolder to outputRecalcFolder
ta_copy_clean_folders(yearIn,siteID,fullfile(outputRecalcFolder,'database'));

%% Now run reset everything and run fr_automated_cleaning with the 
%  the current settings (PAOA001+ANNEX000) to put the correct clean files
%  back into our database. I could run this
%  by running a new instance of Matlab or try to reset all the paths and
% do it that way. If I forget to do this, some files in the database on 
% the ANNEX001 could stay messed up for a long time before somebody notices

answer = questdlg({'ANNEX001 database is now possibly wrong.','(Overwriten with using different Biomet.Net and/or TraceAnalysis_ini files)'}, ...
                'Re-do ANNEX001 cleaning', ...
                'Yes - run cleaning','No - database stays corrupted','Cancel','No - database stays corrupted');
% Handle response
switch answer
    case 'Yes - run cleaning'
        % setup Matlab to current Biomet.Net and \\annex001
        % and run fr_automated_cleaning
        fprintf('This option has not been implemented yet.\n')
    case {'No - database stays corrupted','Cancel'}
        fprintf('Program stopped without restoring ANNEX001 database\nusing default Biomet.Net and ANNEX001 parameters!\n');
end

cd(originalMatlabPWD)

fclose(fid);

fr_compare_database_traces(siteID,yearIn,fullfile(outputRecalcFolder,backupFolderName),...
                                         fullfile(outputRecalcFolder,'database'),...
                                         'clean/thirdstage')

% fr_compare_database_traces(siteID,yearIn,...
%     'D:\junk\recalc_tests\Test10_changed_1stStgIni\database_backup_20220805214036',...
%      fullfile(outputRecalcFolder,'database'),...
%      'clean/secondstage')    

 return



