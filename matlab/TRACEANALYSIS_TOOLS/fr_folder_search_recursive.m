function s = fr_folder_search_recursive(folderIn,fileName,folderFlag)
%
%
%
% folderFlag        - 0;[]  - find files (default)
%                     1     - find folders only that match,
%

arg_default('folderFlag',0);

s = dir(fullfile(folderIn,'**',fileName));

if folderFlag~= 0
    folderCnt = 0;
    for cnt = 1:length(s)
        %if s(cnt).isdir && ~strcmp(s(cnt).name,'.') && ~strcmp(s(cnt).name,'..')
        if s(cnt).isdir && strcmp(s(cnt).name,'.')
            folderCnt = folderCnt+1;
            if folderCnt == 1
                s1 = s(cnt);
            else
                s1(folderCnt) = s(cnt); %#ok<*AGROW>
            end
        end
    end
    s = s1;
end



% I kept the lines below because of the strange way how Matlab deals with
% the file names on Windows computers. I decided to ignore the fact that
% the file names returned by this function will have names with the same
% capitalization as in the input fileName instead of the actual name in the
% Windows file system. For more, see the Example.
% 

% % Have to pad the fileName with '.*' otherwise Matlab does not properly
% % read the file name caps/lower case letters.
%
% % Example:
%   (Note: the correct file name under Windows is 'Clean_tv' so s2 is
%   correct.)
%
% %   s1 = dir('\\annex001\database\2022\YF\Climate\YF_CR1000_1_MET\clean_tv');
% %   s2 = dir('\\annex001\database\2022\YF\Climate\YF_CR1000_1_MET\clean_tv.*');
% %   fprintf('%s <> %s\n',s1.name,s2.name)
% % Returns:
% %    > clean_tv <> Clean_tv
% %
% 
% % The padding should be only done for the fileName-s that don't already have
% % an extension. So pad only files without '.' in their names
% if contains(fileName,'.')
%     s_tmp = dir(fullfile(folderIn,'**',fileName));
% else
%     s_tmp = dir(fullfile(folderIn,'**',[fileName '.*']));
% end
% 
% % Because of padding the file names, now one needs to make sure that some
% % files were not mistakenly added to the list (there should be no file
% % names that have the original file name but a different extension)
% goodRecords = 0;
% for cntFile = 1:length(s_tmp)
%     if strcmp(s_tmp(cntFile).name,fileName)
%         goodRecords = goodRecords+1;
%         s(goodRecords) = s_tmp(cntFile); %#ok<*AGROW>
%     end
% end
% % if no good results, return an empty struct
% if goodRecords == 0
%     s = struct([]);
% end

        