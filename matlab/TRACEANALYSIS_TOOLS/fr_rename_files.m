function s = fr_rename_files(folderIn,oldName,newName)
s = fr_folder_search_recursive(folderIn,oldName);
for cntFile = 1:length(s)
    oldFile = fullfile(s(cntFile).folder,s(cntFile).name);
    newFile = fullfile(s(cntFile).folder,newName);
    % Matlab uses movefile to rename files and the file name in Windows
    % cannot be renamed if the new name is the same, just with different
    % letter cases ('Clean_tv' == 'clean_tv' under windows and causes
    % an error: 
    %     Error using movefile
    %     Cannot copy or move a file or directory onto itself.
    % Hence, the file first needs to be renamed into something else
    
    % Create a temporary name in the same folder where the file is:
    tmpFile = tempname(s(cntFile).folder);
    movefile(oldFile,tmpFile);
    % then rename to the correct name:
    movefile(tmpFile,newFile)
    fprintf('%s => %s\n',oldFile,newFile);
end

