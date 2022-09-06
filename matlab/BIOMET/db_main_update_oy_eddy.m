function k = db_main_update_oy_eddy(pthIn,wildcard,pthOut)
%
% eg. k = db_main_update_oy_eddy('D:\Elyn_data\TraceAnalysis\OY\stats\',
%                             '*.mat','D:\Elyn_data\TraceAnalysis\OY\2002\dbaseflux');
%       would update the data base using all Jan 2000 files
%
%   This function updates eddy correlation (PC based) data base files.
%   It reads data from hhour files stored in the pthIn directory and
%   updates data base located in pthOut
%   
%   Wildcard parameter lets us choose the site (hp or hc)
% 
% Inputs:
%       pthIn       -   raw data path (*.mat files)
%       wildcard    -   '*.hp.mat' or '*.hc.mat'
%       pthOut      -   data base location for the output data
% Outputs:
%       k           -   number of files processed
%
% (c)                   File created:       Oct 2001
%                       Last modification:  
%
% Revisions:
%
%
pth_tmp = fr_valid_path_name(pthIn);          % check the path and create
if isempty(pth_tmp)                         
    error 'Directory does not exist!'
else
    pthIn = pth_tmp;
end
pth_tmp = fr_valid_path_name(pthOut);          % check the path and create
if isempty(pth_tmp)                         
    error 'Directory does not exist!'
else
    pthOut = pth_tmp;
end

D = dir([pthIn wildcard]);
n = length(D);
k = 0;
tic;
for i=1:n
    %if D(i).isdir == 0 & ~strcmp(D(i).name(7),'s')       % avoid directories and short form hhour files
    if D(i).isdir == 0        % avoid directories, use short form hhour files (Jan 18, 2000)
        if find(D(i).name == ':' | D(i).name == '\') 
            x = load(D(i).name);
        else
            x = load([pthIn D(i).name]);
        end
        disp(sprintf('Processing: %s',D(i).name))
        OutputData = db_update_oy_eddy(x.stats,pthOut);
        k = k+1;
    end
end
tm = toc;
disp(sprintf('%d files processed in %d seconds.',round([k tm])))
