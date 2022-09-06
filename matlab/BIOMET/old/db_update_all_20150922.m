function db_update_all(runCleaning,local_export)
% db_update_all
%
% runCleaning  - if 1 or missing then run database cleaning
%              - if 0 then skip cleaning and just do the exports
%
% local_export - if 1 then export csv files to our local copy of the FCRN
%                export db
%              - if 0 then skip
% Run all database update and file export tasks
% This function is automatically run by the scheduler every morning

% Revisions:
% Aug 21, 2014
%   remove MPB3 from daily update
% May 15, 2014
%   -recativated monthly .csv export for CCRN: \\annex001\FTP_FLUXNET
%   (Nick)
%  Aug 6, 2013
%       warning set to off in wrapper function: logfiles getting overly big with warnings
%  Jan 8, 2013 (Nick)
%       -export csv/DIS files to Fluxnet02 right up to current date. Removed old FTP-DIS export
%       location on PAOA003
%  Sept 6, 2012
%       -added export of web plots for HP sites outside normal daily cleaning loop
%  Jul 6, 2012
%       -export to DIS folders for BS, PA and YF.
%  Jan 30, 2012
%       -change dos logon syntax for PAOA001 (WinXP, used to be Win98).
%       -all CR data exports (Dave S, Al) deactivated.
%  July 20, 2011
%       - PM fire index removed. Project ended 3/31/11. CR chamber cleaning
%       removed: chamber dismantled Nov, 2011. Remove decommissioned EC sites:
%       HJP02, CR (tall tower)
%   Oct 8, 2010
%       -added MPB3 to automated update site list. Mat finished implementing cleaning 
%        ini files for MPB3 on Sept 7/2010.
%   Jul 21, 2010
%       -commented out CS319 export of 2009 UBC climate data for Roland
%       Stull. Program was crashing.
%   Nov 13, 2009
%       -added export of fire index from Port McNeill variable retention
%       site
%   Oct 2, 2007
%       -Nick added a monthly search and report for missing hhour (.mat) files
%   July 10, 2007
%       -changed site by site cleaning to run stage 6 to export web graphs
%       (Nick)
%   June 28, 2007:
%       -modified to explicitly clean by site, since using
%        fr_automated_cleaning with no arguments can still crash if there is a
%        problem with one site; also added local_export flag so that an up-to-date FCRN
%        export database can be maintained for internal use (Nick)
%   Feb 19, 2007
%       - Added update of hhour database from long .mat files (Praveena and David)
%   July 6, 2006
%       - Added runCleaning flag (Zoran)

if nargin == 0
    runCleaning = 1;
    local_export  = 0;
end

yy = datevec(now); 
dayOfWeek = datestr(now,8);

% Remove yesterdays log files
delete(fullfile(db_pth_root,'db_Update.log'));

%---------------------------------------------------
% Biomet database update and automatic cleaning
%---------------------------------------------------
%dos('net use \\paoa001\sites arctic /user:biomet');
%dos('net use \\paoa003\ftp_biomet arctic');

% Updates hhour database from long .mat files
db_hhour_copy;

if runCleaning == 1
    % Daily cleaning
    eval_wrapper('Updating Eddy DB with daily download','db_update_UBC_daily');
    eval_wrapper('Updating Eddy DB with long hhour files','db_update_hhour_database([yy(1)]);');
    eval_wrapper('Updating BERMS DB for current year','db_update_BERMS_daily([],[yy(1)])');
    
    % Generation of graphs does not work!
    % June 28,2007: Nick modified to explicitly clean by site, since using
    % fr_automated_cleaning with no arguments can still crash if there is a
    % problem with one site; this way the loop will continue with the next
    % site
    if local_export % do daily export to our local copy of the FCRN db (for internal use only)
                    % now on Fluxnet02, drive G.
        %sites = {'BS' 'CR' 'HJP02'  'PA' 'YF' 'OY' }; 
        sites = {'BS'  'PA' 'YF' }; % update site list: July 20, 2011
        for i=1:length(sites)
            eval_wrapper(['Automatic cleaning and .csv export for ' sites{i} ],'fr_automated_cleaning(yy(1)-1:yy(1),sites{i},5)');
        end
    else
        %sites = {'BS' 'CR' 'FEN' 'HJP02' 'HJP75' 'JP'  'OY' 'PA' 'YF' 'UBC_TOTEM'...
        %         'MPB1' 'MPB2' 'MPB3'};
        
        sites = {'BS' 'PA' 'YF' 'UBC_TOTEM' 'MPB1' 'HP09' 'HP11'}; % removed decommissioned site MPB3: Aug 21, 2014 
                                        % remove MPB2, HDF11 Jan 19, 2015
        for i=1:length(sites) % run cleaning with export of web graphs
            if ~strcmp(char(sites{i}),'UBC_TOTEM')
               
               eval_wrapper(['Automatic cleaning of current year for ' sites{i} ],'fr_automated_cleaning([yy(1)],sites{i},6)');
            else
               eval_wrapper(['Automatic cleaning of current year for ' sites{i} ],'fr_automated_cleaning(yy(1),sites{i},[1 2 3])');
            end
        end
    end
    %eval_wrapper('CR chamber cleaning','fr_automated_cleaning_cr_ch(yy(1))');
    
    % Tasks that are only done on the first saturday of every month
    if strcmp(dayOfWeek,'Sat') & yy(3) <= 7
        eval_wrapper('Update BERMS DB for all years','db_update_BERMS_daily');
        % (Jan 8, 2013) removed DIS file export, now maintain .csv files right up to present
        % May 15, 2014: reactivated monthly export to
        % \\annex001\FTP_FLUXNET (Nick)
        eval_wrapper('CCRN data export','fr_automated_cleaning(yy(1)-1:yy(1),{''bs'',''pa''},4)'); % removed hjp02: July 20, 2011
        %eval_wrapper('Search for and report missing hhour
        %files','run_hhour_file_search([],[],1)'); % Nick added 10/02/2007,
        %and removed July 20, 2011.
    end % of runCleaning
end
%---------------------------------------------------
% Data export for other people
%---------------------------------------------------

% Dave Spittlehouses CR throughfall data
%dos('net use \\paoa003\ftp_biomet arctic');
%eval_wrapper('Exporting data for Dave S.','fr_export_dave_to_ftp');

dos('net use \\paoa001\web_page_wea arctic /user:biomet');
% Weather data for fire indexes
%eval_wrapper('Exporting fire index data MH','MH_FireWeatherIndex_Report(floor(now)+datenum(0,0,0,21,0,0)-[60:-1:0])');
%eval_wrapper('Exporting fire index data PM','PM_FireWeatherIndex_Report(floor(now)+datenum(0,0,0,21,0,0)-[60:-1:0])');
%eval_wrapper('Exporting fire index data OY','dataforal');
%eval_wrapper('Exporting fire index data CR','dataforal_cr');

% UBC Climate station data and graphic export
eval_wrapper('Exporting UBC climate station graphs','web_plots30');
eval_wrapper('Exporting UBC climate station data temperature','outfile30');
eval_wrapper('Exporting UBC climate station data solar','outfile30_solar');
eval_wrapper('Exporting UBC climate station data rain','ubc_rain05_now');
eval_wrapper('Exporting HP web plots','fr_automated_cleaning(yy(1),{''HP09'' ''HP11''},6);');

% NASA SMAP export (new May 14, 2014)

eval_wrapper('Exporting NASA SMAP L3 and L4 data products','run_SMAP_export(yy(1));');

% commented out July 21, 2010 (Nick)
% try
%     eval_wrapper('Exporting UBC climate station data rain','cs319');
% end

if runCleaning == 1
    check_daily_updates;   % do this only if cleaning, skip when just exporting data
end

return

function eval_wrapper(task_name,command_name)

fileName_diary = fullfile(db_pth_root,'db_Update.log');

try
    diary(fileName_diary);
    disp([datestr(now) ' - ' task_name]);
    diary off;
    command_name = ['warning(''off'',''all'');warning(''off'',''backtrace'');' command_name];
    evalin('caller',[command_name ';']);
catch
    diary(fileName_diary);
    disp(['Error in ' task_name]);
    disp(lasterr);
    diary off;
end
