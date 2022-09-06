function mpb_rename_and_calc(sites,year,pth_mpb);

pth_old = path;
for i=1:length(sites)
    siteId=char(sites{i});
    fr_set_site(siteId,'n');
    [dataPth,hhourPth,databasePth,csiPth] = FR_get_local_path;
   [date_HF,N] = CRBasic_file_rename_mpb(siteId,pth_mpb);
   pth_calc = fullfile(pth_mpb,siteId);
    if exist('date_HF','var')
        calc_date = [];
        for i=1:length(date_HF)
            if length(char(date_HF{i}))==6
                yymmdd = (char(date_HF{i}));
                yy = yymmdd(1:2);
                yyyy = str2num(['20' yy]);
                mm = str2num(yymmdd(3:4));
                dd = str2num(yymmdd(5:6));
                calc_date = [calc_date; datenum(yyyy,mm,dd)];
            end
        end
        recalc_create_for_mpb(siteId,year,pth_calc);
        recalc_configure_for_mpb(pth_calc);
        new_calc_and_save(calc_date(1):calc_date(end),siteId);
        path(pth_old);
    end
    % sync hhour flux files to PAOA001\Sites\MPBx\hhour
%     switch siteId
%         case 'MPB1'
%             sites_drive = 'L:\';
%         case 'MPB2'
%             sites_drive = 'M:\';
%         case 'MPB3'
%             sites_drive = 'N:\';
%         case 'MPB4'
%             sites_drive = 'O:\';            
%     end
%     dos(['robocopy ' hhourPth ' ' sites_drive ' /COPYALL /E /R:0']);
end