function k = db_main_update_chamber_paul(pthIn,wildcard,pthOut)
% 
% eg. k = db_main_update_chamber_paul('\\ANNEX001\2003_HF_CR\MET-DATA\hhour\',...
%                             '03*.hc_ch.mat','\\annex001\database\2003\cr\chambers\');
%       would update the data base using all 2003 files
%
% (c)kai*               File created:       Sep 15, 2003
%                       Last modification:  
%
% Revisions:
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
        OutputData = db_update_chamber_paul(x.stats,pthOut);
        k = k+1;
    end
end
tm = toc;
disp(sprintf('%d files processed in %d seconds.',round([k tm])))
