function db_update_web_files
% db_update_web_files
%  
%  Created    Jan 19, 2010   Rick 
%  This program is used to run more frequent updates of web accessable files
%  This function is automatically run by the task scheduler multiple times per day

% Revisions:
%   
%       - 
yy = datevec(now); 
dayOfWeek = datestr(now,8);

dos('net use \\paoa001\sites arctic');
dos('net use \\paoa003\ftp_biomet arctic');
dos('net use \\paoa001\web_page_wea arctic');


% UBC Climate station data and graphic export
eval_wrapper('Exporting UBC climate station graphs','web_plots30');
eval_wrapper('Exporting UBC climate station data temperature','outfile30');
eval_wrapper('Exporting UBC climate station data solar','outfile30_solar');
%eval_wrapper('Exporting UBC climate station data rain','ubc_rain05_now');

% commented out July 21, 2010 (Nick)
% try
%     eval_wrapper('Exporting UBC climate station data rain','cs319');
% end

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
