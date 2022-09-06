%function view_sites(ind,year)
function view_sites(x)
    [today_DOY today_year]= fr_get_doy(now,0);
    today_DOY = floor(today_DOY);
    if exist('ind') ~= 1
        ind=today_DOY-6:today_DOY;
    end
    if exist('year') ~= 1
        year = today_year;
    end

% --- View PAOA -------
if x(1) > 0
    try;
        view_one_site(ind,year,'PA');
    end
end
% --- View OBS -------
if x(2) > 0
    try
        view_one_site(ind,year,'BS')
    end
end
% --- View CR -------
try
    view_one_site(ind,year,'CR')
end
% --- View JP -------
try
    view_one_site(ind,year,'JP')
 end
 % --- View OY -------
try
    view_one_site(ind,year,'OY')
end
close all       