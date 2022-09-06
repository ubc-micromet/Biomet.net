function OY_DB_UPDATE(SiteID,ind,yearX,driveX)
% Calling syntax:
% OY_DB_UPDATE('OY',360:365,2002,'y:\','021226_021231.mat')  to recalculate and store Dec 26-31, 2002 
% OY_DB_UPDATE('OY',  1:365,2002,'y:\','020101_021231.mat')    to recalculate entire year of data
% driveX is the \\annex001\ drive.  One needs to have write access to this drive.  From zoran's PCs
% one should use drive name: 'y:\'

FileName_p1      = FR_DateToFileName(datenum(yearX,1,1)+ind(1));
FileName_p2      = FR_DateToFileName(datenum(yearX,1,1)+ind(end));
FileName         = ([FileName_p1(1:6) '_' FileName_p2(1:6) '.mat' ]); 

pth_raw = fullfile(driveX,'database',num2str(yearX),'OY\Flux\Raw\');
pth_out = fullfile(driveX,'database',num2str(yearX),'OY\Flux\');

diary(['\\paoa001\Sites\' SiteID '\dbase_logger.log'])
disp(sprintf('==============  Start ========================================='));
disp(sprintf('Date: %s',datestr(now)));
disp(sprintf('Variables: '));
disp(sprintf('pthIn = %s',pth_raw));
disp(sprintf('ind(end) = %s',datestr(ind(end))));
disp(sprintf('pthOut = %s',pth_out));

stats = oy_calc_and_save(SiteID,yearX,1,ind,0,pth_raw);
k = db_main_update_oy_eddy(pth_raw,  FileName, pth_out);

disp(sprintf('Number of files processed = %d',k));
disp(sprintf('==============  End    ========================================='));
disp(sprintf(''));
diary off
