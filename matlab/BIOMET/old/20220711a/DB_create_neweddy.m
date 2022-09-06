function x = DB_create_neweddy(pth)
%
%
%
%
%
% (c) Zoran Nesic           File created:       May   , 1998
%                           Last modification:  Dec 28, 2001
 
%
% Revisions:
% April 5, 2003 - reduced the number of files made for each type (no need for 180 avgar - 50 is fine)




hhours_per_hour = 2;
st = datenum(2004,1,1,0.5,0,0);
ed = datenum(2005,1,1,0,0,0);


maxFiles = 50;
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
maxFiles = 9*9;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Cov Before Rot AvgDtr
fileName = 'covba';
maxFiles = 9*9;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Cov After Rot LinDtr
fileName = 'coval';
maxFiles = 9*9;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Cov After Rot AvgDtr
fileName = 'covaa';
maxFiles = 9*9;
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

% Stationarity
fileName = 'stationary';
maxFiles = 15;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Skewness
fileName = 'skew';
maxFiles = 10;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Kurtosis
fileName = 'kurt';
maxFiles = 10;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Kurtosis
fileName = 'spikes';
maxFiles = 10;
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
