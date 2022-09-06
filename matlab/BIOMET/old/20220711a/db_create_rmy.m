function x = DB_create_rmy(pth,rmy_no)
%
% based on db_create_eddy   File created:       Aug  1, 2003
%                           Last modification:  Aug  1, 2003
 
%
% Revisions:
%

%
%pth = 'c:\cd-rom\CR_DBASE\_' num2str(rmy_no) ];
%siteID = 'CR_' num2str(rmy_no) ];

if ~exist('rmy_no') | isempty(rmy_no)
   disp('Please give an RMYoung no. => returning');
   x = 0;
   return
end

hhours_per_hour = 2;
st = datenum(2003,1,1,0.5,0,0);
ed = datenum(2004,1,1,0,0,0);


maxFiles = 16;
% AvgMinMax Before rotation
fileName = ['avgbr_' num2str(rmy_no) ];
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);
% AvgMinMax After rotation
fileName = ['avgar_' num2str(rmy_no) ];
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Cov Before Rot LinDtr
fileName = ['covbl_' num2str(rmy_no) ];
maxFiles = 4*4;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Cov Before Rot AvgDtr
fileName = ['covba_' num2str(rmy_no) ];
maxFiles = 4*4;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Cov After Rot LinDtr
fileName = ['coval_' num2str(rmy_no) ];
maxFiles = 4*4;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Cov After Rot AvgDtr
fileName = ['covaa_' num2str(rmy_no) ];
maxFiles = 4*4;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Fluxes LinDtr
fileName = ['flxld_' num2str(rmy_no) ];
maxFiles = 2;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Fluxes AvgDtr
fileName = ['flxad_' num2str(rmy_no) ];
maxFiles = 2;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Misc
fileName = ['misc_' num2str(rmy_no) ];
maxFiles = 6;
[DB_len] = DB_create(pth,fileName,st,ed,hhours_per_hour,maxFiles);

% Angles
fileName = ['angle_' num2str(rmy_no) ];
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
