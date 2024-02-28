function run_BB_db_update(yearIn,sites)
%
%
%
% Zoran Nesic           File created:               2019
%                       Last modification:  Feb 26, 2024

%
% Revisions:
%
% Feb 26, 2024 (Zoran)
%   - Fixed a bug when the program run EddyPro database on BBS only twice
%     per day. The idea was to avoid running BBS fr_automated_cleaning all the 
%     time. Moved the if statement to bracket only fr_automated_cleaning.
% Feb 21, 2024 (Zoran)
%   - limited BBS processing to twice per day at 1 and 13 hours
%   - same for Flags processing except the hours are 2 and 14
%   - the two changes shaved off almost 2 minutes from the totals (360s vs
%     240s). The next improvement would be speeding up (or not doing)
%     the Web updates (they take ~80s)
%   - added some extra headers and footers, cleaned up the existing ones.
% Feb 8, 2024 (Zoran)
%   - Added plot_Manitoba_voltages
% Jul 27, 2023 (Zoran, June)
%   - added OHM and BBS
% Nov 18, 2022 (Zoran)
%   - added processing of the Flags files (P:/Sites/siteID/MET/siteID_flags_yyyy.xlsx)
%     For more on these files check out: db_update_flags_files function
%   - added fr_automated_cleaning() (first two stages) to the 30-minute updates
%     We'll now have clean data available for BB_webupdate if needed.
% Aug 29, 2022 (Zoran)
%   - added try-catch-end call to db_update_Micromet_EddyPro_Recalcs
%

startTime = datetime;
arg_default('yearIn',year(startTime));                                  % default - current year
arg_default('sites',{'BB','BB2','DSM','RBM','Young','Hogg','OHM','BBS'}); % default - all sites

fprintf('============================\n');
fprintf('**** run_BB_db_update ******\n');
fprintf('============================\n');
%Cycle through all the sites and do site specific chores
% (netCam picture taking, Manitoba daily values calculations,...)
for cntStr = sites
    siteID = char(cntStr);
    % run BBS site only twice per day (1pm, 1am)
    % if the site is not BBS run the full processing
    % also run if the site is BBS but the hour is either 1 or 13 and
    % the minutes are less than 30
    try
        % Run database update without Web data processing
        db_update_BB_site(yearIn,cntStr,1);
    catch
        fprintf('An error happen while running db_update_BB_site in run_BB_db_update.m\n');
    end    
    try
        % Run database update for EddyPro recalced without Web data processing
        db_update_Micromet_EddyPro_Recalcs(yearIn,cntStr);
    catch
        fprintf('An error happen while running db_update_Micromet_EddyPro_Recalcs in run_BB_db_update.m\n');
    end
    switch siteID
        case 'DSM'
            %Photo_Download(sites,[]);
            netCam_Link = 'http://173.181.139.5:4925/netcam.jpg';
            Call_WebCam_Picture(siteID,netCam_Link)
        case 'RBM'
            %Photo_Download(sites,[]);
            netCam_Link = 'http://173.181.139.4:4925/netcam.jpg';
            Call_WebCam_Picture(siteID,netCam_Link)
        otherwise
    end

    %Run quick daily total calculation for Pascal (DUC)
    try
        switch siteID
            case {'Hogg','Young','OHM'}
                Manitoba_dailyvalues(cntStr,[]);
            otherwise
        end    
    catch
        fprintf('Manitoba_dailyvalues() calculation failed for siteID: %s\n',siteID);
    end
   if ~strcmpi(siteID,'BBS') || (ismember(hour(startTime),[1 13]) && minute(startTime)<30)
        % Run automated cleaning stages 1 and 2 so we have clean data
        % available for plotting and exporting (if needed)
        try
            fr_automated_cleaning(yearIn,siteID,[1 2]);
        catch
            fprintf('An error happen while running fr_automated_cleaning in run_BB_db_update.m\n');
        end  
    end
end

%================
% do web updates 
%================
% create CSV files for the web server
fprintf('\nWeb updates for all sites and all years...\n');
tic;
sitesWeb = {'BB','BB2','DSM','RBM'};
for j=1:length(sitesWeb)
    % make sure that a bug in one site processing does not crash all
    % updates. Do it one site at the time
    try
        BB_webupdate(sitesWeb(j),'P:\Micromet_web\www\webdata\resources\csv\');
    catch
    end
end
fprintf(' Finished in: %5.1f seconds.\n',toc);


% Upload CSV files to the web server
system('start /MIN C:\Ubc_flux\BiometFTPsite\BB_Web_Update.bat');

% Plot Manitoba voltages
try
    plot_Manitoba_voltages
catch
end



%----------------------------------------------------------
% Process the flags files. This may take some time so it
% should be kept at the back of this function so it runs after the
% web updates are done. 
% Limited running this part to twice per day.

% if the time is right, run the Flags processing
if (ismember(hour(datetime),[2 14]) && minute(datetime)<30)
    fprintf('\nUpdating Flags database for all sites and for the current year only...');
    tic;
    % cycle through the sites
    for cntStr = sites
        siteID = char(cntStr);
        fprintf('%s  ',siteID);
        try
            % Run database update without Web data processing
            db_update_flags_files(yearIn,siteID, 'p:/Sites','p:/database');
        catch
            fprintf('An error happen while running db_update_flags_files in run_BB_db_update.m\n');
        end    
    end
    fprintf(' Finished flag processing in: %5.1f seconds.\n',toc);
end


% Added by June Skeeter
% Some functions to be run once processing is complete
% 1) Dump some traces to derived variable for gap-filling
% 2) Run some python scripts
%   a. pull new manual data from G:drive
%   b. write biomet data for EddyPro and Kljun (2015) FFP input data to highfreq

arg_default('test',0)
if ~iscell(sites)
    sites = {sites};
end
if hour(datetime)==0 && minute(datetime)< 30 || test == 1
    for site = sites
        siteID = char(site);
        try
            % A "default" set of met variables for gap filling (plus will calculate
            % moving averages of the time series on daily, monthly, and seasonal timescales
            DerivedVariablesForGapFilling(siteID);
            if strcmpi(siteID,'BBS')
                % Interpolate canopy height from discrete observations
                DerivedVariablesForGapFilling(siteID,{'canopy_height_sample_mean'},1,1,0);
            end

            fprintf('\n\n  ****** Ouptpt derrived variables for %s ***\n\n',siteID);
        catch
            fprintf('\n\n  ****** Error writing to derrived variables for %s ***\n\n',siteID);
        end
    end
end
if hour(datetime)==0 && minute(datetime)> 30 || test == 2
    try
        bioMetRoot = split(matlab.desktop.editor.getActiveFilename,'matlab');
        bioMetRoot = string(bioMetRoot(1));
        bioMetMatRoot = fullfile(string(bioMetRoot(1)),'/matlab/');
        bioMetPyRoot = fullfile(bioMetRoot,'/Python/');
        pyenvPath = fullfile(bioMetPyRoot,'.venv/Scripts/');
        pyScript = fullfile(bioMetPyRoot,'DatabaseFunctions.py');
        activate = '.\activate.bat';
        if exist(pyenvPath,'dir') & isfile (pyScript)

            py_call = sprintf("%s --Task GSheetDump --Sites %s",pyScript,strjoin(sites));
            CLI_args = sprintf("cd %s & %s & python %s & deactivate & cd %s",pyenvPath,activate,py_call,bioMetMatRoot);
            [status,cmdout] = system(CLI_args);
            if status == 0
                disp(fprintf('Read G Drive Files \n %s',cmdout))
            else
                disp(fprintf('GSheetDump Failed \n %s',cmdout))
            end

            py_call = sprintf("%s --Task CSVDump --Sites %s --Years %s",pyScript,strjoin(sites),int2str(yearIn));
            CLI_args = sprintf("cd %s & %s & python %s & deactivate & cd %s",pyenvPath,activate,py_call,bioMetMatRoot);
            [status,cmdout] = system(CLI_args);
            if status == 0
                disp(fprintf('Writing Biomet Files \n %s',cmdout))
            else
                disp(fprintf('Writing Biomet Failed \n %s',cmdout))
            end
        end
    catch
        fprintf('\n\n  ****** Error around Python code ***\n\n');
    end


fprintf('\n\n**** run_BB_db_update finished in %6.1f sec.******\n',seconds(datetime-startTime));
fprintf('=====================================================\n\n\n');

end
