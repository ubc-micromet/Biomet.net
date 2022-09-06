function move_dumpcom_files(pth_dcf,pth_data,dcf_pre,dcf_ext);

% moves a set of HF files created by dumpcom into folders organized by date

% created by:        Nick, Dec 8, 2006
% Last modification: Dec 8, 2006

% Revisions:


% inputs:  pth_dcf  -  location of the dumpcom files
%          pth_data - location of the data folders
%          dcf_pre  - filename prefix
%          dcf_ext  - filename extension
%          

if pth_dcf(end)~= '\'
    pth_dcf = [ pth_dcf '\' ];
end

if pth_data(end)~= '\'
    pth_data = [ pth_data '\' ];
end

lst_all = dir([ pth_data ]);

lst_names = { lst_all.name };
lst_names = char(lst_names');
lst_dir = [ lst_all.isdir ]; 
ind_dir = find(lst_dir == 1);  % find all names in path_data that are directories

% check to make sure that only directories with the correct length are used
ind_mv = [];
for i=1:length(ind_dir)
    if length(deblank(lst_names(ind_dir(i),:))) == 6 
        ind_mv = [ind_mv ; ind_dir(i) ];
    else continue
    end
end
% now come up with a list of existing data folders, and use these to build
% filenames


%tst = ver;     % check for matlab version to ensure correct dos commands are used

fldr_nm = cellstr(deblank(lst_names(ind_mv,:)));

for i=1:length(fldr_nm)
    try
        disp(['...moving files']);
        dos([ 'move ' pth_dcf dcf_pre fldr_nm{i} '*.' dcf_ext ' ' pth_data fldr_nm{i} '\' ],'-echo');
    catch
        disp(lasterr);
    end
end