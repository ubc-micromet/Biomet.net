function tagsOut = getAllTagsYML(siteID)
% Extract all tags for one site
%
% Zoran Nesic               File created:           Apr 1, 2024
%                           Last modification:      Apr 5, 2024

% Revisions
%
% Apr 5, 2024 (Zoran)
%  - improved handling of missing CustomTags
%  - added beeps when the tag overwriting happens
% Apr 9, 2024 (JS)
%  - revised to handle a tags in .yml format


% first load the standard se
tag_file = fullfile(biomet_database_default,'Calculation_Procedures\TraceAnalysis_ini\_StandardTags.yml');
if exist(tag_file,'file');
    S = yaml.loadFile(tag_file);
    tagsOut = parseTags(S);
else
    tagsOut = [];
end

custom_tag_file = sprintf('%s_CustomTags.yml',siteID)
custom_tag_file = fullfile(biomet_database_default,'Calculation_Procedures\TraceAnalysis_ini',siteID,'Derived_Variables',custom_tag_file);
if exist(custom_tag_file,'file');
    S = yaml.loadFile(custom_tag_file);
    customtagsOut = parseTags(S);
else
    customtagsOut = [];
end


a=1

function Flt =  flatten_struct(A)
    A = struct2cell(A);
    Flt =  [];
    for i=1:numel(A)  
        if(isstruct(A{i}))
            Flt =  [Flt,flatten_struct(A{i})];
        else
            tags_in = strtrim(strrep(A{i}," ",","));
            Flt =  [Flt,tags_in]; 
        end
    end

end


function tagsOut = parseTags(subStruct,tagsOut)
    % Recursive functition to go through nested struct of tags
    arg_default('tagsOut',struct())
    fn = fieldnames(subStruct);
    for k=1:numel(fn)
        disp(fn{k})
        if isstruct(subStruct.(fn{k}))
            tags_in = flatten_struct(subStruct.(fn{k}));
            tags_in = strjoin(tags_in,",");
            tagsOut = setfield(tagsOut,fn{k},tags_in);
            tagsOut = parseTags(subStruct.(fn{k}),tagsOut);
        elseif isstring(subStruct.(fn{k}))
            tags_in = [strtrim(strrep(subStruct.(fn{k})," ",",")),''];
            tagsOut = setfield(tagsOut,fn{k},tags_in(1));
        end
    end
end
end

function tagsOut = dropDuplicates(tagsOut)

end