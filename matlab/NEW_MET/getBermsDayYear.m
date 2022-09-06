function [day,year] = getBermsDayYear(fileName)

name = char(fileName(:).name);

day  = 0;
year = 0;

if ~isempty(name)
    year = str2num(name(:,4:5));
    ind_19 = find(year>50);
    year(ind_19) = year(ind_19) + 1900;
    ind_20 = find(year< 50);
    year(ind_20) = year(ind_20) + 2000;

    day  = str2num(name(:,6:8));
end



	   