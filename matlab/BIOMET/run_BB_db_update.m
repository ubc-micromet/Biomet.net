function run_BB_db_update(yearIn,sites)
%
%
%
% Zoran Nesic           File created:               2019
%                       Last modification:  Nov 18, 2022

%
% Revisions:
%
% Nov 18, 2022 (Zoran)
%   - added processing of the Flags files (P:/Sites/siteID/MET/siteID_flags_yyyy.xlsx)
%     For more on these files check out: db_update_flags_files function
%   - added fr_automated_cleaning() (first two stages) to the 30-minute updates
%     We'll now have clean data available for BB_webupdate if needed.
% Aug 29, 2022 (Zoran)
%   - added try-catch-end call to db_update_Micromet_EddyPro_Recalcs
%

dv=datevec(now);
arg_default('yearIn',dv(1));                                  % default - current year
arg_default('sites',{'BB','BB2','DSM','RBM','Young','Hogg','OHM'}); % default - all sites

%Cycle through all the sites and do site specific chores
% (netCam picture taking, Manitoba daily values calculations,...)


for cntStr = sites
    siteID = char(cntStr);
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
    
    % Run automated cleaning stages 1 and 2 so we have clean data
    % available for plotting and exporting (if needed)
    try
        fr_automated_cleaning(yearIn,siteID,[1 2]);
    catch
        fprintf('An error happen while running fr_automated_cleaning in run_BB_db_update.m\n');
    end    
end

%================
% do web updates 
%================
% create CSV files for the web server
fprintf('\nWeb updates for all sites and all years...');
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



%----------------------------------------------------------
% Process the flags files. This may take some time so it
% should be kept at the back of this function so it runs after the
% web updates are done

fprintf('\nUpdating Flags database for all sites and for the current year only...');
tic;
% cycle through the sites
for cntStr = sites
    siteID = char(cntStr);
    try
        % Run database update without Web data processing
        db_update_flags_files(yearIn,siteID, 'p:/Sites','p:/database');
    catch
        fprintf('An error happen while running db_update_flags_files in run_BB_db_update.m\n');
    end    
end
fprintf(' Finished in: %5.1f seconds.\n',toc);


