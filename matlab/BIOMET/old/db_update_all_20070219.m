function db_update_all(runCleaning)
% db_update_all
%
% runCleaning - if 1 or missing then run database cleaning
%             - if 0 then skip cleaning and just do the exports
%
% Run all database update and file export tasks
% This function is automatically run by the scheduler every morning

% Revisions:
%   July 6, 2006
%       - Added runCleaning flag (Zoran)
%

if nargin == 0
    runCleaning = 1;
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

if runCleaning == 1
    % Daily cleaning
    eval_wrapper('Updating Eddy DB with daily download','db_update_UBC_daily');
    eval_wrapper('Updating Eddy DB with long hhour files','db_update_hhour_database([yy(1)-1 yy(1)]);');
    eval_wrapper('Updating BERMS DB for current year','db_update_BERMS_daily([],yy(1))');

    % Generation of graphs does not work!
    eval_wrapper('Automatic cleaning of current year','fr_automated_cleaning');
    eval_wrapper('CR chamber cleaning','fr_automated_cleaning_cr_ch(yy(1))');

    % Tasks that are only done on the first saturday of every month
    if strcmp(dayOfWeek,'Sat') & yy(3) <= 7
        eval_wrapper('Update BERMS DB for all years','db_update_BERMS_daily');
        eval_wrapper('DIS data export','fr_automated_cleaning(yy(1)-1:yy(1),{''bs'',''cr'',''hjp02'',''pa'',''yf'',''oy''},4)');
    end
end % of runCleaning

%---------------------------------------------------
% Data export for other people
%---------------------------------------------------

% Dave Spittlehouses CR throughfall data
%dos('net use \\paoa003\ftp_biomet arctic');
eval_wrapper('Exporting data for Dave S.','fr_export_dave_to_ftp');

dos('net use \\paoa001\web_page_wea arctic');
% Weather data for fire indexes
eval_wrapper('Exporting fire index data MH','MH_FireWeatherIndex_Report(floor(now)+datenum(0,0,0,21,0,0)-[60:-1:0])');
eval_wrapper('Exporting fire index data OY','dataforal');
eval_wrapper('Exporting fire index data CR','dataforal_cr');

% UBC Climate station data and graphic export
eval_wrapper('Exporting UBC climate station graphs','web_plots30');
eval_wrapper('Exporting UBC climate station data temperature','outfile30');
eval_wrapper('Exporting UBC climate station data solar','outfile30_solar');
eval_wrapper('Exporting UBC climate station data rain','ubc_rain05_now');

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
