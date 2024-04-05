function tagsOut = getAllTags(siteID)
% Extract all tags for one site
%
%
%
% Zoran Nesic               File created:           Apr 1, 2024
%                           Last modification:      Apr 5, 2024

% Revisions
%
% Apr 5, 2024 (Zoran)
%  - improved handling of missing CustomTags
%  - added beeps when the tag overwriting happens


% first load the standard set
if exist('tags_Standard','file')
    tagsOut = tags_Standard;
else
    tagsOut = [];
end

% then load the site specific set of tags
fileName = [siteID '_CustomTags'];
if exist(fileName,'file')
    tagsCustom = eval(fileName);
    allCustomFields = fieldnames(tagsCustom);
    allStandardFields = fieldnames(tagsOut);
    flagBeep = 1;
    for cntFields = 1:length(allCustomFields)
        fCustomName = char(allCustomFields(cntFields));
        if ismember(fCustomName,allStandardFields)
            if flagBeep == 1
                beep
                flagBeep  = 0;
                fprintf('\n\n');
            end
            fprintf(2,'Overwriting standard tag: %s with the same tag from %s.m\n',fCustomName,fileName);
        end
        tagsOut.(fCustomName) = tagsCustom.(fCustomName);
    end
end



