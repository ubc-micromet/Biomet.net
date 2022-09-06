function db_update_generate_lists

sys = 'profile';

Sites = {'bs' 'cr' 'jp' 'pa'};
Site_name = {'paob' 'cr' 'paoj' 'paoa'};
pth_update_lst = 'D:\db_update';

for i = 1:length(Sites)
   SiteId = char(Sites(i));
   
   pth_new_mat_files = ['P:\' char(Site_name(i)) '\HHour'];
   pth_db            = ['D:\DataBase\2003\' SiteId '\Profile'];
   
   wc = ['*s.h' SiteId(1) '.mat'];
   
   lst_old = dir(fullfile(pth_new_mat_files,wc));
   
   [dum,ind] = sort({lst_old(:).name}');
   lst_old = lst_old(ind(1:end-7));
   save(fullfile(pth_update_lst,['lst_old_'  SiteId '_' sys ]),'lst_old');
   
end

sys = 'rmy';

Sites = {'cr'};
Site_name = {'cr'};

for i = 1:length(Sites)
   SiteId = char(Sites(i));
   
   pth_new_mat_files = ['P:\' char(Site_name(i)) '\HHour'];
   pth_db            = ['D:\DataBase\2003\' SiteId '\TurbulenceProfile'];
   
   wc = ['*s.h' SiteId(1) '_rmy.mat'];
   
   lst_old = dir(fullfile(pth_new_mat_files,wc));
   
   [dum,ind] = sort({lst_old(:).name}');
   lst_old = lst_old(ind);
   save(fullfile(pth_update_lst,['lst_old_'  SiteId '_' sys ]),'lst_old');
   
end
