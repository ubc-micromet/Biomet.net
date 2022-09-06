function x = DB_create_chamber_paul(pth,Year)
%
% based on db_create_eddy   File created:       Sep 15, 2003
%                           Last modification:  Sep 15, 2003
 
%
% Revisions:
%

if exist('Year') ~= 1 | isempty(Year)
   Year = datevec(now);
   Year = Year(1);
end

hhours_per_hour = 2;
st = datenum(Year,1,1,0.5,0,0);
ed = datenum(Year+1,1,1,0,0,0);


maxFiles = 1; % Number of chambers
% AvgMinMax Before rotation
fileName = ['co2_after'];
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
fileName = ['co2_before'];
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
fileName = ['stdCO2'];
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
fileName = ['r2'];
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
fileName = ['dcdt'];
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
fileName = ['delta_dcdt'];
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
fileName = ['flux'];
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
fileName = ['delta_flux'];
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
fileName = ['temp1'];
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
fileName = ['temp2'];
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
fileName = ['tair'];
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
fileName = ['pbar'];
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
