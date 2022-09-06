function Stats_all = fcrn_load_data(currentDate,SiteId)

Stats_all = [];

%----------------------------------------------------
% Make sure SiteId is current
%----------------------------------------------------
arg_default('SiteId',fr_current_siteid);
if ~strcmp(upper(SiteId),upper(fr_current_siteid))
   fcrn_set_site(SiteId)
end

%----------------------------------------------------
% Get list of long files
%----------------------------------------------------
[pth_data,pth_hhour] = fr_get_local_path;
c = fr_get_init(SiteId, currentDate(1));
lst_comp = dir(fullfile(pth_hhour,['*' c.hhour_ext]));

if isempty(lst_comp)
   disp('Did not find data files.');
   return
end

filenames = char({lst_comp(:).name}');
ind_longfiles = find(lower(filenames(:,7)) == '.');
filenames_long = filenames(ind_longfiles,:);

if isempty(filenames_long)
   disp('Did not find long data files. Loading short ones...');
else
   filenames = filenames(ind_longfiles,:);
end

tv_comp_all = datenum(str2num(filenames(:,1:2))+2000,str2num(filenames(:,3:4)),str2num(filenames(:,5:6)));

%----------------------------------------------------
% Select dates to be compared here
%----------------------------------------------------
if exist('currentDate')~=1 | isempty(currentDate)
   currentDate = tv_comp_all;
end
   
[tv_comp,ind_comp] = intersect(tv_comp_all,currentDate);
if isempty(ind_comp)
   disp('Did not find data for requested date.');
   return
end

filenames = filenames(ind_comp,:);
n_fil = length(tv_comp);


%----------------------------------------------------
% Load up all data requested
%----------------------------------------------------
disp(' ');
disp(['Loading data for ' SiteId ' from ' pth_hhour]);
Stats_all = [];
for i = 1:n_fil
   load_name = fullfile(pth_hhour,deblank(filenames(i,:)));
   x = load(load_name);
   Stats_all = [Stats_all x.Stats];
   disp(['Loaded ' load_name]);
end

i1 = 1;
while isempty(Stats_all(i1).Configuration)
    i1 = i1+1;
end
Stats_all(1).Configuration = Stats_all(i1).Configuration;
