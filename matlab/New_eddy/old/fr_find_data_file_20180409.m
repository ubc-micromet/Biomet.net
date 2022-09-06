function [fullFileName,fileName] = fr_find_data_file(dateIn,configIn,instrumentNum,customeName)
% fr_find_data_file - returns a full file name if file exists, empty if not
% 
% This function is used to confirm existance and find the full path of a UBC
% data file. It returns an empty matrix if the file does not exist. It needs
% the standard UBC ini file.
%
% Inputs:
%   dateIn      - datenum (this is not a vector, only one file is read at the time)
%   configIn    - standard UBC ini file
%   systemNum   - system number (see the ini file)
%   instrumentNum - instrument number (see the ini file)
%   customeName   - explicit file name
%
% Outputs:
%   fullFileName- file name with path if file exists, empty if file is missing
%   fileName    - file name without the path 
%
%
% (c) Zoran Nesic           File created:       Sep 26, 2001
%                           Last modification:  Sep  7, 2004

% Revisions
%
%  Sep 7, 2004 - changed:
%    pth = [pth fileName(1:6) '\'];
%    fullFileName = fullfile(pth,fileName);
%   to
%    pth = [pth fileName(1:6) '\'];
%    fullFileName = fullfile(pth,fileName(1:6),fileName);
%   to avoid need to put '\' at the end of the path
%
%  Oct 8, 2002 - allowed a database file to be found with this procedure

arg_default('customeName');

if strcmp(upper(configIn.Instrument(instrumentNum).FileType),'DATABASE')
        pth = configIn.database_path;
        yr = datevec(dateIn);
        fileName = fullfile(num2str(yr(1)), configIn.site, ...
            configIn.Instrument(instrumentNum).FileID);
        fullFileName = fullfile(pth, fileName);    
        if exist(fullFileName)~= 2
            fullFileName = [];
        end
        
elseif strcmp(upper(configIn.Instrument(instrumentNum).FileType),'CSI') ...
    | ~isempty(customeName)
        pth = configIn.csi_path;
        fileName = customeName;
        fullFileName = fullfile(pth, customeName);    
        if exist(fullFileName)~= 2
             fullFileName = [];
        end
        
elseif strcmp(upper(configIn.Instrument(instrumentNum).FileType),'CUSTOME') ...
    | ~isempty(customeName)
        % assume instrumentNum contains filename
        pth = configIn.path;
        fileName = customeName;
        fullFileName = fullfile(pth, customeName);    
        if exist(fullFileName)~= 2
            fileNameDate = FR_DateToFileName(dateIn);
            pth = [pth fileNameDate(1:6) '\'];
            fullFileName = fullfile(pth,customeName);
            if exist(fullFileName)~= 2
                fullFileName = [];
            end
        end
else
        pth = configIn.path;
        fileName = FR_DateToFileName(dateIn);
        FileID = configIn.Instrument(instrumentNum).FileID;
        fileName = [fileName configIn.ext FileID];
        fullFileName = fullfile(pth,fileName);
        if exist(fullFileName)~= 2
%            pth = [pth fileName(1:6) '\'];
            fullFileName = fullfile(pth,fileName(1:6),fileName);
            if exist(fullFileName)~= 2
                fullFileName = [];
            end
        end
end

