function pth = db_pth_root
% pth = db_pth_root
%
% Returns the database path that updates will be written to.

% Last modified: 
%
% Nov 4, 2022 (Zoran)
%   - changed to more robust way of finding the root path by using 
%     biomet_path('yyyy')
% Apr 11, 2022 (Zoran)
%   - added call to setFolderSeparator() to deal with MacOS paths.
% Apr 2, 2022 (Zoran)
%   - added a non-optional filesep on the end of the path
% Jan 21, 2009
%   -changed exist test to if exist('...') == 2 (Nick)
% Oct 16, 2008
%       -added biomet_database_default for updating/testing local dbase
%       updates (Nick)
% Dec 20, 2007
%      -changed back to network drive formulation after Annex001 replaced
%      with file server; permissions now determined by user (Nick)
% May 30, 2006: 
%      -changed to network drive formulation to allow recalc_create to run
%       from Fluxnet02
%                              

pth = biomet_path('yyyy');      % pth will contain year 'yyyy' in it
ind = strfind(pth,'yyyy');      % find where it starts
pth = pth(1:ind-1);             % extract the string before the 'yyyy' part
                                % Note: it keeps the trailing filesep (legacy issues)
pth = fullfile(pth);            % this sorts out file separators (macOS vs Windows)





