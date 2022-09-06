function x = DB_create_oy_eddy(pth,yearX)
%
%
%
%
% Jan 29, 2003 (Zoran)
%   - changed hard-coded year in "st = " and "ed =" into yearX.  Added
%     yearX as an input parameter


hhours_per_hour = 2;
st = datenum(yearX,1,1,0.5,0,0);
ed = datenum(yearX+1,1,1,0,0,0);

maxFiles = 5*8+4;
% AvgMinMax Before rotation
fileName = 'avgbr';
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
% AvgMinMax After rotation
fileName = 'avgar';
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
% AvgMinMax RawData voltages
fileName = 'avgrv';
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);


% Cov Before Rot AvgDtr
fileName = 'covba';
maxFiles = 30;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Cov After Rot AvgDtr
fileName = 'covaa';
maxFiles = 30;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Fluxes AfterRot AvgDtr
fileName = 'flxaad';
maxFiles = 10;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Fluxes BeforeRot AvgDtr
fileName = 'flxbad';
maxFiles = 10;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Misc
fileName = 'misc';
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
