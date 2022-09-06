function [numfiles, namefiles] = convert_mat_V7toV6(pthIn,pthOut)

% converts v7 .mat files to v6 .mat files

% inputs:
%   pthIn - path where v7 .mat files are stored
%   pthOut - path where v6 .mat files will be saved

% outputs:
% numfiles - number of files converted
% namefiles - name of files converted

% file created: Mar 5, 2008 (Nick, Zoran, Christian)

% Revisions:


tst = pthIn(end);
if ~strcmp(tst,filesep)
  pthIn = [pthIn filesep];
end

if ~exist(pthOut,'dir')
    pthOut = [pthIn 'v6' ];
    mkdir(pthOut);
else
    tst =pthOut(end);
    if ~strcmp(tst,filesep)
       pthOut = [pthOut filesep];
    end
end



% make sure the two paths are not the same!!! at least a warning
% input and output paths are the same! Do you still want to continue?
% (do a GUI window for this)

if strcmp(pthIn,pthOut)
    response =  questdlg(['Input and output paths are identical. Do you want to '...
                        'overwrite v7 .mat files or do you want the converted files saved '...
                        'to a new subfolder called ''v6''? '],...
                        'Warning','Overwrite','Save to subfolder','Cancel','default');
        switch response
        case 'Overwrite'
     
        case 'Save to subfolder'
            pthOut = [pthIn 'v6' ];
            mkdir(pthOut);
            disp(['Created output path ' pthOut ]);
        case 'Cancel'
            disp('...Exiting');
            numfiles = [];
            namefiles = [];
            return
    end
end

s = dir(fullfile(pthIn,'*.mat'));

numfiles = length(s);
namefiles = {s.name};

% convert files one at a time v7 to v6
for i=1:numfiles
    load(fullfile(pthIn,s(i).name));
    save(fullfile(pthOut,s(i).name),'Stats','-v6');
    disp(['Filename ' s(i).name ' converted to v6 format']);
end

disp('');
disp('Number of files converted: ');
disp(numfiles);
