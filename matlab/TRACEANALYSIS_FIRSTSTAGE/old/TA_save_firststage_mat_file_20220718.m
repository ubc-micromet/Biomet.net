function ta_save_firststage_mat_file(fn_export,trace_str);

% saves Firststage cleaning results in a .mat file
% As of Nov 21, 2007, we are saving as a v6 file even from MATLAB 7.
% This can be updated by changing the use_v6format flag.

% file created: Nov 21, 2007 (Nick)         Last Revised: July 28, 2010

% Revisions:
%   July 28, 2010 (Nick)
%       -Fluxnet02 has been updated to Matlab 7. Set use_v6format = 0.


%use_v6format = 1;
use_v6format = 0;

x=ver;
namestr = {x.Name};
ind =[];
for kk=1:length(namestr)
    if strcmp(char(namestr{kk}),'MATLAB')
        ind = [ind; kk];
    end
end
verstr=x(ind).Version; % check user's MATLAB version--if running 7, save as ver 6 mat file (Nick, Nov 21, 2007)
if strcmp(verstr(1),'7') & use_v6format == 1
    disp('====================================================================================');
    disp('|***MATLAB version 7 session detected--Saving trace information in a v6 mat file***|');
    disp('====================================================================================');
    save(fn_export,'trace_str','-v6');
else 
    save(fn_export, 'trace_str');
end