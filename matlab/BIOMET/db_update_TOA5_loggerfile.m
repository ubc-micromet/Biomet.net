function db_update_TOA5_loggerfile(year,siteId);

% * renames TOA5 logger files, copies raw files to annex001, moves (and renames with yyyymmdd tag)
% files from CSI_NET\old on PAOA001 to CSI_NET\old\yyyy, then
% * updates the annex001 database as follows:
%   - climate data goes to \\annex001\database\yyyy\siteId\Climate  and raw files to  \\annex001\database\yyyy\siteId\Climate\Raw
%   - 30min flux data goes to \\annex001\database\yyyy\siteId\Flux_Logger and raw files to  \\annex001\database\yyyy\siteId\Flux_Logger\Raw
% * computes fluxes (WPL corrected if necessary) from raw covariances and saves to \Flux_Logger\computed_fluxes

% user can input year, siteId

% file created: January 6, 2011        last modified: January 11, 2011

% (c) Nick Grant

% function based on db_update_mpb_sites and db_update_hp_sites

% revisions:

dv=datevec(now);
arg_default('year',dv(1));

fileExt = datestr(now,30);
fileExt = fileExt(1:8);

% ******************** SITE 30MIN TABLE NAMES ***************************
% TO ADD A NEW SITE: update switch statement and you're good to go!
switch siteId
    case {'MPB1','MPB2','MPB3','MPB4'}
        filprefx = {'_Clim_30m'  '_EC_comp_cov' '_EC_Tc_cov'  '_EC_Tscov'  '_EC_flux_30m'  };
    case {'HP09'}
        filprefx = {'_clim_Radiation' '_eddy_comp_cov' '_eddy_Tc_cov' '_eddy_Tscov' '_eddy_Flux' '_eddy_flux_30m'  };
    case {'HP11'}
        filprefx = {'_Clim' '_eddy_comp_cov' '_eddy_Tc_cov' '_eddy_Tscov' '_eddy_Flux' '_eddy_flux_30m'  };
end
% **********************************************************************

% location where LoggerNet deposits the data
filePath = sprintf('d:\\sites\\%s\\CSI_net\\old\\',siteId);

% move .DAT files from /old  to  old/yyyy  ; remove .DAT extension
% and add date .yyyymmdd

for m=1:length(filprefx)
    % refresh db path
    pth_db = db_pth_root;

    % progress list filename parsed from siteId and filprefx
    eval(['progressList' char(filprefx{m}) '_Pth = fullfile(pth_db,' '''' siteId...
        char(filprefx{m}) '_progressList_' num2str(year) '.mat'');']);

    if ~isempty(strfind(upper(char(filprefx{m})),'CLIM'))
        eval([ 'pth_db = [pth_db ''yyyy\' siteId...
            '\Climate\''];']);
    else
        eval([ 'pth_db = [pth_db ''yyyy\' siteId...
            '\Flux_Logger\''];']);
    end
    datFiles = dir(fullfile(filePath,[ siteId char(filprefx{m}) '*.dat' ]));
    for i=1:length(datFiles)
        sourceFile      = fullfile(filePath,datFiles(i).name);
        destinationFile_SitesPC = fullfile(fullfile(filePath,num2str(year)),[datFiles(i).name(1:end-3) fileExt]);
        % clim or EC file?
        if ~isempty(strfind(upper(char(filprefx{m})),'CLIM'))
            destinationFile_RawDB   = fullfile(biomet_path(year,siteId),'Climate','Raw',[datFiles(i).name(1:end-3) fileExt]);
        else
            destinationFile_RawDB   = fullfile(biomet_path(year,siteId),'Flux_Logger','Raw',[datFiles(i).name(1:end-3) fileExt]);
        end
        % first copy file to Annex001 db Raw folder
        [Status1,Message1,MessageID1] = copyfile(sourceFile,destinationFile_RawDB);
        if Status1 ~= 1
            uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',Message1,sourceFile,destinationFile_RawDB),'Copying files to Annex001 failed','modal'))
        end %if
        % now move into old/yyyy folder on Sites PC
        [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile_SitesPC);
        if Status1 ~= 1
            uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',Message1,sourceFile,destinationFile1),'Moving files to PAOA001 failed','modal'))
        end %if
    end %i

    % all copying and moving done, now run the db update: pth_db depends on whether a Clim file or an EC file
    eval(['[numOfFilesProcessed,numOfDataPointsProcessed] = fr_site_met_database(''D:\sites\' siteId '\CSI_net\old\' num2str(year) '\' siteId char(filprefx{m}) '*.' num2str(year) '*'',[],[],[],progressList' char(filprefx{m}) '_Pth,pth_db,2);'])
    eval(['disp(sprintf(''' siteId char(filprefx{m}) ':  Number of files processed = %d, Number of HHours = %d'',numOfFilesProcessed,numOfDataPointsProcessed))']);

end %m

convert_raw_logger_covariances_to_fluxes(year,siteId);