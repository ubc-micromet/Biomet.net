function [mainFunctionNames, extraFunctionNames] = packFunctions(s,matlabPath)
% cd to the folder with  most of your functions (or a blank one)
% make subfolders extraFunctions
%                 mainFunctions
% run: "profile clear;profile on;new_calc_and_save(datenum(2004,1,15));profile off;s=profile('info');save profile_info s"
% then: "testnames(s,'C:\MATLAB6\toolbox\')"  this will exclude all m files from under ...\toolbox
%
%s=profile('info');
k = 0;
j = 0;
funExtra = [];
funMain = [];
extraFunctionNames = cell(1,1);
mainFunctionNames = cell(1,1);
N = size(s.FunctionTable,1);
if ~exist('matlabPath','var') | isempty(matlabPath)
    matlabPath = 'C:\MATLABR11\toolbox\';
end
currentFolder = pwd;
for i = 1:N
    try
        % works with Matlab 5.3
        funName = s.FunctionTable(i).MfileName;
    catch
        % works with Matlab 6.x
        funName = s.FunctionTable(i).FileName;
    end
    if ~( strcmp(upper(funName(1:12)),upper(matlabPath(1:12))) | strcmp(upper(funName(1:12)),upper(currentFolder(1:12))) )
        k = k+1;
        funExtra(k) = i;
        extraFunctionNames(k) = {funName};
    end
    if strcmp(upper(funName(1:12)),upper(currentFolder(1:12)))
        j = j+1;
        funMain(j) = i;
        mainFunctionNames(j) = {funName};
    end

end
if k > 0
    extraFunctionNames = unique(extraFunctionNames);
    k = length(extraFunctionNames);
    disp(sprintf('\nFound: %d functions that are not under "%s" or under "%s"',k,matlabPath,currentFolder));
    newFunctionsPath = fullfile(currentFolder,'extraFunctions');
    disp(sprintf('Moving extra functions to "%s"',newFunctionsPath));
    status = mkdir(currentFolder,'extraFunctions');
    if status==1 
        disp(sprintf('New folder "%s" created.',newFunctionsPath));
    else
        disp(sprintf('Folder "%s" already exists.',newFunctionsPath));
        disp('Deleting existing files...')
        delete(fullfile(newFunctionsPath,'*.m'))
    end
    for i=1:k
        sourceX = char(extraFunctionNames(i));
        destX = newFunctionsPath;
        disp(sprintf('Copying: %d. %s ...', i,sourceX));
        status = copyfile(sourceX,destX);
        if status == 0
            disp('************* Copy failed! ************');
        end
    end
end

if j > 0
    mainFunctionNames = unique(mainFunctionNames);
    j = length(mainFunctionNames);
    disp(sprintf('\nFound: %d used functions that are under "%s"',j,currentFolder));
    mainFunctionsPath = fullfile(currentFolder,'mainFunctions');
    disp(sprintf('Copying main functions to "%s"',mainFunctionsPath));
    status = mkdir(currentFolder,'mainFunctions');
    if status==1 
        disp(sprintf('New folder "%s" created.',mainFunctionsPath));
    else
        disp(sprintf('Folder "%s" already exists.',mainFunctionsPath));
        disp('Deleting existing files...')
        delete(fullfile(mainFunctionsPath,'*.m'))
    end
    for i=1:j
        sourceX = char(mainFunctionNames(i));
        destX = mainFunctionsPath;
        disp(sprintf('Copying: %d. %s ...', i, sourceX));
        status = copyfile(sourceX,destX);
        if status == 0
            disp('************* Copy failed! ************');
        end
    end
end
        
        

