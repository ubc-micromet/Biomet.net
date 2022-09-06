function [avv,coeff] = calc_respiration_coeff(tv,ustar,Ts2,nee,S39m,leafstart,leafend,ustarc)
%   This program generates a relationship between nighttime CO2 flux
%   and the soil temperature at the 2-cm depth when u* > ustarc (critical value)
%
%	Input: 	tv				- matlab time vector, used to decide whether daytime data is 
%									to be used 
%				ustar		- friction velocity
% 				Ts2			- soil temperature at 2cm	
%				nee			- NEE - Fc + storage (in mg m^-1 s^-1)
%				S39m		- solar radiation, used to decide whether it is day
%				leafstart   - outside of these two day and night are used, default: tv(1)
%				leafend  		default: tv(end)
%				ustarc		- critical ustar value, default 0.35
%
%   (C) Bill Chen							File created:  Oct. 21, 1998
%												Last modified: Nov. 21, 2000
%

%   Revisions:
%              Oct. 07, 1999 by Bill Chen
%              - add 1999 data
%					Nov. 21, 2000 by kai*
%					- made a proper function out of this
%
%    -Oct 27,2001 Elyn - changed to exponential function, removed doy manipulations

if ~exist('ustarc') | isempty(ustarc)
   ustarc = 0.35;
end


% If no leaf out date are given, use only nighttime data
if ~exist('leafstart') | isempty(leafstart) 
   leafstart = tv(1);
end
    
if ~exist('leafend') | isempty(leafend)
   leafend = tv(end);
end

[year] = datevec(tv);

switch year(1)
case {1994,1996,1998}
   cc = 8;
case 1997
   cc = 6.4;
case 1999
   cc = 7;
otherwise cc = 8;
end

min_year = min(year(:,1));
max_year = max(year(:,1));

if min_year ~= max_year;
    no_years = max_year - min_year + 1;    
    indnight = [];
    [leafs_year, leafs_m, leafs_d] = datevec(leafstart);
    [leafe_year, leafe_m, leafe_d] = datevec(leafend);
    for i=1:no_years;
        indnight_tmp = find((S39m <= 0 | ...
            (tv >= datenum(min_year+i-1,1,1) & tv < datenum(min_year+i-1,leafs_m,leafs_d)) | ...
            (tv >= datenum(min_year+i-1,leafe_m,leafe_d) & tv <= datenum(min_year+i-1,12,31))) & ...
            ustar > ustarc & ~isnan(Ts2.*nee));        
        indnight = [indnight; indnight_tmp];
    end
else
    indnight = find((S39m <= 0 | tv < leafstart | tv > leafend) ...
            & ustar > ustarc & ~isnan(Ts2.*nee));
end


%curve-fitting of Rsha_Ts2cm

avg1 = blockavg(Ts2(indnight),nee(indnight),0.5,30,-20);
ind_avg = find(avg1(:,4) > 3);
avg1 = avg1(ind_avg,:);

in = find(~isnan(avg1(:,1).*avg1(:,2)));
avg1 = avg1(in,:);
Lavg1 = length(avg1);
in = find(avg1(:,1)<=-2);
aa = mean(avg1(in,2));
in = find(avg1(:,1)>=20);
bb = mean(avg1(in,2));
if(isnan(bb));
   bb = cc;
end 

in = find(~isnan(avg1(:,1).*avg1(:,2)) & avg1(:,3)~=0);

Qo = [1 1];;
           
options = optimset('maxfunevals', 1.0e6,...
                   'maxIter',     1.0e6,...
                   'TolX',        1.0e-0,...
                   'TolFun',      1.0e-0,...
                   'display',     'off');
   
[coeff, ESS] = fminsearch('Q10_2_min', Qo, options, avg1(in,2), avg1(in,1));

avv = avg1;


