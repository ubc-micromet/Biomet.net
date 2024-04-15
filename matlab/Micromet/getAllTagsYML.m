function tagsOut = getAllTagsYML(siteID)

% % Should be stored in a config file, a standalone file
% calc_prodecures = fullfile(biomet_database_default,'Calculation_Procedures\TraceAnalysis_ini');
% config_file = fullfile(calc_prodecures,'_config.yml');

path,name,ext = matlab.desktop.editor.getActiveFilename
config_file = fullfile(calc_prodecures,'_config.yml');

% Load default tags from the config file
% Will crash if does not exit, but everyone shoud obtain the default config
% if they don't already have it.  Will also crash if user doesn't have yaml
% extenion installed.  Go to add on and search "yaml".
% Ideally this config file would only be loaded once, somewhere much
% further up the chain
config = yaml.loadFile(config_file);
tags_in = config.Processing.FirstStage.DependencyTags;
tagsOut = parseTags(tags_in);

% Conditionally load custom tags from site specific config file
site_config_file = fullfile(calc_prodecures,siteID,sprintf('%s_config.yml',siteID));
if exist(site_config_file,'file');
    site_config = yaml.loadFile(site_config_file);
    try
        tags_in = site_config.Processing.FirstStage.DependencyTags;
        site_tags = parseTags(tags_in);
        % Append custom dependencies to default tags where applicable
        % Otherwise add as new dependency field
        fn = fieldnames(site_tags);
        for n =1:length(fn)
            if isfield(tagsOut,fn{n})
                tags_in = strjoin([tagsOut.(fn{n}),site_tags.(fn{n})],',');
                tagsOut = setfield(tagsOut,fn{n},tags_in(1));
            else
                tagsOut = setfield(tagsOut,fn{n},site_tags.(fn{n}));
            end
        end
    catch
        disp('Site-specific tags do not exist or could not be parsed')
    end
end

% Remove any duplicate values
tagsOut = dropDuplicates(tagsOut);


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
        if isstruct(subStruct.(fn{k}))
            tags_in = flatten_struct(subStruct.(fn{k}));
            tags_in = strjoin(tags_in,",");
            tagsOut = setfield(tagsOut,fn{k},tags_in);
            tagsOut = parseTags(subStruct.(fn{k}),tagsOut);
            % Reset to current fn
            fn = fieldnames(subStruct);
        elseif isstring(subStruct.(fn{k}))
            tags_in = [strtrim(strrep(subStruct.(fn{k})," ",",")),''];
            tagsOut = setfield(tagsOut,fn{k},tags_in(1));
        end
    end
end
end

function tagsOut = dropDuplicates(tagsOut)
    fn = fieldnames(tagsOut);
    for n =1:length(fn)
        tags_in = unique(split(tagsOut.(fn{n}),','));
        tags_in = strjoin(tags_in,',');
        tagsOut = setfield(tagsOut,fn{n},tags_in);
    end
end