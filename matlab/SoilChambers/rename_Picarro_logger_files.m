function rename_Picarro_logger_files(dateRange,pth_csi,pth_data)
%
% Revisions:
%   Jan 11, 2017 (Zoran)
%       - Fixed a bug that caused missing data (the second half of the data
%       set would go missing).  This was happening because the previous day's data
%       was stored in two logger files.  
%       One was named ACR_CR23x..._1._YYYYMMDD and the other
%       half was in the file named ACR_CR23x..._1.dat.  The program
%       relied on processing both of those files on the *next* (YYYYMM(DD+1))day. If that
%       run was missed the second half of the day would go permanently
%       "missing".
%       The fix:
%           Look into the next day for the second half of the data set
%           (important when running the data PC on GMT time and doing
%           recalculations on a PC on standard time (otherwise half a day might
%           end up missing)
%       Before:
%            [tv1,achData1] = ach_move_and_rename(dateIn,pth_csi,['ACS_CR23X_final_storage_1.' dateStr],pth_data,'ACS_CR23X_final_storage_1.dat',102,'30min');
%            [tv1,achData1] = ach_move_and_rename(dateIn,pth_csi,'ACS_CR23X_final_storage_1.dat',pth_data,'ACS_CR23X_final_storage_1.dat',102,'30min');
%       After: 
%         [tv1,achData1] = ach_move_and_rename(dateIn,pth_csi,['ACS_CR23X_final_storage_1.' dateStr],pth_data,'ACS_CR23X_final_storage_1.dat',102,'30min');
%          dateStrNext=datestr(dateIn+1,'yyyymmdd');
%          [tv1,achData1] = ach_move_and_rename(dateIn,pth_csi,['ACS_CR23X_final_storage_1.' dateStrNext],pth_data,'ACS_CR23X_final_storage_1.dat',102,'30min');
%         [tv1,achData1] = ach_move_and_rename(dateIn,pth_csi,'ACS_CR23X_final_storage_1.dat',pth_data,'ACS_CR23X_final_storage_1.dat',102,'30min');

% renames hhour averaged and 5 s averaged 23X logger files and saves to
% biomet HF data folders

for dateIn = dateRange
    dateStr=datestr(dateIn,'yyyymmdd');
    try
      [tv1,achData1] = ach_move_and_rename(dateIn,pth_csi,['ACS_CR23X_final_storage_1.' dateStr],pth_data,'ACS_CR23X_final_storage_1.dat',102,'30min'); %#ok<*NASGU,*ASGLU>
      % Look into the next day for the second half of the data set
      % (important when running the data PC on GMT time and doing
      % recalculations on a PC on standard time (otherwise half a day might
      % end up missing) (Zoran, Jan 11, 2017)
      dateStrNext=datestr(dateIn+1,'yyyymmdd');
      [tv1,achData1] = ach_move_and_rename(dateIn,pth_csi,['ACS_CR23X_final_storage_1.' dateStrNext],pth_data,'ACS_CR23X_final_storage_1.dat',102,'30min');
      [tv1,achData1] = ach_move_and_rename(dateIn,pth_csi,'ACS_CR23X_final_storage_1.dat',pth_data,'ACS_CR23X_final_storage_1.dat',102,'30min');
      [tv2,achData2] = ach_move_and_rename(dateIn,pth_csi,['ACS_CR23X_final_storage_2.' dateStr],pth_data,'ACS_CR23X_final_storage_2.dat',101,'sec');
      [tv2,achData2] = ach_move_and_rename(dateIn,pth_csi,['ACS_CR23X_final_storage_2.' dateStrNext],pth_data,'ACS_CR23X_final_storage_2.dat',101,'sec');
      [tv2,achData2] = ach_move_and_rename(dateIn,pth_csi,'ACS_CR23X_final_storage_2.dat',pth_data,'ACS_CR23X_final_storage_2.dat',101,'sec');
    catch
      %   [tv1,achData1] = ach_move_and_rename(dateIn,pth_csi,['ACS_CR23X_final_storage_1.' dateStr],pth_data,102,'30min');
      %   [tv2,achData2] = ach_move_and_rename(dateIn,pth_csi,['ACS_CR23X_final_storage_2.' dateStr],pth_data,101,'sec');
       disp(fprintf('...CSI logger file data extraction failed for %s',datestr(dateIn,1)));
    end
end