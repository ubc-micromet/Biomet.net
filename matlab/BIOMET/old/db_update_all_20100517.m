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
dos('net use \\paoa001\sites arctic');
dos('net use \\paoa003\ftp_biomet arctic');

% Updates hhour database from long .mat files
db_hhour_copy;

if runCleaning == 1
    % Daily cleaning
    eval_wrapper('Updating Eddy DB with daily download','db_update_UBC_daily');
    eval_wrapper('Updating Eddy DB with long hhour files','db_update_hhour_database([yy(1)-1 yy(1)]);');
    eval_wrapper('Updating BERMS DB for current year','db_update_BERMS_daily([],yy(1))');
    
    % Generation of graphs does not work!
    % June 28,2007: Nick modified to explicitly clean by site, since using
    % fr_automated_cleaning with no arguments can still crash if there is a
    % problem with one site; this way the loop will continue with the next
    % site
    if local_export % do daily export to our local copy of the FCRN db (for internal use only!)
        sites = {'BS' 'CR' 'HJP02'  'PA' 'YF' 'OY' }; 
        for i=1:length(sites)
            eval_wrapper(['Automatic cleaning of current year for ' sites{i} ],'fr_automated_cleaning(yy(1),sites{i},5)');
        end
    else
        sites = {'BS' 'CR' 'FEN' 'HJP02' 'HJP75' 'JP'  'OY' 'PA' 'YF' 'UBC_TOTEM'};
        for i=1:length(sites) % run cleaning with export of web graphs
            if ~strcmp(char(sites{i}),'UBC_TOTEM')
               eval_wrapper(['Automatic cleaning of current year for ' sites{i} ],'fr_automated_cleaning(yy(1),sites{i},6)');
            else
               eval_wrapper(['Automatic cleaning of current year for ' sites{i} ],'fr_automated_cleaning(yy(1),sites{i},[1 2 3])');
            end
        end
    end
    eval_wrapper('CR chamber cleaning','fr_automated_cleaning_cr_ch(yy(1))');
    
    % Tasks that are only done on the first saturday of every month
    if strcmp(dayOfWeek,'Sat') & yy(3) <= 7
        eval_wrapper('Update BERMS DB for all years','db_update_BERMS_daily');
        eval_wrapper('DIS data export','fr_automated_cleaning(yy(1)-1:yy(1),{''bs'',''cr'',''hjp02'',''pa'',''yf'',''oy''},4)');
        eval_wrapper('Search for and report missing hhour files','run_hhour_file_search([],[],1)'); % Nick added 10/02/2007
    end % of runCleaning
end
%---------------------------------------------------
% Data export for other people
%---------------------------------------------------

% Dave Spittlehouses CR throughfall data
%dos('net use \\paoa003\ftp_biomet arctic');
eval_wrapper('Exporting data for Dave S.','fr_export_dave_to_ftp');

dos('net use \\paoa001\web_page_wea arctic');
% Weather data for fire indexes
%eval_wrapper('Exporting fire index data MH','MH_FireWeatherIndex_Report(floor(now)+datenum(0,0,0,21,0,0)-[60:-1:0])');
eval_wrapper('Exporting fire index data PM','PM_FireWeatherIndex_Report(floor(now)+datenum(0,0,0,21,0,0)-[60:-1:0])');
eval_wrapper('Exporting fire index data OY','dataforal');
eval_wrapper('Exporting fire index data CR','dataforal_cr');

% UBC Climate station data and graphic export
eval_wrapper('Exporting UBC climate station graphs','web_plots30');
eval_wrapper('Exporting UBC climate station data temperature','outfile30');
eval_wrapper('Exporting UBC climate station data solar','outfile30_solar');
eval_wrapper('Exporting UBC climate station data rain','ubc_rain05_now');

try
    eval_wrapper('Exporting UBC climate station data rain','cs319');
end

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

    evalin('caller',[command_name ';']);
    
catch
    diary(fileName_diary);
    disp(['Error in ' task_name]);
    disp(lasterr);
    diary off;
end
