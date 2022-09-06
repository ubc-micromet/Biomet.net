function recalc_create(SiteId,Years,base_path,dir_name)

%==========================================================================
% Create base directory 
% If it already exists stop because it might already be in use. If user
% wants to use this name it'll have to be deleted manually.
[s,mes] = mkdir(base_path,dir_name);
if ~isempty(mes)
    disp(mes);
    disp('... returning');
    diary off    
    return
end

base_dir = fullfile(base_path,dir_name);

%==========================================================================
% Start log file
diary(fullfile(base_dir,'recalc.log'));
disp(sprintf('== Creating recalculation setup =='));
disp(sprintf('Date: %s',datestr(now)));
disp(sprintf('SiteId = %s',SiteId));

%==========================================================================
% Get the Site name
All_Sites     = {'BS' 'CR' 'FEN' 'HJP02' 'HJP75' 'HJP94' 'JP'   'OY' 'PA' 'YF' 'UBC_Totem'...
                 'MPB1' 'MPB2' 'MPB3' 'HDF11' 'HP09' 'HP11'};
All_Site_name = {'PAOB' 'CR' 'FEN' 'HJP02' 'HJP75' 'HJP94' 'PAOJ' 'OY' 'PAOA' 'YF' 'UBC' ...
                 'MPB1' 'MPB2' 'MPB3' 'HDF11' 'HP09' 'HP11'};
[dum,ind_id] = intersect(upper(All_Sites),upper(SiteId));
if isempty(ind_id)
    disp(sprintf('The requested site ID: %s has not been found among the known site names: ',SiteId))
    disp(All_Sites)
    disp('... returning');
    diary off
    return
end
SiteName = char(All_Site_name(ind_id));

%==========================================================================
% Copy and create biomet setup matlab files
disp('Copying biomet.net...');
[s,mes] = mkdir(base_dir,'Biomet.net\Matlab');
[s,mes] = copyfile('\\paoa001\matlab',[base_dir '\Biomet.net\Matlab']);
if ~isempty(mes)
    disp(mes)
    disp('... returning');
    diary off
    return
else
    disp(sprintf('%s - done',datestr(now)));
end

%==========================================================================
% Copy Site_Specific

disp('Copying Site_specific...');
[s,mes] = mkdir(base_dir,'UBC_PC_SETUP\Site_specific');
[s,mes] = copyfile(['\\paoa001\Sites\' SiteName '\UBC_PC_SETUP\Site_specific\*.m'],[base_dir '\UBC_PC_SETUP\Site_specific']);
% PC_specific is not copied since we use the one on the current PC
if ~isempty(mes)
    disp(mes)
    disp('... returning');
    diary off
    return
else
    disp(sprintf('%s - done',datestr(now)));
end

disp('Creating fr_get_local_path.m...');
% if on the network overwrite fr_get_local_path
fid = fopen([base_dir '\UBC_PC_SETUP\Site_specific\fr_get_local_path.m'],'wt');
if fid > 0
    fprintf(fid,'%s\n','function [dataPth,hhourPth,databasePth,csiPth] = FR_get_local_path');
    fprintf(fid,'%% This function was generated by recalc_create.m\n');
    fprintf(fid,'dataPth  = %s%s%s;\n',char(39),['\\FLUXNET02\HFREQ_' upper(SiteId) '\met-data\data\'],char(39));
    fprintf(fid,'hhourPth  = %s%s%s;\n',char(39),fullfile(base_dir,'\hhour\') ,char(39));
    fprintf(fid,'databasePth  = %s%s%s;\n',char(39),'\\ANNEX001\Database\',char(39));
    fprintf(fid,'csiPth  = %s%s%s;\n',char(39),['\\FLUXNET02\HFREQ_' upper(SiteId) '\met-data\csi_net\'],char(39));
    fclose(fid);
else
    disp(['Could not create ' base_dir '\UBC_PC_SETUP\Site_specific\fr_get_local_path.m'])
    disp('... returning');
    diary off
    return
end
disp(sprintf('%s - done',datestr(now)));

disp('Copying calibration files...');
[s,mes] = mkdir(base_dir,'hhour');
%3/10/2010: Nick added the '*' wildcard before calibrations to catch manual
%cal files
[s,mes] = copyfile(['\\paoa001\Sites\' SiteName '\hhour\*calibrations*.*'],[base_dir '\hhour']); 
if ~isempty(mes)
    disp(['**************** -> Error: ' mes])
    %disp('... returning');
    %return
else
    disp(sprintf('%s - done',datestr(now)));
end

%==========================================================================
% Create first, second and thirdstage database (for comparison with current
% results)
disp('Creating first, second and third stage database ...');
[s,mes] = mkdir(base_dir,'database');
pth = pwd;
cd(base_dir); % This causes the cleaning log file to be created in base_dir
for k=1:length(Years)
    try
        fr_automated_cleaning(Years(k),SiteId,[1 2 3],[base_dir '\database'])
    catch
        disp(['Cleaned traces backup failed for ' SiteId ', ' num2str(Years(k)) ]);
        continue
    end
end
cd(pth);
diary(fullfile(base_dir,'recalc.log'));
disp(sprintf('== Finished recalculation setup =='));
diary off
return

