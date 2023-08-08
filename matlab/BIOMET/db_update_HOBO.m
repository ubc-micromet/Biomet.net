function db_update_HOBO(yearIn,sites)
% Convert EddyPro recalc files to database (read_bor()) files
%
%
% Zoran Nesic       File created:       Aug  7, 2023
%                   Last modification:  Aug  7, 2023 
% 


% Revisions:
%

dv=datevec(now);
arg_default('yearIn',dv(1));
arg_default('sites','USRRC');

if exist('biomet_sites_default.m','file')
    sites_pth = biomet_sites_default;
else
    sites_pth = 'p:\Sites';
end

missingPointValue = NaN;            % For Micromet sites we'll use NaN to indicate missing values (new feature since Oct 20, 2019)

pth_db = db_pth_root; 

for cntYears=1:length(yearIn)
    for cntSites=1:length(sites)
        siteID = char(sites(cntSites));
        fprintf('\n**** Processing Year: %d, Site: %s   *************\n',yearIn(cntYears),siteID);

        % Progress list for HOBO files
        progressListPath = fullfile(pth_db,sprintf('%s_HOBO_WT_progressList_%d.mat',siteID,yearIn(cntYears)));

        % Path to HOBO Water Table Database
        outputPath = fullfile(pth_db,'yyyy',siteID,'HOBO_Water_Table');                     
        % Path to the source files
        inputPath = fullfile(sites_pth,...
                           sprintf('%s/HOBO_Water_Table/%s_HOBO_*.csv',siteID,siteID));
        % Process the new files
        [numOfFilesProcessed,numOfDataPointsProcessed]= fr_HOBO_database(inputPath,progressListPath,outputPath,[],[],missingPointValue);           
        fprintf('%s  HOBO water table:  Number of files processed = %d, Number of HHours = %d\n',siteID,numOfFilesProcessed,numOfDataPointsProcessed);
        
    end %j  site counter
    
end %k   year counter

