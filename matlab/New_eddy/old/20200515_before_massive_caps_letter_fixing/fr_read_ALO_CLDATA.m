function [EngUnits,Header] = fr_read_ALO_CLDATA(dateIn,configIn,instrumentNum)
% fr_read_ALO_HFDATA - reads data that is stored as a comma delimeted file.
%                       Most likely works only on Alberto's data (Brian Amiro)
% 
%
% Inputs:
%   dateIn      - datenum (this is not a vector, only one file is read at the time)
%   configIn    - standard UBC ini file
              %   systemNum   - system number (see the ini file)
%   instrumentNum - instrument number (see the ini file)
%
% Outputs:
%   EngUnits    - data matrix if file exists, empty if file is missing
%   Header      - file header
%
%
% (c) Zoran Nesic           File created:       Nov  7, 2003
%                           Last modification:  Nov  7, 2003

% Revisions
%
    pth = configIn.path;
    fileName = configIn.Instrument(instrumentNum).Name;
    FileID = configIn.Instrument(instrumentNum).FileID;
    if ~isempty(FileID) & strcmp(upper(FileID),'YYYYDDD')
        [doy,year] = fr_get_doy(dateIn,0);
        doy = num2str(ceil(doy));
        year = num2str(year);
        if length(doy)<3 
            doy = ['0'*ones(1, 3-length(doy)) doy];
        end
        FileID = [year doy];
    end
    fileName = [fileName '.' FileID];

    fullFileName = fullfile(pth,fileName);
    if exist(fullFileName)~= 2
        pth = [pth fileName(1:6) '\'];
        fullFileName = fullfile(pth,fileName);
        if exist(fullFileName)~= 2
            fullFileName = [];
        end
    end
    if isempty(fullFileName)
        error(['File: ' dummy ' does not exist!'])
    end
   
    x=textread(fullFileName,'%f','headerlines',2,'delimiter',',');
    y=reshape(x,7,length(x)/7)';
    tv = datenum(y(:,2),1,y(:,3),fix(y(:,4)/100),y(:,4)-fix(y(:,4)/100)*100,0);
    ind = find(abs(tv-dateIn)<1/49);
    EngUnits = y(ind,:);
    Header = [];
