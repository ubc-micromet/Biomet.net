function fr_export_dave_to_FTP
% fr_export_dave_to_FTP  Exporting interceptio data for Dave Spittlehouse to 
% the biomet FTP site
%
% This function calls datafordave by Elyn H.

dv = datevec(now);

datafordave(dv(1),datenum(dv(1),1,1),datenum(dv(1),dv(2),1),'interception','\\paoa003\ftp_biomet\dave\', 0);
datafordave(dv(1),datenum(dv(1),1,1),datenum(dv(1),dv(2),1),'model','\\paoa003\ftp_biomet\dave\', 0);
