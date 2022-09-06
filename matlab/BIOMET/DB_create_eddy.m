function x = DB_create_eddy(pth)
%
%
%
%
%
% (c) Zoran Nesic           File created:       May   , 1998
%                           Last modification:  Dec 17, 2009
 
%
% Revisions:
%  Dec 29,2010
%       - new year (2011)
%Dec 17,2009
%       - new year (2010)
%   Dec 10,2008
%       - new year (2009)
%   Dec 27, 2006
%       - new year (2007)
%   Dec 19, 2005
%       - new year (2006)
%   Dec 23, 2002
%       - new year (2003)
%   Dec 28, 2001
%       - new year (2002)
%   Feb 6, 2001
%       - changed the start and the end time from:
%           st = datenum(2001,1,1,0,0,0);
%           ed = datenum(2002,1,1,-0.5,0,0);
%         to:
%           st = datenum(2001,1,1,0.5,0,0);
%           ed = datenum(2002,1,1,0,0,0);
%         to match the new data-logger file lengths
%
%   Jan 26, 2000
%       - removed siteID variable (hasn't been used in the program anyway)
%   Jan 18, 2000
%       - changed dates so we can create year 2000 data base.
%   Sep  5, 1999
%       - added extension for year 1999 => ed = datenum(2000,1,1,-0.5,0,0);
%   Aug  5, 1999
%       - increased maxNumOfChans for Avgxx files from 120 to 180
%         to deal with the extra data coming from the DAQ book
%   May 27, 1998
%       -   changed end time from:
%               ed = datenum(1999,1,1,0,0,0);
%           to 
%               ed = datenum(1999,1,1,-0.5,0,0);
%           so the length of data base stays the same as for the dataloggers
%

%
%pth = 'c:\cd-rom\CR_DBASE\';
%siteID = 'CR';



hhours_per_hour = 2;
st = datenum(2011,1,1,0.5,0,0);
ed = datenum(2012,1,1,0,0,0);


maxFiles = 180;
% AvgMinMax Before rotation
fileName = 'avgbr';
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
% AvgMinMax After rotation
fileName = 'avgar';
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
% AvgMinMax RawData counts
fileName = 'avgrc';
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
% AvgMinMax RawData voltages
fileName = 'avgrv';
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);



% Cov Before Rot LinDtr
fileName = 'covbl';
maxFiles = 12*12;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Cov Before Rot AvgDtr
fileName = 'covba';
maxFiles = 12*12;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Cov After Rot LinDtr
fileName = 'coval';
maxFiles = 12*12;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Cov After Rot AvgDtr
fileName = 'covaa';
maxFiles = 12*12;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Fluxes LinDtr
fileName = 'flxld';
maxFiles = 20;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Fluxes AvgDtr
fileName = 'flxad';
maxFiles = 20;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Misc
fileName = 'misc';
maxFiles = 30;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Angles
fileName = 'angle';
maxFiles = 3;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Recalc time vector (DOUBLE!!)
ZeroFile = zeros(DB_len,1);                                     % create a full size zero array
fileName = [pth 'reclc.1'];                                     % recalc time vector
fid = fopen(fileName,'w');                                      % create time vector file
file_err_chk(fid)                                               % check if file opened properly
x = fwrite(fid,ZeroFile,'float64');                             % save TimeVector
fclose(fid);


%===============================================================
% LOCAL FUNCTIONS
%===============================================================
function x = file_err_chk(fid)
    if fid == -1
        error 'File opening error'
    end
