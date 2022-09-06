function nee = calc_nee(clean_tv,
% This program calculates NEE. NEE = Fc + St, where Fc is CO2 flux
% and St is CO2 storage in the column from surface to measurement level
%
% (C)Bill Chen						File created:  May 27, 1998
%										Last modified: Oct 07, 1999
%
% Note: NEE of 1994 come from Paul directly.
%
% Revision:
%           Oct. 07, 1999 by Bill Chen
%           - add 1999 data
%				May. 26, 1999 by Bill Chen
%           - get nee94 from Paul's nee data
%				Feb. 02, 1999 by Bill Chen
%				- calculate NEE of 1998
%				Nov. 17, 1998 by Bill Chen
%				- change save path
%
%  Altaf Arain, March 22, 2000
%  - Updated for SOBS site

global DATA_PATH_BILL

% --- get time series ---
load([DATA_PATH_BILL 'BS\1999\halfhour\DecDOY_99']);
CST99 = t_99;

% --- get CO2 fluxes ---
%load([DATA_PATH_BILL_1 '1999\halfhour\Fco2_39m_99']);
%Fc99 = 1000/44*Fco2_39m_99;	%unit convert from mg/m2/s to umol/m2/s

load([DATA_PATH_BILL 'BS\1999\halfhour\Fc_99bs']);
Fc99bs = Fc_99bs;	%unit umol/m2/s

% --- get CO2 storage from ground to the measured level ---
load([DATA_PATH_BILL 'BS\1999\halfhour\dcdt99bs']); 


%--- calculate NEE and pick out unreasonable value ---
nee99bs       = Fc99bs + dcdt99;
%ind         = [316 4050];
%nee99bs(ind) 	= NaN*ones(length(ind),1);
%nee99bs(ind)  = (nee99bs(ind-1)+nee99bs(ind+1))/2;

save ([DATA_PATH_BILL 'BS\1999\halfhour\nee99bs'],'nee99bs')
% save 'c:\bill\data\boreas\tf\BS\1999\halfhour\nee99bs' nee99bs
