function check_daily_zips(doy);

% checks \\PAOA001\Sites folders for daily zips

dv = datevec(now);
sites = { 'CR' 'YF' 'OY' 'PAOB' 'PAOA' 'HJP02' };
arg_default('doy');
if isempty(doy)
    doy = floor(now) - datenum(dv(1),1,0);
end

for i=1:length(doy)
    lst_sites = {};
    for k=1:length(sites)
        pth_zip = ['\\PAOA001\Sites\' char(sites{k}) '\DailyZip\old\'];
        fn_zip = fullfile(pth_zip,[char(sites{k}) '_' num2str(dv(1)) '_' num2str(doy(i)) '.zip']);
        if ~exist(fn_zip,'file')
            lst_sites = [lst_sites; sites(k) ];
        end
    end
    if isempty(lst_sites)
        disp(['No sites are missing daily zips for DOY ' num2str(doy(i)) ]);
    else
        disp(['The following sites are missing daily zips for DOY ' num2str(doy(i)) ':' ]);
        for i=1:length(lst_sites)
            disp([lst_sites(i)]);
        end
    end
end


