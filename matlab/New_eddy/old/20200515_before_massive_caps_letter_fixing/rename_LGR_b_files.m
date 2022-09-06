% rename all raw data files for LGR so that the extensions do not start
% as *.dLGR* instead of *.bLGR*
pth1 = 'd:\met-data\data\';

fprintf('Start of renaming\n');
% first convert all the *.bLGR1101.mat files in the current folder 
s = dir(fullfile(pth1,'*.BLGR1101.mat'));

for i=1:length(s)
    new_name = s(i).name;
    ind = strfind(new_name,'BLGR');
    if ~isempty(ind)
        new_name(ind) = 'd';
    end
        
    fprintf('%s -> %s  ',fullfile(pth1,s(i).name),fullfile(pth1,new_name));
    ss= movefile(fullfile(pth1,s(i).name),fullfile(pth1,new_name));
    if ss==1
        fprintf('-> success\n');
    else
        fprintf('-> error\n');
    end
end

% and all the *.bLGR1101 files in the current folder 
s = dir(fullfile(pth1,'*.bLGR1101'));

for i=1:length(s)
    try
        new_name = s(i).name;
        ind = strfind(new_name,'BLGR');
        if ~isempty(ind)
            new_name(ind) = 'd';
        end

        fprintf('%s -> %s  ',fullfile(pth1,s(i).name),fullfile(pth1,new_name));
        ss=movefile(fullfile(pth1,s(i).name),fullfile(pth1,new_name));
        if ss==1
            fprintf('-> success\n');
        else
            fprintf('-> error\n');
        end
    end
end



% then convert all the files in folders
s_tmp = dir(fullfile(pth1));
%s_dir = [];
k=0;
for i=1:length(s_tmp)
    if s_tmp(i).isdir & ~ strcmp(s_tmp(i).name(1),'.')
        k = k+1;
        if k==1
            s_dir = s_tmp(i);
        else
            s_dir(k) = s_tmp(i);
        end
    end
end


for j=1:k
    % cycle through each data folder and look for *.bLGR1101.mat files
    pth_data = fullfile(pth1,s_dir(j).name);
    % convert all the files in the current folder 
    s = dir(fullfile(pth_data,'*.bLGR1101.mat'));
    
    for i=1:length(s)
        new_name = s(i).name;
        ind = strfind(new_name,'BLGR');
        if ~isempty(ind)
            new_name(ind) = 'd';
        end
        fprintf('%s -> %s\n',fullfile(pth_data,s(i).name),fullfile(pth_data,new_name));
        ss= movefile(fullfile(pth1,s(i).name),fullfile(pth1,new_name));
        if ss==1
            fprintf('-> success\n');
        else
            fprintf('-> error\n');
        end
    end
    
    % cycle through each data folder and look for *.bLGR1101 files
    pth_data = fullfile(pth1,s_dir(j).name);
    % convert all the files in the current folder 
    s = dir(fullfile(pth_data,'*.bLGR1101'));
    
    for i=1:length(s)
        new_name = s(i).name;
        ind = strfind(new_name,'BLGR');
        if ~isempty(ind)
            new_name(ind) = 'd';
        end

        fprintf('%s -> %s\n',fullfile(pth_data,s(i).name),fullfile(pth_data,new_name));
        ss= movefile(fullfile(pth1,s(i).name),fullfile(pth1,new_name));
        if ss==1
            fprintf('-> success\n');
        else
            fprintf('-> error\n');
        end
    end
    
end
fprintf('End of renaming\n');