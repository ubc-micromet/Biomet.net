fid= fopen('C:\Ubc_flux\DeleteOldZip.bat', 'wt'); %open the file for writing, use text mode instead of binary
deleteDate = datestr(now - 14, 2); %save two weeks of files
deleteDate = strrep (deleteDate,'/','-'); %change the date fromat to from dd/mm/yyyy to dd-mm-yyyy
fprintf(fid, '@ECHO OFF\n');
% Yf Site -------------------------------------------------------------------------
fprintf(fid, 'XCOPY D:\\Sites\\Yf\\DailyZip\\old\\*.* D:\\Sites\\Yf\\DailyZip\\old\\temp /D:%s /k/i\n', deleteDate);
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\Yf\\DailyZip\\old\\*.*\n');
fprintf(fid, 'XCOPY D:\\Sites\\Yf\\DailyZip\\old\\temp\\*.* D:\\Sites\\Yf\\DailyZip\\old\\\n');
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\Yf\\DailyZip\\old\\temp\\*.*\n');
% OY Site -------------------------------------------------------------------------
fprintf(fid, 'XCOPY D:\\Sites\\OY\\DailyZip\\old\\*.* D:\\Sites\\OY\\DailyZip\\old\\temp /D:%s /k/i\n', deleteDate);
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\OY\\DailyZip\\old\\*.*\n');
fprintf(fid, 'XCOPY D:\\Sites\\OY\\DailyZip\\old\\temp\\*.* D:\\Sites\\OY\\DailyZip\\old\\\n');
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\OY\\DailyZip\\old\\temp\\*.*\n');
% Yf Site -------------------------------------------------------------------------
fprintf(fid, 'XCOPY D:\\Sites\\Yf\\DailyZip\\old\\*.* D:\\Sites\\Yf\\DailyZip\\old\\temp /D:%s /k/i\n', deleteDate);
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\Yf\\DailyZip\\old\\*.*\n');
fprintf(fid, 'XCOPY D:\\Sites\\Yf\\DailyZip\\old\\temp\\*.* D:\\Sites\\Yf\\DailyZip\\old\\\n');
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\Yf\\DailyZip\\old\\temp\\*.*\n');
% PAOA Site -------------------------------------------------------------------------
fprintf(fid, 'XCOPY D:\\Sites\\PAOA\\DailyZip\\old\\*.* D:\\Sites\\PAOA\\DailyZip\\old\\temp /D:%s /k/i\n', deleteDate);
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\PAOA\\DailyZip\\old\\*.*\n');
fprintf(fid, 'XCOPY D:\\Sites\\PAOA\\DailyZip\\old\\temp\\*.* D:\\Sites\\PAOA\\DailyZip\\old\\\n');
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\PAOA\\DailyZip\\old\\temp\\*.*\n');
% Paob Site -------------------------------------------------------------------------
fprintf(fid, 'XCOPY D:\\Sites\\Paob\\DailyZip\\old\\*.* D:\\Sites\\Paob\\DailyZip\\old\\temp /D:%s /k/i\n', deleteDate);
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\Paob\\DailyZip\\old\\*.*\n');
fprintf(fid, 'XCOPY D:\\Sites\\Paob\\DailyZip\\old\\temp\\*.* D:\\Sites\\Paob\\DailyZip\\old\\\n');
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\Paob\\DailyZip\\old\\temp\\*.*\n');
% HJP02 Site -------------------------------------------------------------------------
fprintf(fid, 'XCOPY D:\\Sites\\HJP02\\DailyZip\\old\\*.* D:\\Sites\\HJP02\\DailyZip\\old\\temp /D:%s /k/i\n', deleteDate);
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\HJP02\\DailyZip\\old\\*.*\n');
fprintf(fid, 'XCOPY D:\\Sites\\HJP02\\DailyZip\\old\\temp\\*.* D:\\Sites\\HJP02\\DailyZip\\old\\\n');
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\HJP02\\DailyZip\\old\\temp\\*.*\n');
% HJP75 Site -------------------------------------------------------------------------
fprintf(fid, 'XCOPY D:\\Sites\\HJP75\\DailyZip\\old\\*.* D:\\Sites\\HJP75\\DailyZip\\old\\temp /D:%s /k/i\n', deleteDate);
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\HJP75\\DailyZip\\old\\*.*\n');
fprintf(fid, 'XCOPY D:\\Sites\\HJP75\\DailyZip\\old\\temp\\*.* D:\\Sites\\HJP75\\DailyZip\\old\\\n');
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\HJP75\\DailyZip\\old\\temp\\*.*\n');
% Paoj Site -------------------------------------------------------------------------
fprintf(fid, 'XCOPY D:\\Sites\\Paoj\\DailyZip\\old\\*.* D:\\Sites\\Paoj\\DailyZip\\old\\temp /D:%s /k/i\n', deleteDate);
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\Paoj\\DailyZip\\old\\*.*\n');
fprintf(fid, 'XCOPY D:\\Sites\\Paoj\\DailyZip\\old\\temp\\*.* D:\\Sites\\Paoj\\DailyZip\\old\\\n');
fprintf(fid, 'ECHO Y | DEL D:\\Sites\\Paoj\\DailyZip\\old\\temp\\*.*\n');
fclose (fid);

