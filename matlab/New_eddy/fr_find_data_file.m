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
%                           Last modification:  Oct  6, 2022

% Revisions
%
%  Oct 6, 2022 (Zoran)
%  - changed arg_default('customeName') to arg_default('customeName',[]);
%    The newest version of arg_default does not tolerate missing second argument.
%  Sep 7, 2004 - changed:
%    pth = [pth fileName(1:6) '\'];
%    fullFileName = fullfile(pth,fileName);
%   to
%    pth = [pth fileName(1:6) '\'];
%    fullFileName = fullfile(pth,fileName(1:6),fileName);
%   to avoid need to put '\' at the end of the path
%
%  Oct 8, 2002 - allowed a database file to be found with this procedure

arg_default('customeName',[]);

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
        fileNameDate = fr_DateToFileName(dateIn);
        pth = [pth fileNameDate(1:6) '\'];
        fullFileName = fullfile(pth,customeName);
        if exist(fullFileName)~= 2
            fullFileName = [];
        end
    end
else
    pth = configIn.path;
    fileName = fr_DateToFileName(dateIn);
    FileID = configIn.Instrument(instrumentNum).FileID;
    fileName = [fileName configIn.ext FileID];
    fullFileName = fullfile(pth,fileName);
    % First look for the file directly under ..\met-data\data
    if ~exist(fullFileName,'file')
        % if it doesn't exist there, add the folder name:
        % ..\met-data\data\yymmdd\
        fullFileName = fullfile(pth,fileName(1:6),fileName);
        if ~exist(fullFileName,'file') && (strcmp(configIn.Instrument(instrumentNum).FileType,'LGR1') && exist([fullFileName '.mat'],'file'))
            % if it does not exist but it's of type FileType == 'LGR1'
            % and it exist as [fullFileName '.mat'] then:
            fullFileName = [fullFileName '.mat'];
        else
            % if it doesn't exist as ..\met-data\data\yymmdd\yymmdd.FileID
            % set it the fullFileName to empty.  Otherwise it will return
            % the fullFileName
            if ~exist(fullFileName,'file')
                fullFileName = [];
            end
        end
    end
end

