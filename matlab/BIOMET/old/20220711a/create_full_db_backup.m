function create_full_db_backup(years,sites,pth_bckup);

% 20170130 Zoran: program obsolete as far as I can tell
disp('Obsolete program.  Use : create_full_biomet_db_backup.m instead.')
return

pc_name = fr_get_pc_name;

if isempty(pth_bckup) &  (strcmp(upper(pc_name),'PAOA001') | strcmp(upper(pc_name),'FLUXNET02') )
   pth_db = db_pth_root;
   arg_default('pth_bckup',fullfile(pth_db,'full_backups'));
end

if isempty(sites)
   sites = {'CR' 'OY' 'YF' 'BS' 'OA' 'OJP' 'HJP02'};
end

today_str = datestr(now,'yyyy-mm-dd');
today_str = today_str([1:4 6:7 9:10]);


for i=1:length(sites)
    basepth =  [pth_bckup '_' sites{i}];
    %for j=1:length(years)
    try
        recalc_create(sites{i},years,basepth,today_str)
    catch
        disp(['Recalc backup failed for ' sites{i} ]);
    end
    %end
    basepth = fullfile(basepth,today_str);
    try
        recalc_cleaning_backup(sites{i},basepth)
    catch
        disp(['Cleaning file backup failed for ' sites{i} ]);
    end
end