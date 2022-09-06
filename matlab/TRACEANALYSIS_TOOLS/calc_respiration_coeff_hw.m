function [avv,coeff] = calc_respiration_coeff_hw(tv,ustar,Ts2,nee,S39m,leafstart,leafend,ustarc)
%   This program generates a relationship between nighttime CO2 flux
%   and the soil temperature at the 2-cm depth when u* > ustarc (critical value)
%
%	Input: 	tv				- matlab time vector, used to decide whether daytime data is 
%									to be used 
%				ustar			- friction velocity
% 				Ts2			- soil temperature at 2cm	
%				nee			- NEE - Fc + storage (in mg m^-1 s^-1)
%				S39m			- solar radiation, used to decide whether it is day
%				leafstart   - outside of these two day and night are used, default: tv(1)
%				leafend  		default: tv(end)
%				ustarc		- critical ustar value, default 0.35
%
%   (C) Bill Chen							File created:  Oct. 21, 1998
%												Last modified: Nov. 21, 2000
%

%   Revisions:
%    Oct. 07, 1999 by Bill Chen  - add 1999 data
%	 Nov. 21, 2000 by kai*       - made a proper function out of this
%    Nov 9, 2001 E.Humphreys     - using fminsearch instead of fitmain (does not change fit or coefficients)

if ~exist('ustarc') | isempty(ustarc)
   ustarc = 0.35;
end

[dt,year] = convert_tv(tv,'doy',6);

% If no leaf out date are given, use only nighttime data
if ~exist('leafstart') | isempty(leafstart) 
   leafstart = 1;
end
if ~exist('leafend') | isempty(leafend)
   leafend = 367;
end

switch year(1)
case {1994,1996,1998}
   cc = 8;
case 1997
   cc = 6.4;
case 1999
   cc = 7;
otherwise cc = 8;
end

indnight = find((S39m <= 0 | dt < leafstart | dt > leafend) ...
   			 & ustar > ustarc & ~isnan(Ts2.*nee));        

%curve-fitting of Rsha_Ts2cm

avg1 = blockavg(Ts2(indnight),nee(indnight),0.5,30,-20);
ind_avg = find(avg1(:,4) > 50);
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

avg1 = [[-30 -0.2 avg1(1,3:4)]; ...
        [-25 -0.0 avg1(1,3:4)];...
        [-20 -0.0 avg1(1,3:4)]; ...
        avg1; ...
        [20 bb+0.3 avg1(Lavg1,3:4)];...
        [25 bb+0.4 avg1(Lavg1,3:4)];...
        [30 bb+0.5 avg1(Lavg1,3:4)]];   % For logistic only!!     
in = find(~isnan(avg1(:,1).*avg1(:,2)) & avg1(:,3)~=0);

%[coeff,y,r2,sigma]= fitmain([5 .1 .1],'fitlogi5',avg1(in,1),avg1(in,2));
%coeff=[coeff 0]; 

C = [1 1 1];
           
options = optimset('maxfunevals', 1.0e6,...
                   'maxIter',     1.0e6,...
                   'TolX',        1.0e-4,...
                   'TolFun',      1.0e-4,...
                   'display',     'off');
   
[coeff, ESS] = fminsearch('logi5_2_min', C, options, avg1(in,2), avg1(in,1));


avv = avg1;
%avv = blockavg(avg1(:,1),avg1(:,2),0.5,9999,-9999);

%----------------------------------------------------------------------------
function[ESS] = logi5_2_min(coeff, obs_flux, Temp)

respiration = logi5(coeff,Temp); %3 coefficients + temperature

difference = obs_flux - respiration;

ESS = sum(difference .^2);

function y_hat = logi5(coeff,X)
%   THIS PROGRAM DO THE BEST FIT OF RECTANGULAR
%       HYPERBOLA 
%       
%       Y = a/(1 + exp(b*(c-x))) 
%
%

y_hat=(coeff(1))./(1 + exp(coeff(2).*(coeff(3)-X)));