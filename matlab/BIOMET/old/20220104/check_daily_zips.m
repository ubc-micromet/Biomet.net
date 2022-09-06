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
        if doy >= 0 & doy < 10
           zerstr = '_00';
       elseif doy >= 10 & doy < 100
           zerstr = '_0' ;
       else
           zerstr = '_';
       end
       fn_zip = fullfile(pth_zip,[char(sites{k}) '_' num2str(dv(1)) zerstr num2str(doy(i)) '.zip']);
        if ~exist(fn_zip,'file')
            lst_sites = [lst_sites; sites(k) ];
        end
    end
    if isempty(lst_sites)
        disp(['No sites are missing daily zips for DOY ' zerstr(2:end) num2str(doy(i)) ]);
    else
        disp(['The following sites are missing daily zips for DOY ' zerstr(2:end) num2str(doy(i)) ':' ]);
        for i=1:length(lst_sites)
            disp([lst_sites(i)]);
        end
    end
end


