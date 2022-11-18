function run_BB_db_update(yearIn,sites)
%
%
%
% Zoran Nesic           File created:               2019
%                       Last modification:  Aug 29, 2022

%
% Revisions:
%
% Aug 29, 2022 (Zoran)
%   - added try-catch-end call to db_update_Micromet_EddyPro_Recalcs
%

dv=datevec(now);
arg_default('yearIn',dv(1));                                  % default - current year
arg_default('sites',{'BB','BB2','DSM','RBM','Young','Hogg'}); % default - all sites

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
            case {'Hogg','Young'}
                Manitoba_dailyvalues(cntStr,[]);
            otherwise
        end    
    catch
        fprintf('Manitoba_dailyvalues() calculation failed for siteID: %s\n',siteID);
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

% Process the flags files. This may take some time so it
% should be kept at the back of this function so it runs after the
% web updates are done

% cycle through the sites
for cntStr = sites
    siteID = char(cntStr);
    try
        % Run database update without Web data processing
        dataOut = fr_flags_database(cnt, 2022, 'v:/Sites','d:\database_local');
        db_update_BB_site(yearIn,cntStr,1);
    catch
        fprintf('An error happen while running db_update_BB_site in run_BB_db_update.m\n');
    end    


