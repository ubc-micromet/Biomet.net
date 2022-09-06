function db_update_cal_stats_only(Year);

% updates only cal_stats files in the database for an input year
% so you don't have to run db_update_UBC_daily (and update the whole
% database) to do so.

% Nick, Sept 22, 2006

Sites     = {'BS' 'CR' 'JP' 'PA' };
Site_name = {'PAOB' 'CR' 'PAOJ' 'PAOA' };
pth_db = fullfile(db_pth_root,'');

for i=1:length(Sites)
    SiteId     = char(Sites(i));
    fr_set_site(SiteId,'n');
    SiteNm     = char(Site_name(i));
    Year_str   = num2str(Year);
    pth_stats = [pth_db Year_str '\' SiteId '\'];
    disp(['Output path root for ' char(Sites(i)) ' is ' pth_stats ]);
    wc         = [Year_str(3:4) '*s.h' SiteId(1) '.mat'];
    wc_ch      = [Year_str(3:4) '*s.h' SiteId(1) '_ch.mat'];
    pth_sfiles = ['\\paoa001\Sites\' SiteNm '\HHour'];
    lst_sfiles = dir(fullfile(pth_sfiles,wc));
    lst_ch_sfiles = dir(fullfile(pth_sfiles,wc_ch));
    % updates eddy and profile cal_stats
    for i = 1:length(lst_sfiles)
        x = load(fullfile(pth_sfiles,lst_sfiles(i).name));
        db_update_cal_stats(x.stats,pth_stats);
        disp(['updated cal_stats for ' lst_sfiles(i).name ])
    end
%     % updates chamber cal_stats
%     if ~isempty(lst_ch_sfiles)
%         for i = 1:length(lst_ch_sfiles)
%             x = load(fullfile(pth_sfiles,lst_ch_sfiles(i).name));
%             db_update_cal_stats(x.stats,pth_stats);
%             disp(['updated chamber cal_stats for ' lst_ch_sfiles(i).name ])
%         end
%     end
    save(fullfile(pth_stats,['lst_old_' SiteId '_cal_stats' ]),'lst_sfiles');
end
