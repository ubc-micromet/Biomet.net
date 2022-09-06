function k = DB_main_update_chambers(siteFlag,pthIn,wildcard,pthOut)
% This function updates chamber database files.
%
% It reads data from hhour files stored in the pthIn directory and updates database located in pthOut
%   
% Inputs:
%           siteFlag
%           pthIn       -   raw data path (*.mat files)
%           wildcard    -   narrow down the choice of mat files to be processed
%           pthOut      -   data base location for the output data
% Outputs:
%           k           -   number of files processed
%
% syntax: k = db_main_update_chambers('\\PAOA001\SITES\PAOA\HHour\','*s.hp.mat','D:\david_data\2002\PA\chambers\slope_min\')
%
% File created by Zoran Nesic 2002.02.15
% Revisions: Feb 10, 2010
%
% Feb 10, 2010 - put file loading inside a try/catch (Nick)
% Feb 8, 2005 - added possibility to work with siteFlag (David)

pth_tmp = fr_valid_path_name(pthIn);          % check the path and create
if isempty(pth_tmp)                         
    error 'Directory does not exist!'
else
    pthIn = pth_tmp;
end

pth_tmp = fr_valid_path_name(pthOut);         % check the path and create
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
            try % nick, 2/10/2010
               x = load(D(i).name);
            catch
                disp(lasterr);
            end
        else
            try % nick, 2/10/2010
               x = load([pthIn D(i).name]);
            catch
               disp(lasterr);
            end
        end
        disp(sprintf('Processing: %s',D(i).name))
        OutputData = DB_update_chambers(x.Stats,pthOut);
        k = k+1;
    end
end
tm = toc;
disp(sprintf('%d files processed in %d seconds.',round([k tm])))
