function createFirstStageIni(structSetup)
% Create the first stage ini defaults for the given site database (traces have to already exist in the database)
%
% For the given site, the function searches through the folder named in structSetup.allMeasurementTypes
% and creates skeleton [Trace]...[End] for each database file. User then has to populate many
% of the values.
%
% The output ini file will be stored as outputPath/Site_ID_FirstStage_Template.ini. If the outputPath is []
% the file is saved in the current folder.
%
%
% Example of the input structure:
% structSetup.startYear = 2021;
% structSetup.startMonth = 1;
% structSetup.startDay = 1;
% structSetup.endYear = 2999;
% structSetup.endMonth = 12;
% structSetup.endDay = 31;
% structSetup.Site_name = 'Delta Site Marsh';
% structSetup.SiteID = 'DSM';
% structSetup.allMeasurementTypes = {'MET','Flux'};
% structSetup.Difference_GMT_to_local_time = 8;  % local+Difference_GMT_to_local_time -> GMT time
% structSetup.outputPath = []; % keep it in the local directory
%
% Zoran Nesic               File created:           Mar 20, 2024
%                           Last modification:      Mar 26, 2024

% Revisions:
%


outputIniFileName = fullfile(structSetup.outputPath, [structSetup.SiteID '_FirstStage_Template.ini']);
fid = fopen(outputIniFileName,'w');

% Header output
fprintf(fid,'%%\n%% File generated automatically on %s\n%%\n\n',datetime('today'));
fprintf(fid,'Site_name = ''%s''\n',structSetup.Site_name);
fprintf(fid,'SiteID = ''%s''\n\n',structSetup.SiteID);
fprintf(fid,'Difference_GMT_to_local_time = %d   %% hours\n\n',structSetup.Difference_GMT_to_local_time);


for cntMeasurementTypes = 1:length(structSetup.allMeasurementTypes)
    measurementType = char(structSetup.allMeasurementTypes(cntMeasurementTypes));

    inputFolder = biomet_path(structSetup.startYear,structSetup.SiteID,measurementType);
    allFiles = dir(inputFolder);
    
    for cntFiles = 1:length(allFiles)
        if ~allFiles(cntFiles).isdir
            try
                variableName = allFiles(cntFiles).name;
                fprintf(fid,'[Trace]\n');
                fprintf(fid,'    variableName         = ''%s''\n',variableName);
                fprintf(fid,'    title                = ''Title goes here''\n');
                fprintf(fid,'    originalVariable     = ''''\n');
                fprintf(fid,'    inputFileName        = {''%s''}\n',variableName);
                fprintf(fid,'    inputFileName_dates  = [ datenum(%d,%d,%d) datenum(%d,%d,%d)]\n',...
                                                        structSetup.startYear,structSetup.startMonth,structSetup.startDay,...
                                                        structSetup.endYear,structSetup.endMonth,structSetup.endDay);
                        
                fprintf(fid,'    measurementType      = ''%s''\n',measurementType);
                fprintf(fid,'    tags                 = ['''']\n');
                fprintf(fid,'    units                = ''''\n');
                fprintf(fid,'    instrument           = ''''\n');
                fprintf(fid,'    instrumentSN         = ''''\n');
                fprintf(fid,'    calibrationDates     = ''''\n');
                fprintf(fid,'       loggedCalibration = [ 1 0 datenum(%d,%d,%d) datenum(%d,%d,%d)]\n',...
                                                        structSetup.startYear,structSetup.startMonth,structSetup.startDay,...
                                                        structSetup.endYear,structSetup.endMonth,structSetup.endDay);
                fprintf(fid,'       currentCalibration= [ 1 0 datenum(%d,%d,%d) datenum(%d,%d,%d)]\n',...
                                                        structSetup.startYear,structSetup.startMonth,structSetup.startDay,...
                                                        structSetup.endYear,structSetup.endMonth,structSetup.endDay);
                fprintf(fid,'    comments             = ''''\n');
                fprintf(fid,'    minMax               = [-Inf,Inf]\n');
                fprintf(fid,'    zeroPt               = -9999\n');
                fprintf(fid,'    dependent            = ''''\n');
        
                fprintf(fid,'[End]\n\n');
            catch ME
            end
        end
    end
end
fclose all;
end

