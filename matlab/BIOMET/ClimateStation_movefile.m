function [Status1,Message1,MessageID1] = ClimateStation_movefile
% ClimateStation_movefile - Moves ClimateStation data files from the DropBox folder
%                           into the c:\sites\ubc\csi_net folder. Files are
%                           date-stamped. It uses fr_movefile to make
%                           safely handle files with the same names.
%                  
%
% (c) Zoran Nesic       File created:   Oct 6, 2014
%                       Last modified:  Aug 7, 2023


% Revisions
%
% Aug 7, 2023 (Zoran)
%   - Added renaming of the CR1000 files.
% Jan 4, 2022 (Zoran)
%   - added try-catch statement
% April 19, 2012 (Nick)
%   -file extensions up to 256 now available

fprintf('Started: %s\n',mfilename);
try
    fileName = 'UBRAW.dat';
    filePath = 'D:\Sites\Sync\Sync\ClimateStation_to_UBC';
    destinationPath = 'D:\SITES\ubc\CSI_NET';
    fileExt = datestr(now,30);
    fileExt = fileExt(1:8);

    sourceFile       = fullfile(filePath,fileName);
    destinationFile1 = fullfile(destinationPath,[fileName(1:end-3) fileExt]);
    [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
    if Status1 ~= 1
        uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',...
            Message1,sourceFile,destinationFile1),'Moving DropBox files to d:\Sites failed','modal'))
    end %if
catch
    fprintf('*** Error in: %s ***\n',mfilename);
end
try
    fileName = 'TF-ClimateStation_CR1000_Clim_30m.dat';
    filePath = 'D:\Sites\ubc\CSI_NET';
    destinationPath = 'D:\SITES\ubc\CSI_NET\OLD';
    fileExt = datestr(now,30);
    fileExt = fileExt(1:8);

    sourceFile       = fullfile(filePath,fileName);
    destinationFile1 = fullfile(destinationPath,[fileName(1:end-3) fileExt]);
    [Status1,Message1,MessageID1] = fr_movefile(sourceFile,destinationFile1);
    if Status1 ~= 1
        uiwait(warndlg(sprintf('Message: %s\nSource path: %s\nDestination path: %s',...
            Message1,sourceFile,destinationFile1),'Moving CR1000 files to d:\Sites failed','modal'))
    end %if
catch
    fprintf('*** Error in: %s ***\n',mfilename);
end
fprintf('Finished: %s\n',mfilename);


        
        