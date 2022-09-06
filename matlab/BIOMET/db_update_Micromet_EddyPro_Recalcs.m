function db_update_Micromet_EddyPro_Recalcs(yearIn,sites)
% Convert EddyPro recalc files to database (read_bor()) files
%
%
% Zoran Nesic       File created:       Aug  24, 2022
%                   Last modification:  Aug  29, 2022 (Zoran)
% 


% Revisions:
%
% Aug 29, 2022 (Zoran)
%   - A small change in an fprintf() line.

dv=datevec(now);
arg_default('yearIn',dv(1));
arg_default('sites','BB');


missingPointValue = NaN;            % For Micromet sites we'll use NaN to indicate missing values (new feature since Oct 20, 2019)

pth_db = db_pth_root; %#ok<NASGU>

for k=1:length(yearIn)
    for j=1:length(sites)
        siteID = char(sites(j));
        fprintf('\n**** Processing Year: %d, Site: %s   *************\n',yearIn(k),siteID);

        % Progress list for EddyPro files: progressListHH_EddyPro_Pth =
        % \\vinimet.geog.ubc.ca\projects\database\DSM_EddyPro_ProgressList
        cmdTMP = (['progressList' siteID '_EddyPro_Pth = fullfile(pth_db,''' siteID...
            '_EddyPro_progressList_' num2str(yearIn(k)) '.mat'');']);
        eval(cmdTMP);

        % Path to Flux Database: HHFluxDataBase_Pth
        cmdTMP = ([siteID 'FluxDatabase_Pth = [pth_db ''yyyy\' siteID...
            '\Flux\''];']);
        eval(cmdTMP);
                     
        % Then process the new files
        outputPathStr = [siteID 'FluxDatabase_Pth'];
        eval(['outputPath = ' outputPathStr ';']);     
        inputPath = sprintf('//vinimet.geog.ubc.ca/projects/sites/%s/Flux/eddypro_%s_%d*_full_output*_adv.csv',siteID,siteID,yearIn(k));
        if filesep ~= '/'
             inputPath = regexprep(inputPath,'/',filesep);
        end
        cmdTMP = sprintf('progressList = progressList%s_EddyPro_Pth;', siteID);  
        eval(cmdTMP);
        [numOfFilesProcessed,numOfDataPointsProcessed]= fr_SmartFlux_database(inputPath,progressList,outputPath,[],[],missingPointValue);           
        fprintf('%s  HH_EddyPro:  Number of files processed = %d, Number of HHours = %d\n',siteID,numOfFilesProcessed,numOfDataPointsProcessed);

    end %j  site counter
    
end %k   year counter

