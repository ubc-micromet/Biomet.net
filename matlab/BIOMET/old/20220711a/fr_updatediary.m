function fr_updatediary(obj, event, string_arg)
try
    % to update diary file first turn it off
    % (that flushes it)
    eval('base','diary off');
    % Then open it back up using the DiaryFileName
    % stored in the userData
    userData = get(0,'userdata');
    DiaryFileName = userData.DiaryFileName;
    currentDiaryFileName = get(0,'DiaryFile');
    if ~strcmpi(DiaryFileName,currentDiaryFileName)
        % if the diary file name changed from the default
        % changed it back to the original. 
        % for troubleshooting purposes, indicate that this
        % change will happen in the currentDiaryFileName before
        % reverting to DiaryFileName
        eval('base', 'diary on')
        fprintf('*** fr_updatediary.m reverted diary name from:\n');
        fprintf('***    %s\n',currentDiaryFileName);
        fprintf('*** to:\n');
        fprintf('***    %s\n',DiaryFileName);
        fprintf('*** at: %s\n',datestr(now))
    end
    eval('base',sprintf('diary %s',DiaryFileName));
catch
end