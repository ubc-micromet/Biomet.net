function send_data_to_TimberWest(flagAttempt,emailEnable)
%
% Data emailing to TimerWest.  To be scheduled for 4:08am and 4:35am local time
% 
% flagAttempt - 1 (or nothing) for the first attempt. It also deletes all
%                 c:\ubc_flux\FTP\sent_yyyymmdd that might exist in that
%                 folder
%               2 for the second attempt (to be executed only if there is
%                 not c:\ubc_flux\FTP\sent_yyyymmdd file in the folder
%
% (c) Zoran Nesic           File created:       Feb  2, 2008
%                           Last modification:  Nov  3, 2008

% Revisions:
% 
% Nov 3, 2008 (z)
%   - added local time
% Oct 23, 2008 (z)
%   - changed one email address for TW
% Feb 27, 2008
%   - introduced emailEnable flag (default = 1, TRUE).  Used for testing
%     to avoid sending many emails.  Set to 0 when testing.
% Feb 24, 2008
%   - fixed a bug: program was reporting data from one day earlier than
%     it should have. Changed singleDay = (now-1); to singleDay = (now);
% Feb 11, 2008
%   - added more email addresses to the output list
%

if ~exist('flagAttempt') | isempty(flagAttempt)
    flagAttempt = 1;
end

if flagAttempt == 1 
    % delete all old flag files
    delete('c:\ubc_flux\ftp\sent_*');
end

if ~exist('emailEnable') | isempty(emailEnable)
    emailEnable = 1;
end

standardTime = 4;                   % download data for the 24hours ending at 4am STANDARD time

singleDay = (now);
fileDate = datestr(singleDay,30);
fileDate = fileDate(1:8);
fileName = fullfile('c:\ubc_flux\ftp',['sent_' fileDate]);

if flagAttempt == 2
    %check if the data for today was already sent
    % return if it was sent (no fileName in the folder)
    if exist(fileName,'file')
        return
    end
end

% create the flag file sent_yyyymmdd (store the current time/date in it)
fid = fopen(fileName,'w');
if fid > 0
    fprintf(fid,'Attempting to send at: %s',datestr(now,21));
end
fclose(fid);

% Calculate precip for the previous 24hours for OY site
[precip24hOY , Pgeonor,tv,tv_GMT]=fr_oy_daily_precip(singleDay,standardTime);

% Calculate precip for the previous 24hours for YF site
[precip24hYF , P_tb,tv,tv_GMT]=fr_YF_daily_precip(singleDay,standardTime);

% create the attachment for OY site
fileAttachment = 'c:\ubc_flux\ftp\UBC_report.txt';
fid = fopen(fileAttachment,'wt');
if fid > 0
    fprintf(fid,'\n\n');    
    fprintf(fid,'Piggot Site:        Total precipatation for %s was: %4.2f mm\n\n',datestr(singleDay-1,1),precip24hOY);
    fprintf(fid,'Buckley Bay Site:   Total precipatation for %s was: %4.2f mm\n\n\n\n\n',datestr(singleDay-1,1),max(precip24hYF));
    fprintf(fid,'Report created at: %s Local Time (%s GMT) \n\n',datestr(convert_local2GMT(now,8,1)),datestr(now,0));        
end
fclose(fid);

% Send email
if emailEnable == 1 
    setpref('Internet','SMTP_server','interchange.ubc.ca')
    setpref('Internet','Email','nesic@interchange.ubc.ca')
    %sendmail({'zoran.nesic@ubc.ca','grutzmacherB@TimberWest.com','dhcc@shaw.ca','wheelert@timberwest.com','jekline@timberwest.com','kimbo@storeycreek.com'},sprintf('Piggot & Buckley site reports for %s',datestr(singleDay,1)),' ',fileAttachment);
    sendmail({'zoran.nesic@ubc.ca','dominic.lessard@ubc.ca','nick.grant@ubc.ca','grutzmacherB@TimberWest.com','dhcc@shaw.ca','aalgaardma@timberwest.com','jekline@timberwest.com','kimbo@storeycreek.com','busster@telus.net','wheelert@timberwest.com'},sprintf('Piggot & Buckley site reports for %s',datestr(singleDay,1)),' ',fileAttachment);
    %sendmail({'zoran.nesic@ubc.ca'},sprintf('TEST. TEST. Piggot & Buckley site reports for %s',datestr(singleDay,1)),' ',fileAttachment);
end





        